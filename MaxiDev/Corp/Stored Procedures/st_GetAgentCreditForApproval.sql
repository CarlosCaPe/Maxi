CREATE PROCEDURE  [Corp].[st_GetAgentCreditForApproval] 
	as
BEGIN

	SET NOCOUNT ON;


SELECT 
	   A.AgentCode
	  ,A.AgentName
      ,AC.Name as AgentClass
	   ,[CreditLimit]
	  ,[CreditLimitSuggested]
	  ,[IdAgentCreditApproval]
	   ,ACA.[IdAgent]
  FROM [dbo].[AgentCreditApproval] ACA with(nolock)
  INNER JOIN Agent A with(nolock) ON A.IdAgent=ACA.IdAgent
  INNER JOIN AgentClass AC with(nolock) ON AC.IdAgentClass=A.IdAgentClass
  WHERE ACA.IsApproved is null


END
