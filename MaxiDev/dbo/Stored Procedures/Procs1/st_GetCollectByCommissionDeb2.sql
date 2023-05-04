
CREATE procedure [dbo].[st_GetCollectByCommissionDeb2]
(
    @BeginDate datetime,
    @EndDate datetime
)
as
--Inicializacion de variables
Declare @Today int

--quitar
--set @EndDate=getdate()

set @Today = [dbo].[GetDayOfWeek] (@EndDate)

--quitar
--set @EndDate=@EndDate-1

Select  @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)  
Select  @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)

--quitar
--if @Today=1 
--    set @Today=3
--else
--    set @Today=1


--descomentar
if @today=7
    set @today=3
if @today=6
    set @today=2
else
    set @today=1



select @EndDate, @EndDate-1

select a.IdAgent,cl.Name AgentClass, AgentCode ,AgentName,RetainMoneyCommission ,case when isnull(AgentCommission,0)> 0 then isnull(AgentCommission,0) else 0 end Commission, case when isnull(CommissionRetain,0)>0 then isnull(CommissionRetain,0) else 0 end CommissionRetain, isnull(Debit,0) Debit
from agent a
join 
    agentclass cl on a.idagentclass=cl.idagentclass
join 
    agentstatus s on a.IdagentStatus=s.IdagentStatus
left join
(
    select IdAgent, sum(isnull(AmountByLastDay,0)) Debit from maxicollection where DateOfCollection=@EndDate-@Today group by IdAgent
) deb on a.idagent=deb.idagent
left join
(        
    select idagent,sum(commission) agentcommission from agentbalance where DateOfMovement>= @BeginDate and DateOfMovement <= @EndDate group by idagent
)com on a.idagent=com.idagent
left join
(
    select idagent, sum(isnull(Commission,0)) CommissionRetain from AgentCommisionCollection where DateOfCollection=@EndDate-1 group by idagent
)comR on a.idagent=comR.idagent
where
	((a.IdAgentPaymentSchema=1 and a.idagentstatus=3) or (a.RetainMoneyCommission=1 and a.idagentstatus in (1,4) ) ) 
    --and isnull(Debit,0)>0 
    and
    not exists (select IdAgentCommisionCollection from AgentCommisionCollection where IdCommisionCollectionConcept=2 and IdAgent = A.IdAgent and DateOfCollection=@EndDate-1)