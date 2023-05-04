﻿CREATE Procedure [Corp].[st_GetMaxiCollectionForAssign]
(
    @CollectDate DATETIME,
    @IdUser int--,
    --@AllStatus bit = null
)
as
SET ARITHABORT ON
--declaracion de variables
declare @IsAdmin int
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

select @IsAdmin=isadmin from [CollectionUsers] with(nolock) where iduser=@IdUser
set @IsAdmin=isnull(@IsAdmin,0)

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
        a.idowner
    from MaxiCollection m with(nolock)
    JOIN dbo.Agent a with(nolock) ON m.idagent=a.idagent    
    WHERE m.dateofcollection=dbo.RemoveTimeFromDatetime(@CollectDate) 
    ORDER BY AgentCode    
END
ELSE
begin
    INSERT INTO #Collect
    exec [Corp].[st_GetAgentAllCollectionForAssign] @CollectDate
END

delete from #Collect where (IdAgentCollectType=1 and IdAgentStatus!=3 and IdAgentStatus!=7)

/*
if (isnull(@AllStatus,0)=0)
begin
    delete from #Collect where IdAgentStatus=2 or IdAgentStatus=6 or IdAgentStatus=5
end
*/

if @IsAdmin=1
begin
select IdAgentStatus,AgentStatus,sum(TotUnassigned) TotUnassigned from
(
SELECT distinct
    c.idagent,
    c.IdAgentStatus, 
    AgentStatus,
    case when isnull(a.iduser,0)=0 then 1 else 0 end TotUnassigned
FROM 
    #Collect c
JOIN 
    dbo.AgentStatus s with(nolock) ON c.IdAgentStatus=s.IdAgentStatus
join 
    agent ag with(nolock) on c.idagent=ag.idagent 
left join MaxiCollectionAssign a with(nolock) on a.idagent=c.idagent and DateOfAssign=@CollectDate
where ((AmountByLastDay>0 and ag.idagentcollecttype in (1,2)) or (ag.idagentcollecttype not in (1,2)) or (AmountByLastDay>0 and (ag.idagentstatus=3 or ag.idagentstatus=7)) or (AmountByCalendar>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ))
)t
where t.idagentstatus in (1,3,4,7)
GROUP BY 
    IdAgentStatus,AgentStatus
ORDER BY AgentStatus
end
else
begin
select IdAgentStatus,AgentStatus,sum(TotUnassigned) TotUnassigned from
(
select distinct 
    c.idagent,
    c.IdAgentStatus, 
    AgentStatus,    
    case when isnull(a.iduser,0)=0 then 1 else 0 end TotUnassigned
FROM 
    #Collect c
JOIN 
    dbo.AgentStatus s with(nolock) ON c.IdAgentStatus=s.IdAgentStatus
join 
    agent ag with(nolock) on c.idagent=ag.idagent 
left join MaxiCollectionAssign a with(nolock) on a.idagent=c.idagent and DateOfAssign=@CollectDate
where 
    c.idagent in (select idagent from MaxiCollectionAssign with(nolock) where iduser=@IdUser and DateOfAssign=@CollectDate)
    and ((AmountByLastDay>0 and ag.idagentcollecttype in (1,2)) or (ag.idagentcollecttype not in (1,2)) or (AmountByLastDay>0 and (ag.idagentstatus=3 or ag.idagentstatus=7)) or (AmountByCalendar>0 and (ag.idagentstatus=3 or ag.idagentstatus=7)))
) t
where t.idagentstatus in (1,3,4,7)
GROUP BY 
    IdAgentStatus,AgentStatus
ORDER BY AgentStatus

end


