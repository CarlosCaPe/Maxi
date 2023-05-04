CREATE PROCEDURE st_GetCountryCurrency
(
    @IdCountryCurrency  INT
)
AS
BEGIN
    SELECT
        cc.IdCountryCurrency,
        c.CurrencyCode,
        ct.CountryCode
    FROM CountryCurrency cc
        JOIN Currency c ON c.IdCurrency = cc.IdCurrency
        JOIN Country ct ON ct.IdCountry = cc.IdCountry
    WHERE cc.IdCountryCurrency = @IdCountryCurrency
END