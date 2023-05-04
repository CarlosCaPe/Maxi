CREATE PROCEDURE [dbo].[st_FetchAgentBusinessType]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

  SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.IdAgentBusinessType as Id, c.Name
	FROM AgentBusinessType c 

	ORDER BY c.IdAgentBusinessType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END