CREATE PROCEDURE [dbo].[st_FetchCounty]
(
    @IdCountry      INT,
    @IdState        INT,
	@Name	        VARCHAR(200),
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

      SELECT 
	  COUNT(*) OVER() _PagedResult_Total,
	  cc.IdCounty, cc.CountyName, cc.DateOfLastChange, cc.EnterByIdUser FROM County cc WITH(NOLOCK)
		JOIN State pc WITH(NOLOCK) ON pc.IdState = cc.IdState
		JOIN Country p WITH(NOLOCK) ON pc.IdCountry = p.IdCountry
		WHERE 
			pc.IdState=@IdState 
		AND p.IdCountry=@IdCountry
		AND (@Name IS NULL OR (cc.CountyName LIKE CONCAT('%', @Name, '%')))

	          ORDER BY cc.IdCounty
	          OFFSET (@Offset) ROWS
	          FETCH NEXT @Limit ROWS ONLY
	END

