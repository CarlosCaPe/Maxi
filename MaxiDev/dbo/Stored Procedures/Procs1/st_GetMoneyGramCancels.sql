CREATE PROCEDURE st_GetMoneyGramCancels
AS
BEGIN

	DECLARE @IdGateWay		INT
	
	SELECT 
		@IdGateWay = g.IdGateway 
	FROM Gateway g WHERE g.Code = 'MONEYGRAM'

	SELECT
		t.ClaimCode		IdRemittance,
		c.CountryCode	CurrencyCode
	FROM Transfer t 
		JOIN CountryCurrency cc ON cc.IdCountryCurrency = t.IdCountryCurrency
		JOIN Country c ON c.IdCountry = cc.IdCountry
	WHERE 
		t.IdGateway = @IdGateWay
		AND t.IdStatus = 25
END


