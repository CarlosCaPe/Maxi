CREATE PROCEDURE [dbo].[st_CancelCheckByIdUser]
(
    @IdCheck INT,
    @EnterByIdUser INT,
    @Note NVARCHAR(MAX),
    @IdLenguage INT,
    @HasError BIT OUT,
    @Message NVARCHAR(MAX) OUT
)
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;


BEGIN TRY

IF EXISTS (SELECT 1 FROM [dbo].[Checks] WITH (NOLOCK) WHERE [IdCheck]=@IdCheck AND [IdStatus]=20)
begin

UPDATE [dbo].[Checks] SET [IdStatus]=22, [DateOfLastChange]=GETDATE(), [DateStatusChange]=GETDATE() WHERE [IdCheck]=@IdCheck;

INSERT INTO [dbo].[CheckDetails]
			   ([IdCheck]
			   ,[IdStatus]
			   ,[DateOfMovement]
			   ,[Note]
			   ,[EnterByIdUser])
		VALUES
		(
			@IdCheck,
			22,
			GETDATE(),
			@Note,
			@EnterByIdUser
		);

	EXEC [checks].[st_CheckCancelToAgentBalance] @IdCheck, @EnterByIdUser, 0;

	-- INTRUSIVE NOTIFICATION

	DECLARE @AgentId INT
			,@Raw NVARCHAR(MAX)
			,@MessageId INT
			,@Msg NVARCHAR(MAX)

	SELECT 
		@AgentId = A.[IdAgent]
	FROM [dbo].[Checks] C WITH (NOLOCK)
	JOIN [dbo].[Agent] A WITH (NOLOCK) ON C.[IdAgent] = A.[IdAgent]
	WHERE C.[IdCheck] = @IdCheck;

	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[Agent] WITH (NOLOCK) WHERE [IdAgentCommunication] IN (1,4) AND [IdAgent] = @AgentId)
		RETURN

	declare @CustomerName varchar(1000) 
	DECLARE @IdUserCheckCreator int

	select @CustomerName=(Name + ' '+ FirstLastName + ' ' + SecondLastName), @IdUserCheckCreator=EnteredByIdUser from checks WITH (NOLOCK) where IdCheck = @IdCheck
	SET @Raw = '{"IdCheck":'+(select CONVERT(varchar(20), @IdCheck))+',"IdMessageSource":1,"IsIntrusive":true,"Message":"","CanClose":true, "MessageUs": "Check with folio ' + ISNULL(CONVERT(NVARCHAR(MAX),@IdCheck),'Error') + ' has been canceled.","MessageES":"El cheque con folio '+ ISNULL(CONVERT(NVARCHAR(MAX),@IdCheck),'Error') + ' ha sido cancelado.","IsReleased":false,"EnteredByIdUser":'+(select CONVERT(varchar(20), @IdUserCheckCreator))+',"Folio":"'+ CONVERT(varchar(20), @IdCheck)+'","CustomerName":"'+@CustomerName+'","DateOfTransfer":"'+convert(varchar(100),GETDATE())+'"}'
	
	--SET @Raw = LTRIM(
	--'{"IdMessageSource":1, "IsIntrusive":true, "Message": "El cheque con folio ' 
	--+ ISNULL(CONVERT(NVARCHAR(MAX),@IdCheck),'Error') + ' ha sido cancelado.\n\n'
	--+ 'Check with folio ' + ISNULL(CONVERT(NVARCHAR(MAX),@IdCheck),'Error') + ' has been canceled.", "CanClose":true}')

	EXEC @MessageId = [dbo].[st_CreateMessageForAgent]
	        @AgentId,
	        6, -- Message Provider Id
	        @EnterByIdUser,
	        @Raw,
	        0, -- Is Spanish Language
	        @HasError OUTPUT,
	        @Msg OUTPUT;
    
	IF @HasError = 0
	BEGIN
		SET @HasError=0                                                                                   
		SELECT @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'PTOK');
	END

	RETURN
END

Set @HasError=1                                                                                   
Select @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'MESSAGE57');  

end try
Begin Catch
    Set @HasError=1                                                                                   
    Select @Message = dbo.GetMessageFromMultiLenguajeResorces(@IdLenguage,'MESSAGE57');       
	Declare @ErrorMessage nvarchar(max) =ERROR_MESSAGE();                                             
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CancelCheckByIdUser',Getdate(),@ErrorMessage)                                                                                            
End Catch
