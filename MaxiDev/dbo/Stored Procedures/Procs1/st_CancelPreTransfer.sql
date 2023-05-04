CREATE PROCEDURE st_CancelPreTransfer
(
	@IdPreTransfer	BIGINT
)
AS
BEGIN
	UPDATE PreTransfer SET
		Status = 1
	WHERE IdPreTransfer = @IdPreTransfer
END