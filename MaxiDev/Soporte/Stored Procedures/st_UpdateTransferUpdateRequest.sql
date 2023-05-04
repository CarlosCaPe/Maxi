CREATE PROCEDURE Soporte.st_UpdateTransferUpdateRequest
(
	@IdTransferUpdateRequest	INT,
	@ReturnCode					VARCHAR(200) NULL,
	@XMLResponse				XML NULL
)
AS
BEGIN 

	UPDATE Soporte.TransferUpdateRequest SET
		RequestSent = 1,
		ReturnCode = @ReturnCode,
		XMLResponse = @XMLResponse,
		DateOfLastChange = GETDATE()
	WHERE IdTransferUpdateRequest = @IdTransferUpdateRequest

END

