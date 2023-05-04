

/************************/
/* st_GetCurrentBalance */
/************************/
CREATE Procedure [msg].[st_GetCurrentBalance]
(
  @IdUser int
)
as

Select a.IdAgent, isnull(Balance,0) Balance, a.CreditAmount 
From [dbo].AgentUser au (nolock)
inner join [dbo].[Agent] a  (nolock) on a.IdAgent  = au.IdAgent  
left join [dbo].[AgentCurrentBalance] acb (nolock) on acb.IdAgent = au.IdAgent
Where au.IdUser = @IdUser

