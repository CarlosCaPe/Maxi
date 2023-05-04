CREATE PROCEDURE [dbo].[st_FetchCity]
(
    @IdCountry      INT,
    @IdState        INT,
	@Name			VARCHAR(200)=NULL,
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

      SELECT 
	  COUNT(*) OVER() _PagedResult_Total,
	  cc.IdCity, cc.CityName, cc.DateOfLastChange, cc.EnterByIdUser FROM City cc WITH(NOLOCK)
		JOIN State pc WITH(NOLOCK) ON pc.IdState = cc.IdState
		JOIN Country p WITH(NOLOCK) ON pc.IdCountry = p.IdCountry
		WHERE 
		    pc.IdState=@IdState 
		AND p.IdCountry=@IdCountry
		AND (@Name IS NULL OR (cc.CityName LIKE CONCAT('%', @Name, '%')))
	          ORDER BY cc.IdCity
	          OFFSET (@Offset) ROWS
	          FETCH NEXT @Limit ROWS ONLY
	END

