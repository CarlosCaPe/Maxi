CREATE PROCEDURE [dbo].[st_FetchAgentCommunication]
(
	--@Name			VARCHAR(200)=NULL,
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

  SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.IdAgentCommunication as Id, c.Communication as Name
	FROM AgentCommunication c 

	ORDER BY c.IdAgentCommunication
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END
