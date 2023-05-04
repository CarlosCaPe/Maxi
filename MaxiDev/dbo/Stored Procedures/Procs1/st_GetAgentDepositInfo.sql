CREATE procedure [dbo].[st_GetAgentDepositInfo]
(
    @IdAgent int
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

select IdAgentBankDeposit,a.IdAgentCollectType,t.Name CollectType,isnull(Balance,0) CurrentBalance 
from agent a with(nolock)
left join AgentCurrentBalance c with(nolock) on a.idagent=c.idagent
join AgentCollectType t with(nolock) on a.IdAgentCollectType=t.IdAgentCollectType
where a.idagent=@IdAgent