
CREATE Procedure [dbo].[st_GetAgentAllCollectionForAssign]
    @CollectionDate DATETIME 
AS   

--Delaracion de variables
Declare @DayOfPayment int    
    
--Inicializacion de variables
Select   @DayOfPayment = dbo.[GetDayOfWeek](@CollectionDate)
        ,@CollectionDate = convert(DATE,@CollectionDate)

select t.idagent,AgentCode, AgentState, AgentName, sum(AmountByCalendar) AmountByCalendar, sum(AmountByLastDay) AmountByLastDay, sum(AmountByCollectPlan) AmountByCollectPlan,sum(collectAmount) collectAmount,t.IdAgentCollectType,IdAgentClass, IdAgentStatus, Idowner from
(
--Obtener adeudos por agencia
select idagent,AmountByCalendar, AmountByLastDay, AmountByCollectPlan,0 collectAmount,IdAgentCollectType 
from maxicollection (nolock) where DateOfCollection >= @CollectionDate AND DateOfCollection < dateadd(day,1,@CollectionDate)
--UNION ALL
--Obtener Depositos
--select idagent,0 AmountByCalendar, 0 AmountByLastDay, 0 AmountByCollectPlan,amount collectAmount,idagentcollecttype from agentdeposit WHERE dbo.RemoveTimeFromDatetime(DateOfLastChange)=@CollectionDate
UNION ALL
--Obtener cobros por comisiones
SELECT c.IdAgent,0 AmountByCalendar,0 AmountByLastDay,AmountExpected AmountByCollectPlan,d.AmountToPay collectAmount,5 idagentcollecttype FROM dbo.AgentCollectionDetail d (nolock)
    JOIN dbo.AgentCollection c (nolock) ON c.IdAgentCollection=d.IdAgentCollection
    join dbo.Agent a (nolock) ON c.IdAgent=a.IdAgent
    WHERE IdAgentCollectionConcept=4 AND (d.CreationDate >= @CollectionDate AND d.CreationDate < dateadd(day,1,@CollectionDate))
) T
join agent a (nolock) on t.idagent=a.idagent
group by t.idagent,AgentCode,AgentState, AgentNAme, t.IdAgentCollectType,IdAgentClass, IdAgentStatus,Idowner
--order by agentcode

