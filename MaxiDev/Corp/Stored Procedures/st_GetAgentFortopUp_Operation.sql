CREATE PROCEDURE [Corp].[st_GetAgentFortopUp_Operation]
AS

	SELECT DISTINCT
		A.[IdAgent]
		, A.[AgentCode]
		, A.[AgentName]
		, A.[IdAgentStatus]
		, S.[AgentStatus]
		, /* CASE
				WHEN ISNULL(AP.[IdOtherProducts],0)=7 THEN 2
				WHEN ISNULL(AP.[IdOtherProducts],0)=9 THEN 3
			ELSE 0 END*/
		2 [Provider]
	FROM [dbo].[Agent] A WITH (NOLOCK)
	JOIN [dbo].[AgentStatus] S WITH (NOLOCK) ON S.[IdAgentStatus] = A.[IdAgentStatus]
	JOIN [dbo].[AgentProducts] AP WITH (NOLOCK) ON A.[IdAgent] = AP.[IdAgent] AND AP.[IdOtherProducts] IN (7,9,17) AND AP.[IdGenericStatus] = 1
	WHERE A.[IdAgent] IN (
							SELECT [IdAgent] FROM [dbo].[AgentOtherProductInfo] WITH (NOLOCK) WHERE [IdOtherProduct] IN (7,9,17)
						)
	ORDER BY A.[AgentCode]


