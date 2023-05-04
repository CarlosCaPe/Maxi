CREATE PROCEDURE st_NSUpdateProcessJob
(
	@IdProcessJob		INT,
	@Status				NVARCHAR(50),
	@Response			XML
)
AS
BEGIN
	UPDATE NSProcessJob SET
		Status = @Status,
		Response = @Response,
		LastUpdate =  GETDATE()
	WHERE IdProcessJob = @IdProcessJob
END


