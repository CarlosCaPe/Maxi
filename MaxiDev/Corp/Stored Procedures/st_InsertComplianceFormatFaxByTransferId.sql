CREATE PROCEDURE [Corp].[st_InsertComplianceFormatFaxByTransferId]
	-- Add the parameters for the stored procedure here
	@TransferId INT,
	@EnteredByUserId INT,
	@IdLenguage INT,
	@SendPcNotification BIT = 0,
	@HasError BIT OUTPUT,
	@ResultMessage NVARCHAR(MAX) OUTPUT
AS
/********************************************************************
<Author> Francisco Lara </Author>
<app></app>
<date>2015-08-25</date>
<Description>Insert Fax for each compliance format broken rule by transfer id</Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="16/01/2020" Author="adominguez">Compliance format does not apply for closed transfers #1</log>
</ChangeLog>
*********************************************************************/


BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	IF EXISTS (SELECT 1 FROM [dbo].[Transfer] with(nolock) WHERE [IdTransfer]=@TransferId) --#1
	BEGIN

	IF @SendPcNotification IS NULL SET @SendPcNotification = 0

	--IF EXISTS (SELECT 1 FROM [dbo].[TransferClosed] with(nolock) WHERE [IdTransferClosed]=@TransferId) -- Se omite este paso --#1
	--	EXEC [dbo].[st_MoveBackTransfer] @TransferId;

	DECLARE @QRHelper NVARCHAR(MAX);
	SELECT @QRHelper = [dbo].[GetGlobalAttributeByName]('QRHandler');

	DECLARE @Formats NVARCHAR(MAX);

	SELECT @Formats = COALESCE(@Formats + ', ', '') + (M.[FileOfName])
	FROM (
		SELECT DISTINCT CF.[FileOfName]
		FROM [dbo].[BrokenRulesByTransfer] BRT with(NOLOCK)
		JOIN [dbo].[ComplianceFormat] CF with(NOLOCK) ON BRT.[ComplianceFormatId] = CF.[ComplianceFormatId]
		WHERE BRT.[IdTransfer] = @TransferId
	) M
	
	DECLARE @Parameters NVARCHAR(MAX) = 
		'<Parameters>
			<Parameter name="IdTransfer" value="' + CONVERT(NVARCHAR(MAX),@TransferId) + '" />
			<Parameter name="QRComplianceFormat" value="' + @QRHelper + '?id=F' + CONVERT(NVARCHAR(MAX),@TransferId) + '" />
			<Parameter name="ComplianceFormatName" value="' + ISNULL(@Formats,'') + '" />
		</Parameters>'

	INSERT INTO [dbo].[QueueFaxes]
           (IdAgent
		   ,[Parameters]
           ,[ReportName]
           ,[Priority]
           ,IdQueueFaxStatus
           ,EnterByIdUser
           )
           SELECT DISTINCT
				T.[IdAgent]
				,@Parameters [Parameters]
				,'ComplianceReports' Report
				,2 [Priority] -- Medium priority
				,1 [IdQueueFaxStatus]
				,@EnteredByUserId [EnteredByUserId]
			FROM [dbo].[Transfer] T with(NOLOCK)
			WHERE T.[IdTransfer] = @TransferId;
           

	SET @HasError =0;
    SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE46');

	IF @SendPcNotification = 0
		RETURN

	/* Compliance Notification

	DECLARE @AgentCode NVARCHAR(MAX),
			@AgentName NVARCHAR(MAX),
			@Folio NVARCHAR(MAX),
			@ClaimCode NVARCHAR(MAX),
			@DateOfTransfer NVARCHAR(MAX),
			@CustomerName NVARCHAR(MAX),
			@TransferDetail XML
			
	DECLARE @Formats NVARCHAR(MAX)

	SELECT DISTINCT @Formats = COALESCE(@Formats + ', ', '') + ('"' + CF.[DisplayName] + '"')
	FROM [dbo].[BrokenRulesByTransfer] BRT (NOLOCK)
	JOIN [dbo].[ComplianceFormat] CF (NOLOCK) ON BRT.[ComplianceFormatId] = CF.[ComplianceFormatId]
	WHERE BRT.[IdTransfer] = @TransferId

	SELECT
		@AgentCode = A.[AgentCode]
		,@AgentName = A.[AgentName]
		,@Folio = T.[Folio]
		,@ClaimCode = T.[ClaimCode]
		,@DateOfTransfer = T.[DateOfTransfer]
		,@CustomerName = [dbo].[funGetFullName](T.[CustomerName],T.[CustomerFirstLastName],T.[CustomerSecondLastName], 1)
	FROM [dbo].[Transfer] T (NOLOCK)
	JOIN [dbo].[Agent] A (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
	WHERE T.[IdTransfer] = @TransferId

	IF @@ROWCOUNT = 0
		SELECT
			@AgentCode = A.[AgentCode]
			,@AgentName = A.[AgentName]
			,@Folio = T.[Folio]
			,@ClaimCode = T.[ClaimCode]
			,@DateOfTransfer = T.[DateOfTransfer]
			,@CustomerName = [dbo].[funGetFullName](T.[CustomerName],T.[CustomerFirstLastName],T.[CustomerSecondLastName], 1)
		FROM [dbo].[TransferClosed] T (NOLOCK)
		JOIN [dbo].[Agent] A (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
		WHERE T.[IdTransferClosed] = @TransferId

	DECLARE @Raw NVARCHAR(MAX) = LTRIM(
		'{"IdTransfer":' + CONVERT(NVARCHAR(MAX),@TransferId)
		+ ',"AgentCode":"' + @AgentCode + '"'
		+ ',"AgentName":"' + @AgentName + '"'
		+ ',"Folio":"' + @Folio + '"'
		+ ',"ClaimCode":"' + @ClaimCode + '"'
		+ ',"DateOfTransfer":"' + @DateOfTransfer + '"'
		+ ',"CustomerName":"' + @CustomerName + '"'
		+ ',"Note":"Se ha recibido formato de cumplimiento para transacci�n folio ' + @Folio + '"'
		+',"Requirements":[' + ISNULL(@Formats,'') + ']}')

	EXEC [dbo].[st_CreateComplianceNotification]
		@TransferId, 
		@EnteredByUserId, 
		'Compliance Format Notification', -- Note
		NULL, -- NoteHTML
		@Raw,
		0, -- IsSpanishLanguage
		1, -- OnlyAgentPcNotification
		@TransferDetail OUTPUT, 
		@HasError OUTPUT, 
		@ResultMessage OUTPUT

	*/

	-- INTRUSIVE NOTIFICATION

	DECLARE @AgentId INT
			,@Folio NVARCHAR(MAX)
			,@Raw NVARCHAR(MAX)
			,@MessageId INT
			,@Msg NVARCHAR(MAX)

	SELECT 
		@AgentId = A.[IdAgent]
		,@Folio = T.[Folio]
	FROM [dbo].[Transfer] T with(NOLOCK)
	JOIN [dbo].[Agent] A with(NOLOCK) ON T.[IdAgent] = A.[IdAgent]
	WHERE T.[IdTransfer] = @TransferId

	IF @@ROWCOUNT = 0
		SELECT @AgentId = A.[IdAgent]
		FROM [dbo].[TransferClosed] T with(NOLOCK)
		JOIN [dbo].[Agent] A with(NOLOCK) ON T.[IdAgent] = A.[IdAgent]
		WHERE T.[IdTransferClosed] = @TransferId
	
	IF NOT EXISTS (SELECT 1 FROM [dbo].[Agent] with(nolock) WHERE [IdAgentCommunication] IN (1,4) AND [IdAgent] = @AgentId)
		RETURN

	SET @Raw = LTRIM(
	'{"IdMessageSource":1, "IsIntrusive":true, "Message": "Se le ha enviado por fax el formato de cumplimiento para el folio ' 
	+ ISNULL(@Folio,'Error') + ', por favor llene lo que haga falta y env�ela firmada por el cliente al (866) 367-6295\n\n'
	+ 'A compliance form has been faxed to you regarding folio ' + ISNULL(@Folio,'Error') + ', please fill it out and have the customer sign it. Send it back to (866) 367-6295", "CanClose":true}')

	EXEC @MessageId = [Corp].[st_CreateMessageForAgent]
	        @AgentId,
	        5, -- Message Provider Id
	        @EnteredByUserId,
	        @Raw,
	        0, -- Is Spanish Language
	        @HasError OUTPUT,
	        @Msg OUTPUT;

	IF @HasError = 1
	BEGIN
		SET @HasError = @Msg
		RETURN
	END

	-- Get current Transfer Detail
	DECLARE @TransferDetailId INT
			--,@TransferNoteId INT


	Select @TransferDetailId = dbo.fun_GetIdTransferDetail(@TransferId)

	INSERT INTO [dbo].[TransferNote] VALUES (@TransferDetailId, 3, @EnteredByUserId, 'Compliance Format Notification', GETDATE());
	--SET @TransferNoteId = @@IDENTITY

	--INSERT INTO [dbo].[TransferNoteNotification] VALUES (@TransferNoteId, @MessageId, 1)
	END
ELSE
BEGIN
INSERT INTO [dbo].[ErrorLogForStoreProcedure] (StoreProcedure,ErrorDate,ErrorMessage)VALUES('[Corp].[st_InsertComplianceFormatFaxByTransferId]',GETDATE(),'La tranferencia no esta en tabla Transfer, Idtransfer =' + cast(@TransferId as varchar(20))); -- #1
		SET @HasError = 1
		SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE47')	
		return
END
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)         
	SELECT @ErrorMessage=ERROR_MESSAGE()        
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] (StoreProcedure,ErrorDate,ErrorMessage)VALUES('[Corp].[st_InsertComplianceFormatFaxByTransferId]',GETDATE(),@ErrorMessage) ;
    SET @HasError =1
    SELECT @ResultMessage=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE47')	
END CATCH

