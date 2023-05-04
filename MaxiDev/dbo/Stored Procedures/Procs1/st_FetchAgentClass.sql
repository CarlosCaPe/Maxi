CREATE PROCEDURE [dbo].[st_FetchAgentClass]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

SELECT 
	   COUNT(*) OVER() _PagedResult_Total,
       [IdAgentClass] as [Id]
      ,[Name] as [Name]
       FROM [dbo].[AgentClass] WITH(NOLOCK)
	
	ORDER BY IdAgentClass
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
