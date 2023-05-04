CREATE PROCEDURE [dbo].[st_FetchCountryCurrency]
(
	@CountryCode	   VARCHAR(200),
	@CurrencyCode	   VARCHAR(200),
	@Offset			   BIGINT,
	@Limit			   BIGINT
)
AS
BEGIN
    SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		cc.IdCountryCurrency, cc.IdCountry, cc.IdCurrency, cc.DateOfLastChange, cc.EnterByIdUser 
	FROM CountryCurrency cc WITH(NOLOCK)
		JOIN Country pc WITH(NOLOCK) ON pc.IdCountry = cc.IdCountry
		JOIN Currency p WITH(NOLOCK) ON p.IdCurrency = cc.IdCurrency
    WHERE 	
		(@CountryCode IS NULL OR pc.CountryCode = @CountryCode) -- @Code
		AND (@CurrencyCode IS NULL OR p.CurrencyCode = @CurrencyCode) -- @Code
	
	ORDER BY cc.IdCountryCurrency
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
