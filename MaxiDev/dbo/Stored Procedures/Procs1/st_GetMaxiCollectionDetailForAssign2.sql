
create Procedure [dbo].[st_GetMaxiCollectionDetailForAssign2]
(
    @CollectDate DATETIME,
    @IdAgentStatus int,
    @IdAgentClass INT,
    @IdUser int
)
as
SET ARITHABORT ON
--declaracion de variables
declare @IsAdmin int
CREATE TABLE #Collect
(
    IdAgent INT,
    AgentCode NVARCHAR(max),
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

select @IsAdmin=isadmin from [CollectionUsers] where iduser=@IdUser
set @IsAdmin=isnull(@IsAdmin,0)

--Obtener de historico
IF (@CollectDate<dbo.RemoveTimeFromDatetime(GETDATE()))
BEGIN
    INSERT INTO #Collect
    SELECT 
        m.idagent,
        a.AgentCode,
        a.AgentName,
        AmountByCalendar, 
        AmountByLastDay, 
        AmountByCollectPlan,
        CollectAmount,
        m.IdAgentCollectType,
        m.IdAgentClass,
        m.IdAgentStatus,
        a.IdOwner
    from MaxiCollection m (nolock)
    JOIN dbo.Agent a (nolock) ON m.idagent=a.idagent
    WHERE m.dateofcollection=dbo.RemoveTimeFromDatetime(@CollectDate)
    ORDER BY AgentCode
END
ELSE
begin
    INSERT INTO #Collect
    exec st_GetAgentAllCollectionForAssign @CollectDate
END

delete from #Collect where (IdAgentCollectType=1 and IdAgentStatus!=3 and IdAgentStatus!=7)

--paginar

select idagent,SUM(amount) dep  into #deposits from agentdeposit (nolock) WHERE dbo.RemoveTimeFromDatetime(DateOfLastChange)=@CollectDate group by idagent

if @IsAdmin=1
    select t.IdAgent,AgentCode,AgentName,OwnerName,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,CollectAmount+isnull(dep,0) CollectAmount,DateOfDebit,DateOfLNPD LNPD,IdUser,UserLogin,CallStatus,CallDate, Revision, DepositAmount, isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=t.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) AmountHisDebt 
    from
    (
        select
            c.IdAgent,c.AgentCode,c.AgentName,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,Sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay, sum(c.AmountByCollectPlan) AmountByCollectPlan,sum(c.CollectAmount) CollectAmount,d.DateOfDebit,d.DateOfLNPD,isnull(a.IdUser,0) IdUser,isnull(u.username,'Unassigned') UserLogin,dbo.fn_GetCallStatus(c.idagent,@CollectDate) CallStatus,dbo.fn_GetCallDate(c.idagent,@CollectDate) CallDate, isnull(Revision,0) Revision, isnull(DepositAmount,0) DepositAmount
        FROM 
            #Collect c
        join owner o (nolock) on c.idowner=o.idowner       
        join 
            agent ag (nolock) on c.idagent=ag.idagent
        left join MaxiCollectionAssign a (nolock) on a.idagent=c.idagent and DateOfAssign=@CollectDate
        left join users u (nolock) on a.iduser=u.iduser
        left join maxicollectiondetail d (nolock) on c.idagent=d.idagent and dateofcollection=@CollectDate
        left join [AgentCollectionRevision] r on c.idagent=r.idagent
        WHERE     c.IdAgentClass=@IdAgentClass and c.IdAgentStatus=@IdAgentStatus and
        ((AmountByLastDay>0 and ag.idagentcollecttype in (1,2)) or (ag.idagentcollecttype not in (1,2)) or (AmountByLastDay>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ) or (AmountByCalendar>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ))
        group by   isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),c.IdAgent,c.AgentCode,c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0)
    )t
    left join
    /*(
        --select idagent,SUM(amount) dep  from agentdeposit (nolock) WHERE dbo.RemoveTimeFromDatetime(DateOfLastChange)=@CollectDate group by idagent
    )d*/#deposits d on t.idagent=d.idagent
    ORDER BY 
        AgentCode, agentName, OwnerName
else
select t.IdAgent,AgentCode,AgentName,OwnerName,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,CollectAmount+isnull(dep,0) CollectAmount,DateOfDebit,DateOfLNPD LNPD,IdUser,UserLogin,CallStatus,CallDate, Revision, DepositAmount, isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=t.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) AmountHisDebt 
from
    (
        select
            c.IdAgent,c.AgentCode,c.AgentName,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,Sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay, sum(c.AmountByCollectPlan) AmountByCollectPlan,sum(c.CollectAmount) CollectAmount,d.DateOfDebit,d.DateOfLNPD,isnull(a.IdUser,0) IdUser,isnull(u.username,'Unassigned') UserLogin,dbo.fn_GetCallStatus(c.idagent,@CollectDate) CallStatus,dbo.fn_GetCallDate(c.idagent,@CollectDate) CallDate, isnull(Revision,0) Revision, isnull(DepositAmount,0) DepositAmount
        FROM 
            #Collect c
        join owner o (nolock) on c.idowner=o.idowner       
        join 
            agent ag (nolock) on c.idagent=ag.idagent
        left join MaxiCollectionAssign a (nolock) on a.idagent=c.idagent and DateOfAssign=@CollectDate
        left join users u (nolock) on a.iduser=u.iduser
        left join maxicollectiondetail d (nolock) on c.idagent=d.idagent and dateofcollection=@CollectDate
        left join [AgentCollectionRevision] r on c.idagent=r.idagent
        WHERE     c.IdAgentClass=@IdAgentClass and c.IdAgentStatus=@IdAgentStatus and
        ((AmountByLastDay>0 and ag.idagentcollecttype in (1,2)) or (ag.idagentcollecttype not in (1,2)) or (AmountByLastDay>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ) or (AmountByCalendar>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ))
        group by   isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),c.IdAgent,c.AgentCode,c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0)
    )t
    left join
    /*(
        --select idagent,SUM(amount) dep  from agentdeposit (nolock) WHERE dbo.RemoveTimeFromDatetime(DateOfLastChange)=@CollectDate group by idagent
    )d*/#deposits d on t.idagent=d.idagent
    ORDER BY 
        AgentCode, agentName, OwnerName
