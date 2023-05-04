CREATE PROCEDURE [Corp].[st_GetCountryCurrencies] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT CC.IdCountryCurrency, CC.IdCountry, CO.CountryName, CC.IdCurrency, CU.CurrencyName, CO.CountryName, CO.CountryCode, CU.CurrencyName, CU.CurrencyCode, CU.DivisorExchangeRate
	FROM [dbo].[CountryCurrency] AS CC WITH(NOLOCK)
		INNER JOIN [dbo].[Country] AS CO WITH(NOLOCK) ON CC.IdCountry = CO.IdCountry 
		INNER JOIN [dbo].[Currency] AS CU WITH(NOLOCK) ON CC.IdCurrency = CU.IdCurrency
END
