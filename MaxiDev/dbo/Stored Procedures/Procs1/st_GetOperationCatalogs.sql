CREATE PROCEDURE st_GetOperationCatalogs
AS
BEGIN
	SELECT
		'Currency' CatalogType,
		c.CurrencyCode,
		c.CurrencyName
	FROM Currency c

	SELECT 
		'PaymentType' CatalogType,
		pt.IdPaymentType,
		pt.PaymentName
	FROM PaymentType pt

	SELECT
		'Country' CatalogType,
		c.CountryCode,
		c.CountryName
	FROM Country c

	SELECT
		'State' CatalogType,
		st.StateCode,
		st.StateName,
		ct.CountryCode
	FROM State st
		JOIN Country ct ON ct.IdCountry = st.IdCountry
END
