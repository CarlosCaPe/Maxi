CREATE PROCEDURE [dbo].[st_ReportAgentPaymentType] 
	@IdAgentCommissionPay int,
    @BeginDate Datetime,
    @EndDate Datetime
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

/*
	SELECT	A.AgentCode AS AgentCode, 
			A.AgentName AS AgentName, 
			AG.AgentCommissionPayName AS AgentCommissionPayName,
			AST.AgentStatus   
	FROM	Agent AS A 
            INNER JOIN AgentCommissionPay AS AG ON (A.IdAgentCommissionPay = AG.IdAgentCommissionPay)
			INNER JOIN AgentStatus AS AST ON (A.IdAgentStatus = AST.IdAgentStatus)
	WHERE	(A.IdAgentCommissionPay = @IdAgentCommissionPay OR @IdAgentCommissionPay = 0 ) ORDER BY  A.AgentName
*/

--soloQA
--set @EndDate=getdate()

set @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)                        
set @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)  



declare @EndDate2 datetime
set @EndDate2 = @EndDate
if @EndDate = dbo.RemoveTimeFromDatetime(GETDATE()+1) --es hoy la fecha final?
BEGIN
	set @EndDate2 = @EndDate2 -2
END
else
BEGIN
	set @EndDate2 = @EndDate2 -1 
END
print @EndDate2

select distinct idagent into #agentoper from agentbalance with(nolock) 
where 
    DateOfMovement>@BeginDate  and DateOfMovement<@EndDate and idagent in (SELECT 
      distinct [IdAgent]
FROM agentfinalstatushistory with(nolock) where DateOfAgentStatus=@EndDate2 and IdAgentCommissionPay is not null)

insert into #agentoper
select distinct idagent from agentbalance with(nolock) 
where 
    DateOfMovement>@BeginDate  and DateOfMovement<@EndDate and idagent in (
SELECT 
      distinct [IdAgent]
FROM agentfinalstatushistory with(nolock) where DateOfAgentStatus=@EndDate2 and idagentstatus=3 and idagent not in (select idagent from #agentoper))

insert into #agentoper
SELECT 
      distinct a.[IdAgent]
FROM [AgentCollection] a with(nolock)
left join agentfinalstatushistory f with(nolock) on DateOfAgentStatus=@EndDate2 and f.idagent=a.idagent
where AmountToPay>0 and a.idagent not in (select idagent from #agentoper) and f.idagentstatus in (1,4,3)

select   
    ac.idagent,  
    (select top 1 ActualAmountToPay from agentcollectiondetail with(nolock) where LastAmountToPay=0 and idagentcollection=ac.IdAgentCollection order by IdAgentCollectionDetail desc) - ac.amounttopay As AgentPayments,     
    (select top 1 ActualAmountToPay from agentcollectiondetail with(nolock) where LastAmountToPay=0 and idagentcollection=ac.IdAgentCollection order by IdAgentCollectionDetail desc) As TotalCollectPlan, 
    ac.amounttopay As TotalDebt 
    into #CollectPlan
from 
	AgentCollection AC with(nolock) 
LEFT join 
    (select idagent, IdAgentCollectType,sum(amount) amount, count(1) tot  from calendarcollect with(nolock) group by idagent, IdAgentCollectType) cc on ac.idagent=cc.idagent
LEFT join 
    agentcollecttype c with(nolock) on cc.IdAgentCollectType=c.idagentcollecttype
where ac.AmountToPay>0 and ac.idagent in (select idagent from #agentoper)

if @IdAgentCommissionPay=0
    set @IdAgentCommissionPay=null
    
    select AgentCode,AgentName,AgentStatus,AgentCommissionPayName,AgentCurrentStatusName,AgentCurrentCommissionPayName,Commissions,DebCommissions,AgentPayments,TotalCollectPlan,TotalDebt from
    (
    SELECT	A.AgentCode AS AgentCode, 
			A.AgentName AS AgentName, 
            
            ASTF.AgentStatus,
			ISNULL(AGF.AgentCommissionPayName,'UNKNOWN') AS AgentCommissionPayName,			
            
            AST.AgentStatus AgentCurrentStatusName,
            ISNULL(AG.AgentCommissionPayName,'UNKNOWN') AS AgentCurrentCommissionPayName,

            round(isnull((select sum(commission+FxFee) from agentbalance with(nolock) where DateOfMovement>= @BeginDate and DateOfMovement <= @EndDate and idagent=a.idagent),0),2) Commissions,
            round(isnull((select sum(isnull(commission,0)) from AgentCommisionCollection with(nolock) where DateOfCollection>= @BeginDate and DateOfCollection <= @EndDate and idagent=a.idagent),0),2) DebCommissions,
            isnull(AgentPayments,0) AgentPayments,
            isnull(TotalCollectPlan,0) TotalCollectPlan,
            isnull(TotalDebt,0) TotalDebt
	FROM	Agent AS A with(nolock) 
            left JOIN AgentCommissionPay AS AG with(nolock) ON (A.IdAgentCommissionPay = AG.IdAgentCommissionPay)
			JOIN AgentStatus AS AST with(nolock) ON (A.IdAgentStatus = AST.IdAgentStatus)            
            left join agentfinalstatushistory f with(nolock) on DateOfAgentStatus=@EndDate2 and f.idagent=a.idagent
            JOIN AgentStatus AS ASTF with(nolock) ON (f.IdAgentStatus = ASTF.IdAgentStatus)
            left JOIN AgentCommissionPay AS AGF with(nolock) ON (F.IdAgentCommissionPay = AGF.IdAgentCommissionPay)
            left join #CollectPlan as cp on a.idagent=cp.idagent
	WHERE	(f.IdAgentCommissionPay = isnull(@IdAgentCommissionPay,f.IdAgentCommissionPay ) or  @IdAgentCommissionPay is null ) and
            --f.IdAgentCommissionPay is not null and
            A.idagent in (select idagent from #agentoper) and
            a.IdAgentPaymentSchema=1
    ) t
    where Commissions>0
    ORDER BY  AgentCode
