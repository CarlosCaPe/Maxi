CREATE PROCEDURE st_DeleteContactEmail
(
	@IdContactEmail	INT
)
AS
BEGIN
	DELETE FROM ContactEmail WHERE IdContactEmail = @IdContactEmail
END
