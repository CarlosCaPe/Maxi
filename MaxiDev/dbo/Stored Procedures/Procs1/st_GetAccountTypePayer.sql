CREATE PROCEDURE [dbo].[st_GetAccountTypePayer]
(
	@IdPayer	INT,
	@IdLanguage INT = NULL
)
AS
BEGIN
	SELECT
		p.AccountTypePayerId,
		p.IdPayer,
		p.AccountTypeId,
		p.AccountTypeName,
		p.idLenguage IdLanguage
	FROM AccountTypePayer p
	WHERE p.IdPayer = @IdPayer
	AND (@IdLanguage IS NULL OR p.idLenguage = @IdLanguage)
END
