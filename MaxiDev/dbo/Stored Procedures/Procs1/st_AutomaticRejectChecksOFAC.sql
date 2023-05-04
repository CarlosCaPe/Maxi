-- =============================================
-- Author:		Dario Almeida
-- Create date: 2017-01-16
-- Description:	Automátic Check reject OFAC Hold
-- =============================================
CREATE PROCEDURE [dbo].[st_AutomaticRejectChecksOFAC]
	-- Add the parameters for the stored procedure here
	
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF NOT EXISTS(SELECT 1 FROM [dbo].[GlobalAttributes] WHERE [Name] = 'TimeForAutomaticRejectChecks')
		BEGIN
			INSERT INTO [dbo].[GlobalAttributes] SELECT 'TimeForAutomaticRejectChecks',	'168','Time in hours to Reject checks'
		END

	DECLARE @TimeForAutomaticRejectCheck INT = (SELECT CONVERT(INT,[Value]) FROM [dbo].[GlobalAttributes] WHERE [Name] = 'TimeForAutomaticRejectChecks')
	DECLARE @NewLine NVARCHAR(MAX) = CHAR(13)+CHAR(10)
	DECLARE @JobName NVARCHAR(MAX) = 'Maxi_AutomaticReject'

	-- Get checks with OFAC Hold
	SELECT 
		c.[IdCheck]
		, c.[CheckNumber]
		, c.[DateStatusChange]
		, ch.[IdCheckHold]
		, ch.[IdStatus]
		, LTRIM(ISNULL(c.[Name],'') + ' ' + ISNULL(c.[FirstLastName], '') + ' ' + ISNULL(c.[SecondLastName],'')) CustomerName
		, A.[AgentCode]
	INTO #ChecksTemp
	FROM [dbo].[Checks] c WITH (NOLOCK)
	JOIN [dbo].[CheckHolds] ch WITH (NOLOCK) ON c.[IdCheck] = ch.[IdCheck]
	JOIN [dbo].[Agent] A WITH (NOLOCK) ON c.[IdAgent] = A.[IdAgent]
	LEFT JOIN [dbo].[Seller] S WITH (NOLOCK) ON A.[IdUserSeller] = S.[IdUserSeller]
	WHERE
		c.[IdStatus] = 41
		AND ch.[IdStatus] = 15 -- OFAC Hold
		AND ch.[IsReleased] IS NULL
		AND (DATEDIFF(ss, c.[DateStatusChange], GETDATE())/3600) >= @TimeForAutomaticRejectCheck
		
	DECLARE
		@CheckId INT
		, @CheckNumber NVARCHAR(MAX)
		, @DateOfCheck DATETIME
		, @CheckHoldId INT
		, @StatusId INT
		, @CustomerName NVARCHAR(MAX)
		, @AgentCode NVARCHAR(MAX)
		, @EnteredByUserId INT = 37 -- System
		, @SubjectMessage NVARCHAR(MAX)
		, @BodyMessage NVARCHAR(MAX)
		, @EnglishMessage NVARCHAR(MAX)
		, @SpanishMessage NVARCHAR(MAX)
		, @Note NVARCHAR(MAX)
		, @RawMessage NVARCHAR(MAX)
		, @CheckDetail XML -- This is a output parameter for send agent notification
		, @HasError BIT -- This is a output parameter for send agent notification
		, @MessageOut NVARCHAR(MAX) -- This is a output parameter for send agent notification
		, @RejectedNote NVARCHAR(MAX) = 'This check was rejected by System Rule: ''More than 7 days in OFAC hold '' '

	SELECT TOP 1
		@CheckId = c.[IdCheck]
		, @CheckNumber = c.[CheckNumber]
		, @DateOfCheck = c.[DateStatusChange]
		, @CheckHoldId = c.[IdCheckHold]
		, @StatusId = c.[IdStatus]
		, @CustomerName = c.[CustomerName]
		, @AgentCode = c.[AgentCode]
	FROM #ChecksTemp c

	WHILE @CheckId IS NOT NULL
	BEGIN TRY
		
		EXEC [Checks].[st_CheckUpdateVerifyHold] -- Reject check
				@EnterByIdUser = @EnteredByUserId,
				@IsSpanishLanguage = 0,
				@IdCheck = @CheckId,
				@Note = @RejectedNote,
				@StatusHold = @StatusId,
				@IsReleased = 0,
				@HasError = @HasError OUTPUT,
				@Message = @MessageOut OUTPUT,
				@IdCheckHold = @CheckHoldId

		IF @HasError = 1
		BEGIN
			EXEC [dbo].[st_InsertJobLog] @JobName = @JobName, @ReferenceId = @CheckId, @Message = 'Error trying reject check', @HasError = 1
			CONTINUE
		END

		SET @SubjectMessage = 'Check  ' + @CheckNumber + ' from agent ' + @AgentCode + ' was rejected'

		SET @EnglishMessage = 'Check  ' + @CheckNumber + ' was rejected because the information requested was not received on time.'
		SET @SpanishMessage = 'Check  ' + @CheckNumber + ' fue rechazado debido a que la información solicitada no fue recibida a tiempo.'

		SET @BodyMessage = @EnglishMessage + @NewLine + @SpanishMessage

		EXEC [dbo].[st_InsertJobLog] @JobName = @JobName, @ReferenceId = @CheckId, @Message = 'Check was rejected', @HasError = 0

		DELETE FROM #ChecksTemp WHERE [IdCheck] = @CheckId -- Delete from temp table the record processed

		SET @CheckId = NULL -- Cleaning variable

		SELECT TOP 1
			@CheckId = c.[IdCheck]
			, @CheckNumber = c.[CheckNumber]
			, @DateOfCheck = c.[DateStatusChange]
			, @CheckHoldId = c.[IdCheckHold]
			, @StatusId = c.[IdStatus]
			, @CustomerName = c.[CustomerName]
			, @AgentCode = c.[AgentCode]
		FROM #ChecksTemp c

	END TRY
	BEGIN CATCH
		DECLARE @ErrorMessageByRow NVARCHAR(MAX)
		SELECT @ErrorMessageByRow = 'Error with Check ' + ISNULL(CONVERT(NVARCHAR(MAX),@CheckId),'--NULL--') + '...' + ERROR_MESSAGE() 
		EXEC [dbo].[st_InsertJobLog] @JobName = @JobName, @ReferenceId = @CheckId, @Message = @ErrorMessageByRow, @HasError = 1

		DELETE FROM #ChecksTemp WHERE [IdCheck] = @CheckId -- Delete from temp table the record processed

		SET @CheckId = NULL -- Cleaning variable

		SELECT TOP 1
			@CheckId = c.[IdCheck]
			, @CheckNumber = c.[CheckNumber]
			, @DateOfCheck = c.[DateStatusChange]
			, @CheckHoldId = c.[IdCheckHold]
			, @StatusId = c.[IdStatus]
			, @CustomerName = c.[CustomerName]
			, @AgentCode = c.[AgentCode]
		FROM #ChecksTemp c

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
