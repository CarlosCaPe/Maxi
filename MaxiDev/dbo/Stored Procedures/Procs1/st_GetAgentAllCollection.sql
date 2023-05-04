CREATE Procedure [dbo].[st_GetAgentAllCollection]
    @CollectionDate DATETIME 
AS   
/********************************************************************
<Author> ??? </Author>
<app>Corporate</app>
<Description>Obtiene Cobranza por dia de todos los Agentes </Description>

<ChangeLog>
<log Date="06/06/2017" Author="FGONZALEZ">Optimizacion de consultas para uso de indices</log>
</ChangeLog>

*********************************************************************/
SET ARITHABORT ON
--Delaracion de variables
Declare @DayOfPayment int    
    
--Inicializacion de variables
Select   @DayOfPayment = dbo.[GetDayOfWeek](@CollectionDate)
        ,@CollectionDate = dbo.RemoveTimeFromDatetime(@CollectionDate)

select 
	t.idagent
	,AgentCode
	,A.[AgentState]
	,AgentName
	, sum(AmountByCalendar) AmountByCalendar
	, sum(AmountByLastDay) AmountByLastDay
	, sum(AmountByCollectPlan) AmountByCollectPlan
	, sum (collectAmount) collectAmount
	,t.IdAgentCollectType
	,IdAgentClass
	, IdAgentStatus
	, Idowner 
from
(
--Obtener adeudos por agencia

select idagent,AmountByCalendar, AmountByLastDay, AmountByCollectPlan,0 collectAmount,IdAgentCollectType 
from maxicollection with (nolock) 
where DateOfCollection>=@CollectionDate AND DateOfCollection < dateadd(day,1,@CollectionDate) --#1


UNION ALL

--Obtener Depositos
select 
	d.idagent
	,0 AmountByCalendar
	, 0 AmountByLastDay
	, 0 AmountByCollectPlan
	,d.amount collectAmount
	,a.idagentcollecttype
 from agentdeposit  d with (nolock) 
	join agent a with (nolock) on d.idagent=a.idagent 
	LEFT JOIN AgentBalance ab ON ab.IdAgentBalance = d.IdAgentBalance
 WHERE 
	d.DateOfLastChange >= @CollectionDate 
	AND d.DateOfLastChange < dateadd(day,1,@CollectionDate) --#1
	AND [dbo].[GetDayOfWeek] (d.DateOfLastChange) not in (6,7) 
	AND ab.TypeOfMovement <> 'DCP'
	
UNION ALL
	
--Obtener cobros por comisiones
	SELECT 
	c.IdAgent
	,0 AmountByCalendar
	,0 AmountByLastDay
	,AmountExpected AmountByCollectPlan,d.AmountToPay collectAmount,5 idagentcollecttype 
	FROM dbo.AgentCollectionDetail d with (nolock)
	JOIN dbo.AgentCollection c with (nolock) ON c.IdAgentCollection=d.IdAgentCollection
	join dbo.Agent a with (nolock) ON c.IdAgent=a.IdAgent    
	WHERE IdAgentCollectionConcept=4 AND d.CreationDate >=@CollectionDate AND d.CreationDate < dateadd(day,1,@CollectionDate) --#1

) T
join agent a on t.idagent=a.idagent
group by t.idagent,AgentCode, A.[AgentState],AgentNAme, t.IdAgentCollectType,IdAgentClass, IdAgentStatus,Idowner
order by idagent

