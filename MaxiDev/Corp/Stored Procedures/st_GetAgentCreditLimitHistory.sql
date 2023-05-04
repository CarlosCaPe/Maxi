CREATE procedure [Corp].[st_GetAgentCreditLimitHistory]
(
    @IdAgent int
)
as
select 
    top 50 h.CreditAmount,h.DateOfLastChange,h.EnterByIdUser, UserName, h.NoteCreditAmountChange as 'Note'
from 
    [AgentCreditLimitHistory] h with(nolock)
join
    users u with(nolock) on h.EnterByIdUser=u.iduser
where 
    idagent=@IdAgent order by DateOfLastChange desc


