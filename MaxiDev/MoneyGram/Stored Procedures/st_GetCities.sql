CREATE PROCEDURE MoneyGram.st_GetCities
(
	@CountryCode		VARCHAR(300),
	@StateCode			VARCHAR(300)
)
AS
BEGIN
	SELECT * FROM MoneyGram.City c
	WHERE 
		c.CountryCode = @CountryCode
		AND (@StateCode IS NULL OR c.StateProvinceCode = @StateCode)
END
