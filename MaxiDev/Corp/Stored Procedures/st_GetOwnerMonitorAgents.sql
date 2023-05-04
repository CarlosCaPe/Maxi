CREATE PROCEDURE  [Corp].[st_GetOwnerMonitorAgents] 
	@idOwner int
	as
BEGIN
	
	SET NOCOUNT ON;
	SELECT 
	   A.[IdOwner]
      ,A.[AgentCode]
      ,A.[AgentName]
      ,AC.[Name] as 'Class'
      ,A.[IdAgent]
	  ,AST.[AgentStatus] as 'Status'
      ,ACB.[Balance] as 'CurrentBalance'
	  ,ACol.[AmountToPay] as 'CollectPlan'
	  FROM [dbo].[Agent] A WITH (nolock) 
	  LEFT JOIN  dbo.AgentStatus AST WITH (nolock) ON  A.IdAgentStatus=AST.IdAgentStatus 
	  LEFT JOIN  dbo.AgentCollection ACol WITH (nolock) ON  ACol.IdAgent=A.IdAgent 
	  LEFT JOIN AgentClass AC WITH (nolock) ON  AC.[IdAgentClass]=A.IdAgentClass 
	  LEFT JOIN AgentCurrentBalance ACB WITH (nolock) ON  ACB.IdAgent=A.IdAgent
	  WHERE A.IdOwner= @idOwner 
	
END
