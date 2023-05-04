CREATE PROCEDURE [dbo].[st_ReportAgentCollectionPlans] 
As
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

select 
    a.idagent,
	A.AgentCode, 
    A.AgentName, 
    (select top 1 CreationDate from agentcollectiondetail with(nolock) where LastAmountToPay=0 and idagentcollection=ac.IdAgentCollection order by IdAgentCollectionDetail desc) CreationDate, 
    isnull(c.name,'Commission') as  CollectionType, 
	'Periodo' as Period, 
    ISNULL(cc.tot,0) As RemainingPayments, 
    isnull(ac.amounttopay/cc.tot,0) As paymentPerPeriod, 
	AC.Fee, 
    (select top 1 ActualAmountToPay from agentcollectiondetail with(nolock) where LastAmountToPay=0 and idagentcollection=ac.IdAgentCollection order by IdAgentCollectionDetail desc) - ac.amounttopay As AgentPayments, 
    0.0 As SubTotal, 
    (select top 1 ActualAmountToPay from agentcollectiondetail with(nolock) where LastAmountToPay=0 and idagentcollection=ac.IdAgentCollection order by IdAgentCollectionDetail desc) As TotalCollectPlan, 
    ac.amounttopay As TotalDebt 
from 
	AgentCollection AC with(nolock) 
join 
    Agent A with(nolock) on AC.IdAgent = A.IdAgent 
LEFT join 
    (select idagent, IdAgentCollectType,sum(amount) amount, count(1) tot  from calendarcollect with(nolock) group by idagent, IdAgentCollectType) cc on ac.idagent=cc.idagent
LEFT join 
    agentcollecttype c with(nolock) on cc.IdAgentCollectType=c.idagentcollecttype
where ac.AmountToPay>0
order by A.AgentCode asc