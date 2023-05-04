
CREATE PROCEDURE [dbo].[sp_GatewayMessageReader]
AS


DECLARE
    @conversation uniqueidentifier,
    @senderMsgType nvarchar(100),
    @msg xml

declare
    @IdGateway  int,                          
    @Claimcode  nvarchar(max),
    @ReturnCode nvarchar(max),
    @ReturnCodeType int,
    @XmlValue xml,
	@IsCorrect bit,
	@IdTransfer INT,
	@PrevIdStatus INT

Begin Try 

WAITFOR (
    RECEIVE TOP(1)
        @conversation=conversation_handle,
        @msg=message_body,
        @senderMsgType=message_type_name
    FROM QueueSW.GatewayRecipQueue);


    IF @senderMsgType = N'//Maxi/Transfer/GatewayDataType'
    BEGIN
        SELECT @msg AS RecievedMessage,@senderMsgType AS SenderMessageType;

        SET @IdGateway = @msg.value('(GatewayDataType/Transfer/IdGateway)[1]', 'INT');
        SET @Claimcode = @msg.value('(GatewayDataType/Transfer/Claimcode)[1]', 'NVARCHAR(max)');
        SET @ReturnCode = @msg.value('(GatewayDataType/Transfer/ReturnCode)[1]', 'NVARCHAR(max)')        
        SET @ReturnCodeType = @msg.value('(GatewayDataType/Transfer/ReturnCodeType)[1]', 'INT')        
        SET @XmlValue = @msg.query('GatewayDataType/Transfer/Response/*')

		SELECT @IdTransfer=IdTransfer, @PrevIdStatus=IdStatus 
		FROM Transfer WITH(NOLOCK)
		WHERE ClaimCode=@Claimcode

		IF @IdGateway=18             
		BEGIN
			EXEC st_ResponseReturnCodeChapina @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    
		END 

		IF @IdGateway=4 or @IdGateway=23
		BEGIN
			EXEC  st_ResponseReturnCodeBTS @IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue,@IsCorrect Output                    
		END

        INSERT INTO GatewayDataTmp
        VALUES
        (@IdGateway,@Claimcode,@ReturnCode,@ReturnCodeType,@XmlValue)

    END

	DECLARE @NewIdStatus	INT

	SELECT
		@NewIdStatus = t.IdStatus
	FROM Transfer t WITH(NOLOCK)
	WHERE t.IdTransfer = @IdTransfer

	DECLARE @LogDescription VARCHAR(MAX)

	IF (@IsCorrect = 1 AND @PrevIdStatus <> @NewIdStatus)
	BEGIN
		IF EXISTS (SELECT TOP 1 * FROM TransferModify WITH(NOLOCK) WHERE OldIdTransfer = @IdTransfer and IsCancel = 0) AND @NewIdStatus NOT IN (22, 25, 26, 35)
			EXEC st_TransferModifyResponseGateway @IdTransfer, 0
		ELSE IF @NewIdStatus = 22 AND EXISTS (SELECT TOP 1 * FROM TransferModify WITH(NOLOCK) WHERE OldIdTransfer = @IdTransfer)
			EXEC st_TransferModifyResponseGateway @IdTransfer, 1
	END
    
		insert into dbo.SBReceiveGatewayMessageLog (ConversationID,MessageXML) values (@conversation,@msg)    

	END CONVERSATION @conversation;-- WITH CLEANUP;

End Try                                                                                            
Begin Catch
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('sp_GatewayMessageReader',Getdate(),@ErrorMessage)                                                                                            
End Catch  

