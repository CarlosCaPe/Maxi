CREATE PROCEDURE [dbo].[st_FetchSpread]
(
	@Name	   	            VARCHAR(200)=NULL,
	@CountryCode	   	    VARCHAR(200)=NULL,
	@CurrencyCode	        VARCHAR(200)=NULL,
	@Offset			        BIGINT,
	@Limit			        BIGINT
)
AS
BEGIN
	DECLARE @Records TABLE (Id INT, _PagedResult_Total BIGINT)

	INSERT INTO @Records(Id, _PagedResult_Total)
	SELECT
		cc.IdSpread,
		COUNT(*) OVER() _PagedResult_Total
		
	FROM Spread cc WITH(NOLOCK)
	  JOIN CountryCurrency pk WITH(NOLOCK) ON pk.IdCountryCurrency = cc.IdCountryCurrency 
      JOIN Country pp WITH (NOLOCK) ON pp.IdCountry = pk.IdCountry
	  JOIN Currency py WITH (NOLOCK) ON py.IdCurrency = pk.IdCurrency
	  
	WHERE 
      (@Name IS NULL OR cc.SpreadName LIKE CONCAT('%', @Name, '%')) -- @Name
	  AND (@CountryCode IS NULL OR (pp.CountryCode = @CountryCode)) -- @CountryCode
      AND (@CurrencyCode IS NULL OR (py.CurrencyCode = @CurrencyCode)) -- @CurrencyCode
	  
    ORDER BY cc.IdSpread
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

	SELECT
		cc.IdSpread, 
		cc.SpreadName, 
		cc.DateOfLastChange, 
		cc.EnterByIdUser,
		cc.IdCountryCurrency, 
		r._PagedResult_Total
	FROM Spread cc WITH(NOLOCK)
		JOIN @Records r ON r.Id = cc.IdSpread

	SELECT
		pc.IdSpreadDetail,
		pc.IdSpread,
		pc.FromAmount,
		pc.ToAmount,
		pc.SpreadValue,
		pc.DateOfLastChange,
		pc.EnterByIdUser
	FROM SpreadDetail pc WITH(NOLOCK)
		JOIN @Records r ON r.Id = pc.IdSpread

END