CREATE PROCEDURE st_AttemptOFACAutoRelease
(
    @IdTransfer     INT
)
AS
BEGIN
	-- Initialize variables
	DECLARE @IdCustomer 					INT,
		@CustomerName               	VARCHAR(200),
		@CustomerFirstLastName      	VARCHAR(200),
		@CustomerSecondLastName     	VARCHAR(200),
		@CustomerXMLMatch           	XML,
		@CustomerHasMatch				BIT,

		@IdBeneficiary					INT,
		@BeneficiaryName               	VARCHAR(200),
		@BeneficiaryFirstLastName      	VARCHAR(200),
		@BeneficiarySecondLastName     	VARCHAR(200),
		@BeneficiaryXMLMatch           	XML,
		@BeneficiaryHasMatch			BIT,
		@IdCurrentStatus				INT


    SELECT 
		@IdCustomer = t.IdCustomer,
		@CustomerName = o.CustomerName,
		@CustomerFirstLastName = o.CustomerFirstLastName,
		@CustomerSecondLastName = o.CustomerSecondLastName,
		@CustomerXMLMatch = o.CustomerMatch,
		@CustomerHasMatch = IIF(o.CustomerMatch IS NULL, 0, 1),


		@IdBeneficiary = t.IdBeneficiary,
		@BeneficiaryName = o.BeneficiaryName,
		@BeneficiaryFirstLastName = o.BeneficiaryFirstLastName,
		@BeneficiarySecondLastName = o.BeneficiarySecondLastName,
		@BeneficiaryXMLMatch = o.BeneficiaryMatch,
		@BeneficiaryHasMatch = IIF(o.BeneficiaryMatch IS NULL, 0, 1),

		@IdCurrentStatus = t.IdStatus
    FROM Transfer t WITH(NOLOCK)
		JOIN TransferOFACInfo o  WITH(NOLOCK) ON o.IdTransfer = t.IdTransfer
    WHERE t.IdTransfer = @IdTransfer

    -- Return all tranfers without OFAC hold
    IF NOT EXISTS (SELECT 1 FROM TransferHolds th  WITH(NOLOCK) WHERE th.IdTransfer = @IdTransfer AND th.IdStatus = 15 AND ISNULL(th.IsReleased, 0) = 0)
	BEGIN
        PRINT 'This transfer does not have an active OFAC hold'
		RETURN;
	END

	-- Return all transfers when double verification
	IF EXISTS (SELECT 1 FROM TransferOFACInfo o WITH(NOLOCK) WHERE o.IdTransfer = @IdTransfer AND o.IsOFACDoubleVerification = 1)
	BEGIN
		EXEC st_SaveChangesToTransferLog @IdTransfer, @IdCurrentStatus, 'This transfer require double verification, cannot be auto released', 0
        PRINT 'This transfer require double verification, cannot be auto released'
		RETURN;
	END


	DECLARE @CustomerHasPreviusRelease 		BIT,
			@CustomerIsSameResult			BIT,
			@BeneficiaryHasPreviusRelease	BIT,
			@BeneficiaryIsSameResult		BIT

	SELECT TOP 1
		@CustomerHasPreviusRelease = IIF(o.IsOFACDoubleVerification = 1, 0, IIF(o.IdUserRelease1 IS NOT NULL, 1, 0)),
		@CustomerIsSameResult = IIF((@CustomerName = o.CustomerName
			AND @CustomerFirstLastName = o.CustomerFirstLastName
			AND @CustomerSecondLastName = o.CustomerSecondLastName
			AND CAST(@CustomerXMLMatch AS VARCHAR(MAX)) = CAST(o.CustomerMatch AS VARCHAR(MAX))), 1, 0)
	FROM TransferOFACInfo o WITH(NOLOCK)
		LEFT JOIN Transfer t WITH(NOLOCK) ON t.IdTransfer = o.IdTransfer
		LEFT JOIN TransferClosed tc WITH(NOLOCK) ON tc.IdTransferClosed = o.IdTransfer
	WHERE 
		ISNULL(t.IdCustomer, tc.IdCustomer) = @IdCustomer
		AND t.IdTransfer <> @IdTransfer
	ORDER BY o.IdTransferOFACInfo DESC

	SELECT TOP 1
		@BeneficiaryHasPreviusRelease = IIF(o.IsOFACDoubleVerification = 1, 0, IIF(o.IdUserRelease1 IS NOT NULL, 1, 0)),
		@BeneficiaryIsSameResult = IIF((@BeneficiaryName = o.BeneficiaryName
			AND @BeneficiaryFirstLastName = o.BeneficiaryFirstLastName
			AND @BeneficiarySecondLastName = o.BeneficiarySecondLastName
			AND CAST(@BeneficiaryXMLMatch AS VARCHAR(MAX)) = CAST(o.BeneficiaryMatch AS VARCHAR(MAX))), 1, 0)
	FROM TransferOFACInfo o WITH(NOLOCK)
		LEFT JOIN Transfer t WITH(NOLOCK) ON t.IdTransfer = o.IdTransfer
		LEFT JOIN TransferClosed tc WITH(NOLOCK) ON tc.IdTransferClosed = o.IdTransfer
	WHERE 
		ISNULL(t.IdCustomer, tc.IdCustomer) = @IdCustomer
		AND ISNULL(t.IdBeneficiary, tc.IdBeneficiary) = @IdBeneficiary
		AND t.IdTransfer <> @IdTransfer
	ORDER BY o.IdTransferOFACInfo DESC

	DECLARE @ReleaseTransaction BIT = 0,
			@ReleaseNote		VARCHAR(300)

	IF @CustomerHasMatch = 1 AND ISNULL(@CustomerHasPreviusRelease, 0) = 1 AND ISNULL(@CustomerIsSameResult, 0) = 1
	BEGIN
		IF ISNULL(@CustomerIsSameResult, 0) = 0
		BEGIN
			SET @ReleaseTransaction = 0;
			SET @ReleaseNote = 'Customer: The latest comparison to OFAC is different from the current one'
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM EvaluationOFACAutoRelease e WHERE e.IdReference = @IdCustomer AND e.IdEvaluationEntityType = 1 AND EnableAutoRelease = 1)
		BEGIN
			SET @ReleaseTransaction = 0;
			SET @ReleaseNote = 'Customer: Has OFAC auto release disabled'
		END
		ELSE
		BEGIN
			SET @ReleaseTransaction = 1;
			SET @ReleaseNote = 'Customer: Has previous discard'
		END
	END
	
	IF @BeneficiaryHasMatch = 1 AND ISNULL(@BeneficiaryHasPreviusRelease, 0) = 1 AND ISNULL(@BeneficiaryIsSameResult, 0) = 1
	BEGIN
		IF ISNULL(@BeneficiaryIsSameResult, 0) = 0
		BEGIN
			SET @ReleaseTransaction = 0;
			SET @ReleaseNote = 'Beneficiary: The latest comparison to OFAC is different from the current one'
		END
		ELSE IF NOT EXISTS (SELECT 1 FROM EvaluationOFACAutoRelease e WHERE e.IdReference = @IdBeneficiary AND e.IdEvaluationEntityType = 2 AND EnableAutoRelease = 1)
		BEGIN
			SET @ReleaseTransaction = 0;
			SET @ReleaseNote = 'Beneficiary: Has OFAC auto release disabled'
		END
		ELSE IF @CustomerHasMatch = 0 OR @ReleaseTransaction = 1
		BEGIN
			SET @ReleaseTransaction = 1;
			IF ISNULL(@ReleaseNote, '') = ''
				SET @ReleaseNote = 'Beneficiary: Has previous discard'
			ELSE
				SET @ReleaseNote = CONCAT(@ReleaseNote, ' / ', 'Beneficiary: Has previous discard')
		END
	END

	IF ISNULL(@ReleaseTransaction, 0) = 0
	BEGIN
		SET @ReleaseNote = CONCAT('OFAC AutoRelease', CHAR(10),'This transfer cannot be released automatically, ', @ReleaseNote)

		EXEC st_SaveChangesToTransferLog @IdTransfer, @IdCurrentStatus, @ReleaseNote, 0
        PRINT @ReleaseNote
		RETURN;
	END

	SET @ReleaseNote = CONCAT('OFAC AutoRelease', CHAR(10), @ReleaseNote)

	DECLARE @IdUserRelease 		INT,
			@DateOfRelease		DATETIME,
			@IdOFACAction		INT	

	SELECT 	@IdUserRelease = CAST(dbo.GetGlobalAttributeByName('SystemUserID') AS INT),
			@DateOfRelease = GETDATE(),
			@IdOFACAction = 2

	EXEC st_SaveChangesToTransferLog @IdTransfer, 16, @ReleaseNote, 0
	
	UPDATE TransferOFACInfo SET
		IdUserRelease1 = @IdUserRelease,
		UserNoteRelease1 = @ReleaseNote,
		DateOfRelease1 = @DateOfRelease,
		IdOFACAction1 = @IdOFACAction
	WHERE IdTransfer = @IdTransfer

	UPDATE TransferHolds SET
		IsReleased = 1
	WHERE IdTransfer = @IdTransfer
	AND IdStatus = 15

	SELECT
		@ReleaseTransaction				ReleaseTransaction,
		@ReleaseNote					ReleaseNote,

		@CustomerHasMatch				CustomerHasMatch, 
		@CustomerHasPreviusRelease		CustomerHasPreviusRelease,

		@BeneficiaryHasMatch 			BeneficiaryHasMatch,
		@BeneficiaryHasPreviusRelease 	BeneficiaryHasPreviusRelease
END
