CREATE PROCEDURE [dbo].[sp_UpdateMessageReader]
AS
/********************************************************************
<Author>eneas salazar</Author>
<app>Maxi</app>
<Description>Reiniciar los Queues del ambiente correspondiente</Description>

<ChangeLog>
<log Date="22/08/2018" Author="esalazar">Creacion</log>
<log Date="16/06/2022" Author="jdarellano" Name="#1">Performance: se agregan WITH (NOLOCK).</log>
</ChangeLog>
--Development Status
--56 -> Update Transfer
--70 -> Update In Progress

--QA
--74 -> Update Transfer
--73 -> Update In Progress

Stage, Produccion Status
--70 -> Update In Progress
--71 -> Update Transfer
********************************************************************/
DECLARE
    @conversation uniqueidentifier,
    @senderMsgType nvarchar(100),
    @msg xml;

DECLARE @IdTransfer int;
DECLARE @IdTransferStatus int;
DECLARE @EnterByIdUser int;
DECLARE @IdUserType Int;
DECLARE @IdAgent int;
DECLARE @IdAgentStatus int;
--Declare @IdPayer int  
DECLARE @OFAC int;
DECLARE @CustomerName nvarchar(max);
DECLARE @CustomerFirstLastName nvarchar(max);
DECLARE @CustomerSecondLastName nvarchar(max);  
DECLARE @BeneficiaryName nvarchar(max);
DECLARE @BeneficiaryFirstLastName nvarchar(max);
DECLARE @BeneficiarySecondLastName nvarchar(max);
--Declare @IdPaymentType int  
--Declare @Amount money
--Declare @Reference int
--Declare @Country nvarchar(max)
--Declare @AgentCommissionExtra money
--Declare @AgentCommissionOriginal money
--Declare @ModifierCommissionSlider money
--Declare @ModifierExchangeRateSlider money
--Declare @IdTransferResend int
DECLARE @DateOfTransfer datetime;
--Declare @StateTax money
--Cambios para ofac transfer detail
DECLARE @IsOFAC bit;
DECLARE @IsOFACDoubleVerification bit;

