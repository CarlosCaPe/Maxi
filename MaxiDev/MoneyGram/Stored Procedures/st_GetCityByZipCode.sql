CREATE PROCEDURE MoneyGram.st_GetCityByZipCode
(
	@ZipCode		VARCHAR(10)
)
AS
BEGIN
	SELECT
		0 IdCity,
		sp.CountryCode,
		sp.StateProvinceCode,
		z.CityName,
		z.ZipCode
	FROM dbo.ZipCode z 
		JOIN MoneyGram.StateProvince sp ON sp.CountryCode = 'USA' AND sp.StateProvinceCode = z.StateCode
	WHERE z.ZipCode = @ZipCode
END