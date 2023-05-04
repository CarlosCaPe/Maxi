CREATE PROCEDURE st_CancelTransfer
(
	@IdTransfer		BIGINT,
	@ErrorMessage	VARCHAR(MAX)
)
AS
BEGIN
BEGIN TRANSACTION
	DECLARE @MSG_ERROR NVARCHAR(500)
	
	BEGIN TRY
		UPDATE Transfer SET
			IdStatus = 22,
			DateStatusChange = GETDATE()
		WHERE IdTransfer = @IdTransfer

		EXEC st_CancelCreditToAgentBalanceTotalAmount  @IdTransfer
		EXEC st_SaveChangesToTransferLog @IdTransfer, 22, @ErrorMessage, 0

		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		RAISERROR(@MSG_ERROR, 16, 1);
	END CATCH
END