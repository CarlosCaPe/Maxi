CREATE PROCEDURE st_FetchAgentSchema
(
	@IdAgent				INT,
	@IdCountryCurrency		INT,
	@ShowAll				BIT,

	@Offset					BIGINT,
	@Limit					BIGINT
)
AS
BEGIN
	SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		s.*
	FROM AgentSchema s WITH(NOLOCK)
	WHERE 
		s.IdAgent = @IdAgent
		AND (@IdCountryCurrency IS NULL OR s.IdCountryCurrency = @IdCountryCurrency)
		AND (ISNULL(@ShowAll, 0) = 1 OR s.IdGenericStatus = 1)
	ORDER BY s.IdAgentSchema
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
