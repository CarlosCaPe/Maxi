CREATE PROCEDURE MoneyGram.st_GetMappedCountry
(
	@IdCountry		INT
)
AS
BEGIN
	SELECT
		mgc.*
	FROM dbo.Country mc
		JOIN MoneyGram.Country mgc ON mgc.CountryCode = mc.CountryCode
	WHERE mc.IdCountry = @IdCountry
END