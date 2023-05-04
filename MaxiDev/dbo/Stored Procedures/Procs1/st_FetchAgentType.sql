CREATE PROCEDURE [dbo].[st_FetchAgentType]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

SELECT 
	   COUNT(*) OVER() _PagedResult_Total,
       [IdAgentType] as [Id] 
      ,[Name] as  [Name]
       FROM [dbo].[AgentType] WITH(NOLOCK)
	
	ORDER BY IdAgentType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
