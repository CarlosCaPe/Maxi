CREATE PROCEDURE MoneyGram.st_GetMappedCity
(
	@IdCity		INT
)
AS
BEGIN
	SELECT
		0 IdCity,
		msp.CountryCode,
		msp.StateProvinceCode,
		c.CityName
	FROM dbo.City c
		JOIN dbo.State s ON s.IdState = c.IdState
		JOIN dbo.Country co ON co.IdCountry = s.IdCountry

		-- MG
		JOIN MoneyGram.Country mc ON mc.CountryCode = co.CountryCode
		JOIN MoneyGram.StateProvince msp ON mc.CountryCode = msp.CountryCode AND CONCAT(mc.CountryLegacyCode, '-', msp.StateProvinceCode) = s.StateCodeISO3166_2
	WHERE c.IdCity = @IdCity
END