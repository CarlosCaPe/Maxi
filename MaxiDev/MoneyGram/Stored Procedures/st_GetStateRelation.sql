CREATE PROCEDURE MoneyGram.st_GetStateRelation
AS
BEGIN
	
	SELECT 
		s.IdState IdStateMaxi,
		msp.*
	FROM dbo.State s
		JOIN dbo.Country c ON c.IdCountry = s.IdCountry
		JOIN MoneyGram.Country mg ON mg.CountryCode = c.CountryCode
		JOIN MoneyGram.StateProvince msp ON msp.CountryCode = mg.CountryCode AND CONCAT(mg.CountryLegacyCode, '-', msp.StateProvinceCode) = s.StateCodeISO3166_2
	WHERE mg.ActiveForMaxi = 1
		--AND mg.IsStateRequired = 1
	
END