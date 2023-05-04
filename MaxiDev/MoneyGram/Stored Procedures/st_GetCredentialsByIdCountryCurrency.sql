CREATE PROCEDURE MoneyGram.st_GetCredentialsByIdCountryCurrency
(
	@IdCountryCurrency	INT
)
AS
BEGIN
	DECLARE @TargetCurrencyCode VARCHAR(20)

	SELECT
		@TargetCurrencyCode = c.CurrencyCode
	FROM dbo.CountryCurrency cc
		JOIN dbo.Currency c ON c.IdCurrency = cc.IdCurrency
	WHERE cc.IdCountryCurrency = @IdCountryCurrency

	SELECT TOP 1
		c.*
	FROM MoneyGram.Credentials c
	WHERE ISNULL(c.CurrencyCode, '') = ISNULL(@TargetCurrencyCode, '')
		OR c.CurrencyCode IS NULL
	ORDER BY
		CASE WHEN c.CurrencyCode IS NULL THEN 1 ELSE 0 END

	SELECT	
		'' ConfigKey, 
		'' ConfigValue
END
