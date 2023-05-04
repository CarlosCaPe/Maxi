CREATE PROCEDURE st_CancelUnpaidTransfers
AS
BEGIN
	DECLARE @TransferToCancel		TABLE(IdTransfer INT)
	DECLARE @StandByPendingPayment	INT,
			@IdUserSystem			INT,
			@IdReasonForCancel		INT,
			@CancelationNote		VARCHAR(500)
	
	SET @StandByPendingPayment = TRY_CAST(dbo.GetGlobalAttributeByName('StandByPendingPayment') AS INT)
	IF @StandByPendingPayment = 0
		SET @StandByPendingPayment = 30

	SET @IdUserSystem = TRY_CAST(dbo.GetGlobalAttributeByName('SystemUserID') AS INT)
		IF @IdUserSystem = 0
		SET @IdUserSystem = 37

	SET @IdReasonForCancel = TRY_CAST(dbo.GetGlobalAttributeByName('TDD_Modify_IdReasonForCancel') AS INT)
	SET @CancelationNote = dbo.GetGlobalAttributeByName('TDD_Modify_CancellationNote')

	INSERT INTO @TransferToCancel(IdTransfer)
	SELECT
		t.IdTransfer
	FROM Transfer t WITH(NOLOCK)
		JOIN TransferDetail td WITH(NOLOCK) ON td.IdTransfer = t.IdTransfer
	WHERE 
		t.IdStatus = 1
		AND td.IdStatus = 73
		AND DATEDIFF(MINUTE, t.DateOfTransfer, GETDATE()) > @StandByPendingPayment

	DECLARE @IdTransferCurrent		INT,
			@HasError				BIT,
			@Message				VARCHAR(MAX)
	WHILE EXISTS(SELECT 1 FROM @TransferToCancel)
	BEGIN
		SELECT 
			@IdTransferCurrent = IdTransfer
		FROM @TransferToCancel

		EXEC st_TransferToCancelInProgress @IdUserSystem, 1, @IdTransferCurrent, @CancelationNote, @IdReasonForCancel, @HasError OUT, @Message OUT

		DELETE FROM @TransferToCancel WHERE IdTransfer = @IdTransferCurrent
	END
END
