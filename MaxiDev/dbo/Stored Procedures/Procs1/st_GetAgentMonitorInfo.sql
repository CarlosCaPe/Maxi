CREATE procedure [dbo].[st_GetAgentMonitorInfo]
(
    @idagent int
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

declare @date datetime = getdate();

set @date=[dbo].[RemoveTimeFromDatetime](@date);


select 
    agentcode, agentname , bankname, c.name agentclass, t.name collecttype, creditamount,isnull((Select top 1 Balance from AgentBalance with(nolock) where DateOfMovement<@date and IdAgent=A.idAgent order by DateOfMovement desc),0) yesterdaybalance, isnull(balance,0) currentbalance, idowner, agentstatus statusname, DoneOnSundayPayOn,DoneOnMondayPayOn,DoneOnTuesdayPayOn,DoneOnWednesdayPayOn,DoneOnThursdayPayOn,DoneOnFridayPayOn,DoneOnSaturdayPayOn, IdAgentCommunication, isnull(AmountByCalendar,0) AmountByCalendar, isnull(AmountByLastDay,0) AmountByLastDay, isnull(AmountByCollectPlan,0) AmountByCollectPlan, isnull(AmountToPay,0) TotalCollectPlan 
from 
    agent a with(nolock)
join 
    agentbankdeposit b with(nolock) on a.idagentbankdeposit=b.idagentbankdeposit
join
    agentclass c with(nolock) on a.idagentclass=c.idagentclass
join
    agentcollecttype t with(nolock) on a.idagentcollecttype=t.idagentcollecttype
left join
    agentcurrentbalance cb with(nolock) on a.idagent = cb.idagent
join 
    agentstatus s with(nolock) on a.idagentstatus=s.idagentstatus    
left join
    (select idagent,sum(AmountByCalendar) AmountByCalendar,sum(AmountByLastDay) AmountByLastDay,sum(AmountByCollectPlan)AmountByCollectPlan from maxicollection with(nolock) where dateofcollection=[dbo].[RemoveTimeFromDatetime](getdate()) and idagent=@idagent group by idagent) f on a.idagent=f.idagent
left join
    AgentCollection g with(nolock) on a.idagent =g.idagent
where 
    a.idagent=@idagent;

exec [dbo].[st_GetAgentPhoneNumbersByIdAgent] @idagent;