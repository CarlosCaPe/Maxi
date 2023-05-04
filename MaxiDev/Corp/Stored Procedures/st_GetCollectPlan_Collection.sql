CREATE PROCEDURE  [Corp].[st_GetCollectPlan_Collection] 
	@idAgent int
	as
BEGIN

	SET NOCOUNT ON;
	SELECT TOP 1
	 AC.IdAgent,
      AC.[AmountToPay]
	  ,ACC.[CommissionPercentage]
	  ,U.[UserName]
	  ,AC.[IdAgentCollection]
      ,AC.[Fee]
      ,ACC.[IsPercent]
      ,ACC.[CommisionMoney]
  FROM [dbo].[AgentCollection] AC WITH (nolock)
  LEFT JOIN AgentCommissionConfiguration ACC WITH (nolock) ON ACC.IdAgentCollection= AC.IdAgentCollection 
  LEFT JOIN dbo.Users U WITH (nolock) ON U.IdUser=AC.EnterByIdUser
  WHERE AC.IdAgent=@idAgent


END
