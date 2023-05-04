CREATE PROCEDURE st_GetContactEmail
(
	@IdContactEntity	INT,
	@IdReference		INT
)
AS
BEGIN

	SELECT
		ce.*
	FROM ContactEmail ce 
	WHERE 
		ce.IdContactEntity = @IdContactEntity 
		AND ce.IdReference = @IdReference
	ORDER BY ce.IsPrincipal DESC
	
END