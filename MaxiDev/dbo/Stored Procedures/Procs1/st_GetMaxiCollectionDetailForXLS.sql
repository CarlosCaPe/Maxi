CREATE Procedure [dbo].[st_GetMaxiCollectionDetailForXLS]
(
    @CollectDate DATETIME   
)
as
--declaracion de variables
CREATE TABLE #Collect
(
    IdAgent INT,
    AgentCode NVARCHAR(max),
	AgentState NVARCHAR(max),
    AgentName NVARCHAR(max),
    AmountByCalendar MONEY, 
    AmountByLastDay MONEY, 
    AmountByCollectPlan MONEY,
    CollectAmount MONEY,
    IdAgentCollectType INT,
    IdAgentClass int,
    IdAgentStatus int,
    IdOwner int
)

--Inicializacion de variables
SELECT @CollectDate=dbo.RemoveTimeFromDatetime(@CollectDate)

--Obtener de historico
IF (@CollectDate<dbo.RemoveTimeFromDatetime(GETDATE()))
BEGIN
    INSERT INTO #Collect
    SELECT 
        m.idagent,
        a.AgentCode,
		a.AgentState,
        a.AgentName,
        AmountByCalendar, 
        AmountByLastDay, 
        AmountByCollectPlan,
        CollectAmount,
        m.IdAgentCollectType,
        m.IdAgentClass,
        m.IdAgentStatus,
        a.IdOwner
    from MaxiCollection m  WITH (NOLOCK)
		JOIN dbo.Agent a WITH (NOLOCK) ON m.idagent=a.idagent
    WHERE m.dateofcollection=dbo.RemoveTimeFromDatetime(@CollectDate)
    ORDER BY AgentCode
END
ELSE
begin
    INSERT INTO #Collect
    exec st_GetAgentAllCollection @CollectDate
END

--SELECT a.IdAgent,a.AgentCode,a.AgentName,BankName,Amount,DepositDate,c.Name AgentCollectType  FROM dbo.AgentDeposit d
--JOIN dbo.Agent a ON a.IdAgent=d.IdAgent
--JOIN dbo.AgentCollectType c ON d.IdAgentCollectType=c.IdAgentCollectType
--WHERE dbo.RemoveTimeFromDatetime(d.DateOfLastChange)=@CollectDate
--AND a.IdAgent IN (SELECT DISTINCT IdAgent from #Collect)
--ORDER BY c.Name,AgentCode

SELECT         
    s.AgentStatus,ac.name AgentClass,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,c.IdAgent,c.AgentCode,c.AgentState, c.AgentName,sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay,sum(c.AmountByCollectPlan) AmountByCollectPlan, sum(c.CollectAmount) CollectAmount
FROM 
    #Collect c    
join agentStatus s WITH (NOLOCK) on s.idagentstatus=c.idagentstatus
join agentclass ac WITH (NOLOCK) on ac.IdAgentClass=c.IdAgentClass
join owner o WITH (NOLOCK) on c.idowner=o.idowner
group by idagent,AgentName,s.AgentStatus,ac.name, isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),AgentCode, AgentState
ORDER BY 
    s.AgentStatus,ac.name desc, isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),AgentCode
