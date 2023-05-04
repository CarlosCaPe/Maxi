CREATE PROCEDURE [MoneyAlert].[st_CountryPhoneCode]
AS
SET NOCOUNT ON
SELECT CountryName, A.CountryPhoneCode from moneyalert.countryPhoneCode A WITH(NOLOCK)
JOIN Country B on (A.IdCountry=B.IdCountry)








