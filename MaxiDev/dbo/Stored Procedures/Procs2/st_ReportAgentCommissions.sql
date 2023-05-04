CREATE procedure [dbo].[st_ReportAgentCommissions]
(
    @BeginDate datetime,
    @EndDate datetime
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

--declaracion de variables

--Inicializacion de variables
 Select  @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)  
 Select  @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1) 

--select t.idagent, AgentCode, AgentName, c.name AgentClass,sum(agentcommission) AgentCommission,case when RetainMoneyCommission=0 then sum(DebCommission) else sum(agentcommission) end DebCommission from
--(   
--    select idagent,commission agentcommission,0 DebCommission from agentbalance where DateOfMovement>= @BeginDate and DateOfMovement <= @EndDate

--    union all
    
--    select idagent,0 agentcommission,commission DebCommission from AgentCommisionCollection where DateOfCollection>= @BeginDate and DateOfCollection <= @EndDate
--)t
--join agent a on a.idagent=t.idagent and IdAgentPaymentSchema=1 and RetainMoneyCommission=1
--join agentclass c on a.idagentclass=c.IdAgentClass
--group by t.idagent, AgentCode, AgentName, c.name, RetainMoneyCommission
--having sum(agentcommission)>0 or sum(DebCommission)>0

select idagent,sum(agentcommission) AgentCommission, sum(DebCommission) DebCommission 
into #commission
from
(   
    select idagent,commission+FxFee agentcommission,0 DebCommission from agentbalance with(nolock) where DateOfMovement>= @BeginDate and DateOfMovement <= @EndDate

    union all
    
    select idagent,0 agentcommission,commission DebCommission from AgentCommisionCollection with(nolock) where DateOfCollection>= @BeginDate and DateOfCollection <= @EndDate
)t
group by t.idagent

select A.idagent, AgentCode, AgentName, c.name AgentClass, round(isnull(AgentCommission,0),2) AgentCommission,round(isnull(DebCommission,0),2) DebCommission, isnull(AgentCommissionPayName,'') AgentCommissionPayName
from
    agent a with(nolock)
join 
    agentclass c with(nolock) on a.idagentclass=c.IdAgentClass
LEFT JOIN
    #commission com on a.idagent=com.idagent
left join
    AgentFinalStatusHistory h with(nolock) on a.idagent=h.IdAgent and h.DateOfAgentStatus=@EndDate
left join
    AgentCommissionPay p with(nolock) on a.IdAgentCommissionPay=p.IdAgentCommissionPay
where
    IdAgentPaymentSchema=1
	and
	round(isnull(AgentCommission,0),2)>0
	and
	a.AgentCode not like '%-B' AND a.AgentCode not like '%-P'
    and
    (
        (RetainMoneyCommission=1) or
        (a.idagent in (select idagent from agentcollection with(nolock) where  AmountToPay>0 and idagentcollection in (select idagentcollection from [dbo].[AgentCommissionConfiguration] with(nolock)))) or
        --suspended
        (isnull(h.idagentstatus,0) in (3,7) and round(isnull((select top 1 balance from agentbalance with(nolock) where dateofmovement<@EndDate and idagent=a.IdAgent order by DateOfMovement desc),0),2)>0)
    )

--select 1242 idagent, '0020-TX'	AgentCode,	'ENVIOS DE PRUEBA' AgentName, 'D'	AgentClass, 10.5	AgentCommission, 10.5	DebCommission, 'Not defined'	AgentCommissionPayName