BEGIN TRY

	WAITFOR (
    RECEIVE TOP(1)
        @conversation=conversation_handle,
        @msg=message_body,
        @senderMsgType=message_type_name
    FROM QueueSW.UpdateRecipQueue);

	    
    IF @senderMsgType = N'//Maxi/Transfer/UpdateDataType'
    BEGIN
        SELECT @msg AS RecievedMessage,@senderMsgType AS SenderMessageType;

        SET @IdTransfer = @msg.value('(UpdateDataType/Transfer/IdTransfer)[1]', 'INT');
        SET @IdTransferStatus = @msg.value('(UpdateDataType/Transfer/IdTransferStatus)[1]', 'INT');
        SET @EnterByIdUser = @msg.value('(UpdateDataType/Transfer/EnterByIdUser)[1]', 'INT');
        SET @IdAgent = @msg.value('(UpdateDataType/Transfer/IdAgent)[1]', 'INT');
        --set @IdPayer = @msg.value('(OriginDataType/Transfer/IdPayer)[1]', 'INT')        
        --set @IdPaymentType = @msg.value('(OriginDataType/Transfer/IdPaymentType)[1]', 'INT')        
        SET @CustomerName = @msg.value('(UpdateDataType/Transfer/CustomerName)[1]', 'NVARCHAR(max)');
        SET @CustomerFirstLastName = @msg.value('(UpdateDataType/Transfer/CustomerFirstLastName)[1]', 'NVARCHAR(max)');
        SET @CustomerSecondLastName = @msg.value('(UpdateDataType/Transfer/CustomerSecondLastName)[1]', 'NVARCHAR(max)');
        SET @BeneficiaryName = @msg.value('(UpdateDataType/Transfer/BeneficiaryName)[1]', 'NVARCHAR(max)');
        SET @BeneficiaryFirstLastName = @msg.value('(UpdateDataType/Transfer/BeneficiaryFirstLastName)[1]', 'NVARCHAR(max)');
        SET @BeneficiarySecondLastName = @msg.value('(UpdateDataType/Transfer/BeneficiarySecondLastName)[1]', 'NVARCHAR(max)');
       -- set @Amount = @msg.value('(OriginDataType/Transfer/Amount)[1]', 'MONEY')
       -- set @Reference = @msg.value('(OriginDataType/Transfer/Reference)[1]', 'INT')
       -- set @Country = @msg.value('(OriginDataType/Transfer/Country)[1]', 'NVARCHAR(max)')
       -- set @AgentCommissionExtra= @msg.value('(OriginDataType/Transfer/AgentCommissionExtra)[1]', 'MONEY')
       -- set @AgentCommissionOriginal = @msg.value('(OriginDataType/Transfer/AgentCommissionOriginal)[1]', 'MONEY')
       -- set @ModifierCommissionSlider = @msg.value('(OriginDataType/Transfer/ModifierCommissionSlider)[1]', 'MONEY')
       -- set @ModifierExchangeRateSlider = @msg.value('(OriginDataType/Transfer/ModifierExchangeRateSlider)[1]', 'MONEY')
		--set @IdTransferResend =@msg.value('(OriginDataType/Transfer/IdTransferResend)[1]', 'INT') 
		SET @DateOfTransfer =@msg.value('(UpdateDataType/Transfer/DateOfTransfer)[1]', 'DATETIME');
		--set @StateTax =@msg.value('(OriginDataType/Transfer/StateTax)[1]', 'MONEY') 


		----------------------  Insert in case Resend Transfer -------------------------------------------------------                                                                                                        
        --------------------------------------------------------------------------------------------------------------
                                                                                                     
                                                                                                     
		                                                        
		---------------------------- State Tax --------------------------------------------------------------------------                                                                    
		-----------------------------------------------------------------------------------------------------------------                                   

        --------------------------- Balance -----------------------------------------------------------------------------
       -----------------------------------------------------------------------------------------------------------------                                   

        ------------------------- Hold Validations ---------------------------------------------------------------------
        --Set @OFAC=0  
        --Cambios para ofac transfer detail
        SET @IsOFAC = 0;
        SET @IsOFACDoubleVerification = 0;

        DECLARE @IdUserSystem int;
        SELECT @IdUserSystem = [Value] FROM dbo.GlobalAttributes WITH (NOLOCK) WHERE [Name] = 'SystemUserID';
  
        IF @IdTransferStatus = 71  
		BEGIN
			------------------------------ Signature validation .. Phone verification-----------------------------------
			EXEC st_SaveChangesToTransferLog @IdTransfer,2,'Signature Validation',0; --- Log de validacion  

			SELECT @IdUserType = IdUserType FROM dbo.Users WITH (NOLOCK) WHERE IdUser = @EnterByIdUser;

			IF @IdUserType = 2 AND NOT EXISTS (SELECT 1 FROM dbo.AgentUser WITH (NOLOCK) WHERE IdUser = @EnterByIdUser)-- usuario Multiagente--  
			BEGIN  
				IF EXISTS (SELECT 1 FROM dbo.TransferHolds WITH (NOLOCK) WHERE IdTransfer = @IdTransfer AND IdStatus = 3 AND (IsReleased = 0 OR IsReleased IS NULL))
				BEGIN
					DELETE FROM dbo.TransferHolds WHERE IdTransfer = @IdTransfer AND IdStatus = 3;
				END

				INSERT INTO [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser]) VALUES (@IdTransfer,3,GETDATE(),GETDATE(),@IdUserSystem);

				EXEC st_SaveChangesToTransferLog @IdTransfer,3,'Signature Hold',0; -- Log , se ha detenido en signature hold  
			END 
			----------------------------------------------------------------------------------------------------------


			-------------------------- Agent Verification-------------------------------------------------------------
				--Exec st_SaveChangesToTransferLog @IdTransfer,5,'AR Validation',0 --- Log de validacion  
				--Select @IdAgentStatus=IdAgentStatus from Agent where IdAgent=@IdAgent  
				--If (@IdAgentStatus=4) or (@IdAgentStatus=3) or (@IdAgentStatus=5) or (@IdAgentStatus=7)
				--	Begin  
				--		Insert Into [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser])  
				--		Values(@IdTransfer,6,GETDATE(),GETDATE() ,@IdUserSystem)  
				--		Exec st_SaveChangesToTransferLog @IdTransfer,6,'AR Hold',0 -- Log , se ha detenido en AR hold  
				--	End
			----------------------------------------------------------------------------------------------------------

			---------------------------------- KYC Verification --------------------------------------------------------------------------  
			EXEC st_SaveChangesToTransferLog @IdTransfer,8,'KYC Validation',0; --- Log de KYC validacion
				
			IF EXISTS (SELECT 1 FROM dbo.BrokenRulesByTransfer WITH (NOLOCK) WHERE IdTransfer = @IdTransfer AND IsDenyList = 0) --AND ([dbo].[fun_GetIfInsertKycBasedOnRequestId](@IdTransfer) = 1)  
			BEGIN     
				DECLARE @isHolded AS bit, @infoMessage AS NVARCHAR(255);
  
				SELECT @isHolded = isHolded, @infoMessage = infoMeesage  
				FROM [dbo].[fun_GetIfInsertKycBasedOnRequestId](@IdTransfer);
  
				--Insert log  
				EXEC st_SaveChangesToTransferLog @IdTransfer, 8, @infoMessage,0;

				IF (@isHolded = 1)  
				BEGIN       
					INSERT INTO [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser]) VALUES (@IdTransfer,9,GETDATE(),GETDATE(),@IdUserSystem);

					EXEC st_SaveChangesToTransferLog @IdTransfer,9,'KYC Hold',0; -- Log , se ha detenido en KYC Hold hold  
				END     
			END  
			---------------------------------------------------------------------------------------------------------------------------
			
			-------------------------------------------------- DenyList Verification --------------------------------------------------
			EXEC st_SaveChangesToTransferLog @IdTransfer,11,'Deny List Verification',0; --- Log de DenyList validacion  

			IF EXISTS (SELECT 1 FROM dbo.BrokenRulesByTransfer WITH (NOLOCK) WHERE IdTransfer = @IdTransfer AND IsDenyList = 1)  
			BEGIN  
				INSERT INTO [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser]) VALUES (@IdTransfer,12,GETDATE(),GETDATE(),@IdUserSystem);

				EXEC st_SaveChangesToTransferLog @IdTransfer,12,'Deny List Hold',0; -- Log , se ha detenido en DenyList Hold hold  
			END
			--------------------------------------------------------------------------------------------------------------------------
			
			--------------------------------------------------- OFAC validation ------------------------------------------------------
			EXEC st_SaveChangesToTransferLog @IdTransfer,14,'OFAC Verification',0; --- Log de OFAC validacion  
          
			--Select @OFAC=( dbo.fun_OfacSearch (@CustomerName,@CustomerFirstLastName,@CustomerSecondLastName))+( dbo.fun_OfacSearch (@BeneficiaryName,@BeneficiaryFirstLastName,@BeneficiarySecondLastName))  
			--IF EXISTS (select top 1 1 from [dbo].[TransferOFACInfo] where idtransfer=@IdTransfer)
			IF EXISTS (SELECT 1 FROM [dbo].[TransferOFACInfo] WITH (NOLOCK) WHERE idtransfer = @IdTransfer)
			BEGIN
				DELETE FROM [dbo].[TransferOFACInfo] WHERE idtransfer = @IdTransfer;
			END

			DECLARE @PercentMatchOfac float; /*S09:Requerimiento_013017-2*/ 

			--Cambios para ofac transfer detail
			EXEC [dbo].[st_SaveTransferOFACInfo]
				@IdTransfer = @IdTransfer,		        
				@CustomerName = @CustomerName,
				@CustomerFirstLastName = @CustomerFirstLastName,
				@CustomerSecondLastName = @CustomerSecondLastName,		        
				@BeneficiaryName = @BeneficiaryName,
				@BeneficiaryFirstLastName = @BeneficiaryFirstLastName,
				@BeneficiarySecondLastName = @BeneficiarySecondLastName,
				@IsOLDTransfer = 0,
				@IsOFAC =  @IsOFAC out,
				@IsOFACDoubleVerification =  @IsOFACDoubleVerification out          
				,@PercentMatchOfac = @PercentMatchOfac out /*Requerimiento_013017-2*/ 

			/*Requerimiento_013017-2: Amount without Fee*/
			DECLARE @OFACHold bit = 0;

			DECLARE @AmountDlls MONEY = 0;
			SET @AmountDlls = ISNULL((SELECT TOP 1 AmountInDollars FROM dbo.[Transfer] WITH(NOLOCK) WHERE IdTransfer = @IdTransfer),0);
			--insert into TestOfacLog 
			--select @IdTransfer, @PercentMatchOfac, getdate()

			IF ((@AmountDlls < 200) AND (@PercentMatchOfac < 95))
			BEGIN			
				SET @OFACHold = 1;
			END

			/**/

			IF(@OFACHold = 0)/*S09:Requerimiento_013017-2*/
			BEGIN

				--If @OFAC<>0  
				IF (@IsOFAC = 1)
				BEGIN  
					INSERT INTO [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser]) VALUES (@IdTransfer,15,GETDATE(),GETDATE(),@IdUserSystem);

					EXEC st_SaveChangesToTransferLog @IdTransfer,15,'OFAC Hold',0; -- Log , se ha detenido en OFAC Hold  
           
					--Cambio para doble verificacion
					IF (@IsOFACDoubleVerification=1)
					BEGIN
						INSERT INTO [dbo].[TransferHolds]([IdTransfer],[IdStatus],[DateOfValidation],[DateOfLastChange],[EnterByIdUser]) VALUES (@IdTransfer,15,GETDATE(),GETDATE(),@IdUserSystem);

						EXEC st_SaveChangesToTransferLog @IdTransfer,15,'OFAC Hold',0; -- Log , se ha detenido en OFAC Hold  
					END
				END    
			END/*S09*/
		END
			--------------------------------------------------------------------------------------------------------------------------------
		EXEC st_SaveChangesToTransferLog @IdTransfer,41,'Verify Hold',0; --- Log de validación de Multiholds  
		
		UPDATE dbo.[Transfer] SET IdStatus = 41,DateStatusChange = GETDATE() WHERE IdTransfer = @IdTransfer;

			----------------------- S26:Notificaciones Automaticas Transferencias KYC Hold -------------------------------------------------
		EXEC [dbo].[st_CreateComplianceNotificationCustomerRequestId] @IdTransfer;

		INSERT INTO dbo.SBReceiveUpdateMessageLog (ConversationID,MessageXML,[IdTransfer]) VALUES (@conversation,@msg,@IdTransfer);
    END
     
END CONVERSATION @conversation;

END TRY

BEGIN CATCH
	DECLARE @ErrorMessage nvarchar(max);
	SELECT @ErrorMessage=ERROR_MESSAGE();
	INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('sp_UpdateMessageReader',GETDATE(),@ErrorMessage);
END CATCH
