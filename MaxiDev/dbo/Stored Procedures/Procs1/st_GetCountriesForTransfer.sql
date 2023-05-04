CREATE PROCEDURE dbo.st_GetCountriesForTransfer
AS
BEGIN

	SELECT DISTINCT C1.IdCountry, C1.CountryName
	FROM dbo.Payer P WITH(NOLOCK) JOIN
		dbo.PayerConfig PC WITH(NOLOCK) ON PC.IdPayer = P.IdPayer JOIN
		dbo.CountryCurrency C WITH(NOLOCK) ON C.IdCountryCurrency = PC.IdCountryCurrency JOIN
		dbo.Country C1 WITH(NOLOCK) ON C.IdCountry = C1.IdCountry
	WHERE PC.IdGenericStatus = 1

END



