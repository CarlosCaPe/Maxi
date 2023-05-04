CREATE PROCEDURE st_GetLenguageResource
(
	@MessageKey	NVARCHAR(150),
	@IdLanguage	INT
)
AS
BEGIN
	SELECT 
		lr.Message
	FROM LenguageResource lr WITH(NOLOCK)
	WHERE 
		lr.IdLenguage = @IdLanguage
		AND lr.MessageKey = @MessageKey
END