Create procedure [Corp].[st_GetAgentDepositInfo]
(
    @IdAgent int
)
as
select IdAgentBankDeposit,a.IdAgentCollectType,t.Name CollectType,isnull(Balance,0) CurrentBalance from agent a with(nolock) 
left join AgentCurrentBalance c with(nolock)  on a.idagent=c.idagent
join AgentCollectType t with(nolock)  on a.IdAgentCollectType=t.IdAgentCollectType
where a.idagent=@IdAgent
