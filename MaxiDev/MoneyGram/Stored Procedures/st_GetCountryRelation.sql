CREATE PROCEDURE [MoneyGram].[st_GetCountryRelation]
AS
BEGIN

	SELECT
		c.IdCountry IdCountryMaxi,
		mg.*
	FROM MoneyGram.Country mg
		LEFT JOIN dbo.Country c ON c.CountryCode = mg.CountryCode
		LEFT JOIN dbo.PayerConfig pc ON pc.IdPayerConfig = mg.IdPayerConfig
	--WHERE 
		--mg.ActiveForMaxi = 1

END