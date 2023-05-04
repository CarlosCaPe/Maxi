CREATE PROCEDURE MoneyGram.st_GetCountryCurrencies
(
	@DeliveryOption		VARCHAR(30)
)
AS
BEGIN

	
	SELECT
		cc.IdCountryCurrency IdCountryCurrencyMaxi,
		mcc.*
	FROM MoneyGram.CountryCurrency mcc
		JOIN dbo.Country c ON c.CountryCode = mcc.CountryCode
		JOIN dbo.Currency cr ON cr.CurrencyCode = mcc.ReceiveCurrency
		JOIN dbo.CountryCurrency cc ON cc.IdCountry = c.IdCountry AND cc.IdCurrency = cr.IdCurrency
	WHERE mcc.DeliveryOption = @DeliveryOption--'WILL_CALL'
	AND mcc.ActiveForMaxi = 1


END
