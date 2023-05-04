-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-11-19
-- Description:	Send Agent and mail notification for transfer to will be reject by system
-- =============================================
CREATE PROCEDURE [dbo].[st_AgentSellerNotificationForReject]
	-- Add the parameters for the stored procedure here

AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @TimeForSendRejectMail INT = (SELECT CONVERT(INT,[Value]) FROM [dbo].[GlobalAttributes] WHERE [Name] = 'TimeForSendRejectMail')
	DECLARE @MaxTimeForAutomaticReject INT = (SELECT CONVERT(INT,[Value]) FROM [dbo].[GlobalAttributes] WHERE [Name] = 'MaxTimeForAutomaticReject')
	DECLARE @NewLine NVARCHAR(MAX) = CHAR(13) + CHAR(10)
	DECLARE @JobName NVARCHAR(MAX) = 'Maxi_AutomaticReject'

	SELECT
		DISTINCT -- For transactions with 2 or more holds
		T.[IdTransfer]
		, T.[Folio]
		, T.[DateOfTransfer]
		, LTRIM(ISNULL(T.[CustomerName],'') + ' ' + ISNULL(T.[CustomerFirstLastName], '') + ' ' + ISNULL(T.[CustomerSecondLastName],'')) CustomerName
		, A.[AgentCode]
		, S.[Email]
	INTO #TransfersTemp
	FROM [dbo].[Transfer] T WITH (NOLOCK)
	JOIN [dbo].[TransferHolds] TH WITH (NOLOCK) ON T.[IdTransfer] = TH.[IdTransfer]
	JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
	LEFT JOIN [dbo].[Seller] S WITH (NOLOCK) ON A.[IdUserSeller] = S.[IdUserSeller]
	WHERE
		T.[IdStatus] = 41
		AND T.[IdTransfer] NOT IN (SELECT TH2.[IdTransfer] FROM [dbo].[TransferHolds] TH2 WITH (NOLOCK) WHERE [IdStatus] = 15 AND [IsReleased] IS NULL) -- Not has OFAC hold unreleased
		AND TH.[IdStatus] IN (9, 12) -- (KYC Hold, Deny List Hold)
		AND TH.[IsReleased] IS NULL
		AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) >= @TimeForSendRejectMail
		AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) <= @MaxTimeForAutomaticReject
		AND T.[EmailByJobSent] = 0 -- Notification has not been sent by job

		INSERT INTO #TransfersTemp
		SELECT
			T.[IdTransfer]
			, T.[Folio]
			, T.[DateOfTransfer]
			, LTRIM(ISNULL(T.[CustomerName],'') + ' ' + ISNULL(T.[CustomerFirstLastName], '') + ' ' + ISNULL(T.[CustomerSecondLastName],'')) CustomerName
			, A.[AgentCode]
			, S.[Email]
		FROM [dbo].[Transfer] T WITH (NOLOCK)
		JOIN [dbo].[TransferHolds] TH WITH (NOLOCK) ON T.[IdTransfer] = TH.[IdTransfer] 
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
		LEFT JOIN [dbo].[Seller] S WITH (NOLOCK) ON A.[IdUserSeller] = S.[IdUserSeller]
		WHERE
			T.[IdStatus] = 41
			AND TH.[IdStatus] = 3 -- Signature Hold
			AND TH.[IsReleased] IS NULL
			AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) >= @TimeForSendRejectMail
			AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) <= @MaxTimeForAutomaticReject
			AND T.[IdTransfer] NOT IN (SELECT T2.[IdTransfer] FROM #TransfersTemp T2 WITH (NOLOCK))
			AND (SELECT COUNT(IdTransfer) FROM TransferHolds WITH(NOLOCK) WHERE IdTransfer = T.IdTransfer AND IdStatus = 15 AND IsReleased IS NULL) <= 0
			AND T.[EmailByJobSent] = 0 -- Notification has not been sent by job

	DECLARE
		@TransferId INT
		, @Folio INT
		, @DateOfTransfer DATETIME
		, @CustomerName NVARCHAR(MAX)
		, @AgentCode NVARCHAR(MAX)
		, @SellerEmail NVARCHAR(MAX)

		, @EnteredByUserId INT = 37 -- System
		, @SubjectMessage NVARCHAR(MAX)
		, @BodyMessage NVARCHAR(MAX)
		, @EnglishMessage NVARCHAR(MAX)
		, @SpanishMessage NVARCHAR(MAX)
		, @IdTransferDetail INT
		, @Note NVARCHAR(MAX)
		, @RawMessage NVARCHAR(MAX)
		, @TransferDetail XML -- This is a output parameter for send agent notification
		, @HasError BIT -- This is a output parameter for send agent notification
		, @MessageOut NVARCHAR(MAX) -- This is a output parameter for send agent notification

	SELECT TOP 1
		@TransferId = T.[IdTransfer]
		, @Folio = T.[Folio]
		, @DateOfTransfer = T.[DateOfTransfer]
		, @CustomerName = T.[CustomerName]
		, @AgentCode = T.[AgentCode]
		, @SellerEmail = T.[Email]
	FROM #TransfersTemp T

	WHILE @TransferId IS NOT NULL
	BEGIN TRY
		
		/**Para obtener el IdTransferDetail correspondiente al Status actual de la transferencia, no el último de TransferDetail**/
		Select @IdTransferDetail= dbo.fun_GetIdTransferDetail(@TransferId)

		-- Get the last note sent to the agent
		SELECT TOP 1
			@Note = TN.[Note]
		FROM [dbo].[TransferNote] TN WITH (NOLOCK)
		JOIN [dbo].[TransferNoteNotification] TNN WITH (NOLOCK) ON TN.[IdTransferNote] = TNN.[IdTransferNote]
		WHERE TN.[IdTransferDetail] = @IdTransferDetail
		ORDER BY TNN.[IdTransferNoteNotification] DESC

		IF @Note IS NULL SET @Note = '' ELSE SET @Note = ' (' + @Note + ').'

		SET @SubjectMessage = 'Folio ' + CONVERT(NVARCHAR(MAX), @Folio) + ' from agent ' + @AgentCode + ' will be rejected'

		SET @EnglishMessage = 'Folio ' + CONVERT(NVARCHAR(MAX), @Folio) + ' will be rejected in 24 hours ' + @Note
		SET @SpanishMessage = 'Folio ' + CONVERT(NVARCHAR(MAX), @Folio) + ' será rechazado en 24 horas ' + @Note

		SET @BodyMessage = @EnglishMessage + @NewLine + @SpanishMessage

		
		--ddg
		DECLARE @Environment NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('Enviroment')

		
		IF @Environment != 'Production'
        SET @SellerEmail = [dbo].[GetGlobalAttributeByName]('ListEmailErrors')

		IF LTRIM(ISNULL(@SellerEmail,'')) != ''
			EXEC [MoneyAlert].[MailByTelephoneServiceProvider] @SellerEmail, @SubjectMessage, @BodyMessage -- Send mail to seller representative

		SET @RawMessage = LTRIM(
			'{"IdMessageSource":1, "IsIntrusive":true, "Message": "' + @SpanishMessage + '\n\n'
			+ @EnglishMessage + '", "CanClose":true}')

		EXEC [dbo].[st_IntrusiveNotificationOrFax]
					@IdTransfer = @TransferId,
					@IdUser = @EnteredByUserId,
					@Note = @Note,
					@RawMessage = @RawMessage,
					@IsSpanishLanguage = 0,
					@HasError = @HasError OUTPUT,
					@MessageOut = @MessageOut OUTPUT,
					@NoteHTML = NULL

		IF @HasError = 0 -- If notification has not error then mark the record
		BEGIN
			UPDATE [dbo].[Transfer] SET [EmailByJobSent] = 1 WHERE [IdTransfer] = @TransferId -- Set that the notification was sent
			EXEC [dbo].[st_InsertJobLog] @JobName = @JobName, @ReferenceId = @TransferId, @Message = 'Notification send to agent', @HasError = 0
		END
		ELSE
			EXEC [dbo].[st_InsertJobLog] @JobName = @JobName, @ReferenceId = @TransferId, @Message = 'Error on st_IntrusiveNotificationOrFax', @HasError = 1

		DELETE FROM #TransfersTemp WHERE [IdTransfer] = @TransferId -- Delete from temp table the record processed

		-- Cleaning variable
		SET @TransferId = NULL
		SET @Note = NULL

		SELECT TOP 1 -- Get a new record to process
			@TransferId = T.[IdTransfer]
			, @Folio = T.[Folio]
			, @DateOfTransfer = T.[DateOfTransfer]
			, @CustomerName = T.[CustomerName]
			, @AgentCode = T.[AgentCode]
			, @SellerEmail = T.[Email]
		FROM #TransfersTemp T

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessageByRow NVARCHAR(MAX)
		SELECT @ErrorMessageByRow = 'Error with Transfer ' + ISNULL(CONVERT(NVARCHAR(MAX),@TransferId),'--NULL--') + '...' + ERROR_MESSAGE() 
		EXEC [dbo].[st_InsertJobLog] @JobName = @JobName, @ReferenceId = @TransferId, @Message = @ErrorMessageByRow, @HasError = 1

		DELETE FROM #TransfersTemp WHERE [IdTransfer] = @TransferId -- Delete from temp table the record processed

		-- Cleaning variable
		SET @TransferId = NULL
		SET @Note = NULL

		SELECT TOP 1 -- Get a new record to process
			@TransferId = T.[IdTransfer]
			, @Folio = T.[Folio]
			, @DateOfTransfer = T.[DateOfTransfer]
			, @CustomerName = T.[CustomerName]
			, @AgentCode = T.[AgentCode]
			, @SellerEmail = T.[Email]
		FROM #TransfersTemp T

	END CATCH

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE() 
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage])
	VALUES ('st_AgentSellerNotificationForReject',GETDATE(),@ErrorMessage)
END CATCH
