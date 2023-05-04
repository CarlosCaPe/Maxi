CREATE PROCEDURE [dbo].[st_FetchAgentEntityType]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

  SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.IdAgentEntityType as Id, c.Name
	FROM AgentEntityType c 

	ORDER BY c.IdAgentEntityType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END