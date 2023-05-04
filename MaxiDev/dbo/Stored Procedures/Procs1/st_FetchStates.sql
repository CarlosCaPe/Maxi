CREATE PROCEDURE st_FetchStates
(
	@Code			VARCHAR(20),
	@Name			VARCHAR(100),
	@CodeISO3166	VARCHAR(10),
	@SendLicense	BIT,
	@IdCountry		INT,

	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

	SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		s.*
	FROM State s
	WHERE 
		s.IdCountry = @IdCountry
		AND (@Code IS NULL OR s.StateCode = @Code) -- @Code
		AND (@Name IS NULL OR s.StateName LIKE CONCAT('%', @Name, '%')) -- @Name
		AND (@CodeISO3166 IS NULL OR s.StateCodeISO3166 = @CodeISO3166) -- @CodeISO3166
		AND (@SendLicense IS NULL OR s.SendLicense = @SendLicense) -- @SendLicense
	ORDER BY s.IdState
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
