CREATE PROCEDURE dbo.st_GetPayersByCountry
@IdCountry	INT = NULL
AS
BEGIN

	SELECT DISTINCT P.IdPayer, P.PayerName, P.PayerCode
	FROM dbo.Payer P WITH(NOLOCK) JOIN
		dbo.PayerConfig PC WITH(NOLOCK) ON PC.IdPayer = P.IdPayer JOIN
		dbo.CountryCurrency C WITH(NOLOCK) ON C.IdCountryCurrency = PC.IdCountryCurrency
	WHERE ((isnull(@IdCountry, 0) = 0) OR C.IdCountry = @IdCountry )
		AND PC.IdGenericStatus = 1

END