CREATE PROCEDURE [dbo].[st_FetchCountries2]
(
	@Code			VARCHAR(200),
	@HasTransfers	BIT,
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

	SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.*
	FROM Country c WITH(NOLOCK)
	--WHERE 
	--	-- @Code
	--	(@Code IS NULL OR c.CountryCode = @Code)
	--	AND -- @HasTransfers
	--	(
	--		ISNULL(@HasTransfers, 0) = 0 
	--		OR 
	--		EXISTS
	--		(
	--			SELECT 1
	--			FROM CountryCurrency cc WITH(NOLOCK)
	--				JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdCountryCurrency = cc.IdCountryCurrency
	--				JOIN Payer p WITH(NOLOCK) ON pc.IdPayer = p.IdPayer
	--			WHERE cc.IdCountry = c.IdCountry
	--			AND pc.IdGenericStatus = 1
	--			AND p.IdGenericStatus = 1
	--		)
	--	)
	ORDER BY c.IdCountry
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
