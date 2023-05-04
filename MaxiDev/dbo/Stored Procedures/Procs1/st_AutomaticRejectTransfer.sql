-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-11-23
-- Description:	Automátic transfer reject
-- =============================================
CREATE PROCEDURE [dbo].[st_AutomaticRejectTransfer]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @TimeForAutomaticReject INT = (SELECT CONVERT(INT,[Value]) FROM [dbo].[GlobalAttributes] WHERE [Name] = 'TimeForAutomaticReject')
	--DECLARE @MaxTimeForAutomaticReject INT = (SELECT CONVERT(INT,[Value]) FROM [dbo].[GlobalAttributes] WHERE [Name] = 'MaxTimeForAutomaticReject')
	DECLARE @NewLine NVARCHAR(MAX) = CHAR(13)+CHAR(10)
	DECLARE @JobName NVARCHAR(MAX) = 'Maxi_AutomaticReject'

	-- Get transactions with KYC Hold
	SELECT 
		T.[IdTransfer]
		, T.[Folio]
		, T.[DateOfTransfer]
		, TH.[IdTransferHold]
		, TH.[IdStatus]
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
		AND TH.[IdStatus] = 9 -- KYC Hold
		AND TH.[IsReleased] IS NULL
		AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) >= @TimeForAutomaticReject
		--AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) <= @MaxTimeForAutomaticReject
		AND T.[EmailByJobSent] = 1 -- Notification has been sent by job

	-- Get transactions with Deny List Hold and not int KYC Hold
	INSERT INTO #TransfersTemp
		SELECT
			T.[IdTransfer]
			, T.[Folio]
			, T.[DateOfTransfer]
			, TH.[IdTransferHold]
			, TH.[IdStatus]
			, LTRIM(ISNULL(T.[CustomerName],'') + ' ' + ISNULL(T.[CustomerFirstLastName], '') + ' ' + ISNULL(T.[CustomerSecondLastName],'')) CustomerName
			, A.[AgentCode]
			, S.[Email]
		FROM [dbo].[Transfer] T WITH (NOLOCK)
		JOIN [dbo].[TransferHolds] TH WITH (NOLOCK) ON T.[IdTransfer] = TH.[IdTransfer]
		JOIN [dbo].[Agent] A WITH (NOLOCK) ON T.[IdAgent] = A.[IdAgent]
		LEFT JOIN [dbo].[Seller] S WITH (NOLOCK) ON A.[IdUserSeller] = S.[IdUserSeller]
		WHERE
			T.[IdStatus] = 41
			AND TH.[IdStatus] = 12 -- Deny List Hold
			AND TH.[IsReleased] IS NULL
			AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) >= @TimeForAutomaticReject
			--AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) <= @MaxTimeForAutomaticReject
			AND T.[EmailByJobSent] = 1 -- Notification has been sent by job
			AND T.[IdTransfer] NOT IN
				(SELECT T2.[IdTransfer] FROM #TransfersTemp T2 WITH (NOLOCK))

		INSERT INTO #TransfersTemp
		SELECT
			T.[IdTransfer]
			, T.[Folio]
			, T.[DateOfTransfer]
			, TH.[IdTransferHold]
			, TH.[IdStatus]
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
			AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) >= @TimeForAutomaticReject
			--AND (DATEDIFF(ss, T.[DateOfTransfer], GETDATE())/3600) <= @MaxTimeForAutomaticReject
			AND T.[EmailByJobSent] = 1 -- Notification has been sent by job
			AND T.[IdTransfer] NOT IN (SELECT T2.[IdTransfer] FROM #TransfersTemp T2 WITH (NOLOCK))
			AND (SELECT COUNT(IdTransfer) FROM TransferHolds WITH(NOLOCK) WHERE IdTransfer = T.IdTransfer AND IdStatus = 15 AND IsReleased IS NULL) <= 0


	DECLARE
		@TransferId INT
		, @Folio INT
		, @DateOfTransfer DATETIME
		, @TransferHoldId INT
		, @StatusId INT
		, @CustomerName NVARCHAR(MAX)
		, @AgentCode NVARCHAR(MAX)
		, @SellerEmail NVARCHAR(MAX)

		, @EnteredByUserId INT = 37 -- System
		, @SubjectMessage NVARCHAR(MAX)
		, @BodyMessage NVARCHAR(MAX)
		, @EnglishMessage NVARCHAR(MAX)
		, @SpanishMessage NVARCHAR(MAX)
		, @Note NVARCHAR(MAX)
		, @RawMessage NVARCHAR(MAX)
		, @TransferDetail XML -- This is a output parameter for send agent notification
		, @HasError BIT -- This is a output parameter for send agent notification
		, @MessageOut NVARCHAR(MAX) -- This is a output parameter for send agent notification
		, @RejectedNote NVARCHAR(MAX) = 'This transaction was rejected because the information requested was not received on time'

	SELECT TOP 1
		@TransferId = T.[IdTransfer]
		, @Folio = T.[Folio]
		, @DateOfTransfer = T.[DateOfTransfer]
		, @TransferHoldId = T.[IdTransferHold]
		, @StatusId = T.[IdStatus]
		, @CustomerName = T.[CustomerName]
		, @AgentCode = T.[AgentCode]
		, @SellerEmail = T.[Email]
	FROM #TransfersTemp T

	WHILE @TransferId IS NOT NULL
	BEGIN TRY
		
		EXEC [dbo].[st_UpdateVerifyHold] -- Reject transaction
				@EnterByIdUser = @EnteredByUserId,
				@IsSpanishLanguage = 0,
				@IdTransfer = @TransferId,
				@Note = @RejectedNote,
				@StatusHold = @StatusId,
				@IsReleased = 0,
				@HasError = @HasError OUTPUT,
				@Message = @MessageOut OUTPUT,
				@IdTransferHold = @TransferHoldId

		IF @HasError = 1
		BEGIN
			EXEC [dbo].[st_InsertJobLog] @JobName = @JobName, @ReferenceId = @TransferId, @Message = 'Error trying reject transfer', @HasError = 1
			CONTINUE
		END

		SET @SubjectMessage = 'Folio ' + CONVERT(NVARCHAR(MAX), @Folio) + ' from agent ' + @AgentCode + ' was rejected'

		SET @EnglishMessage = 'Folio ' + CONVERT(NVARCHAR(MAX), @Folio) + ' was rejected because the information requested was not received on time.'
		SET @SpanishMessage = 'Folio ' + CONVERT(NVARCHAR(MAX), @Folio) + ' fue rechazado debido a que la información solicitada no fue recibida a tiempo.'

		SET @BodyMessage = @EnglishMessage + @NewLine + @SpanishMessage

		--ddg
		DECLARE @Environment NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName]('Enviroment')

		
		IF @Environment != 'Production'
		SET @SellerEmail = [dbo].[GetGlobalAttributeByName]('ListEmailErrors')

		IF LTRIM(ISNULL(@SellerEmail,'')) != ''
			EXEC [MoneyAlert].[MailByTelephoneServiceProvider] @SellerEmail, @SubjectMessage, @BodyMessage -- Send mail to seller representative

		--SET @RawMessage = LTRIM(
		--	'{"IdTransfer":' + CONVERT(NVARCHAR(MAX), @TransferId) + ', "IdMessageSource":1, "IsIntrusive":true, "Message":"", "CanClose":true, '
		--	+ '"MessageUs": "' + @EnglishMessage + '",'
		--	+ '"MessageES":"' + @SpanishMessage + '",'
		--	+ '"IsReleased":false, "EnteredByIdUser":' + CONVERT(NVARCHAR(MAX), @EnteredByUserId) + ', "Folio":"'+ CONVERT(NVARCHAR(MAX), @Folio)
		--	+ '", "CustomerName":"' + @CustomerName + '","DateOfTransfer":"' + CONVERT(NVARCHAR(MAX), @DateOfTransfer)+'"}')

		SET @RawMessage = LTRIM(
			'{"IdMessageSource":1, "IsIntrusive":true, "Message": "' + @SpanishMessage + '\n\n'
			+ @EnglishMessage + '", "CanClose":true}')

		EXEC [dbo].[st_IntrusiveNotificationOrFax]
					@IdTransfer = @TransferId,
					@IdUser = @EnteredByUserId,
					@Note = @RejectedNote,
					@RawMessage = @RawMessage,
					@IsSpanishLanguage = 0,
					@HasError = @HasError OUTPUT,
					@MessageOut = @MessageOut OUTPUT,
					@NoteHTML = NULL

		EXEC [dbo].[st_InsertJobLog] @JobName = @JobName, @ReferenceId = @TransferId, @Message = 'Transfer was rejected', @HasError = 0

		DELETE FROM #TransfersTemp WHERE [IdTransfer] = @TransferId -- Delete from temp table the record processed

		SET @TransferId = NULL -- Cleaning variable

		SELECT TOP 1
			@TransferId = T.[IdTransfer]
			, @Folio = T.[Folio]
			, @DateOfTransfer = T.[DateOfTransfer]
			, @TransferHoldId = T.[IdTransferHold]
			, @StatusId = T.[IdStatus]
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

		SET @TransferId = NULL -- Cleaning variable

		SELECT TOP 1
			@TransferId = T.[IdTransfer]
			, @Folio = T.[Folio]
			, @DateOfTransfer = T.[DateOfTransfer]
			, @TransferHoldId = T.[IdTransferHold]
			, @StatusId = T.[IdStatus]
			, @CustomerName = T.[CustomerName]
			, @AgentCode = T.[AgentCode]
			, @SellerEmail = T.[Email]
		FROM #TransfersTemp T

	END CATCH

END TRY
BEGIN CATCH
	DECLARE @ErrorLine INT
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorLine = ERROR_LINE()
	 SELECT @ErrorMessage = ERROR_MESSAGE() + ' Line: ' + ISNULL(CONVERT(NVARCHAR(MAX),@ErrorLine),' --NULL--')
	 INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage])
		VALUES (ERROR_PROCEDURE(),GETDATE(),@ErrorMessage)
END CATCH
