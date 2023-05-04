CREATE PROCEDURE MoneyGram.st_GetCredentialsByIdPretransfer
(
	@IdPretransfer		BIGINT
)
AS
BEGIN
	DECLARE @IdCountryCurrency	INT

	SELECT
		@IdCountryCurrency = p.IdCountryCurrency
	FROM PreTransfer p
	WHERE p.IdPreTransfer = @IdPretransfer
	
	EXEC MoneyGram.st_GetCredentialsByIdCountryCurrency @IdCountryCurrency
END