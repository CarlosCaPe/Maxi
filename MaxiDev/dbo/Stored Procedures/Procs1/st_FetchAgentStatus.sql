CREATE PROCEDURE [dbo].[st_FetchAgentStatus]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

SELECT 
	   COUNT(*) OVER() _PagedResult_Total,
	   [IdAgentStatus] as [Id]
      ,[AgentStatus] as [Name]
	FROM [dbo].[AgentStatus] WITH(NOLOCK)
	
	ORDER BY IdAgentStatus
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
