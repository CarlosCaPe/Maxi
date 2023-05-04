create Procedure [dbo].[st_GetMaxiCollectionDetail2]
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
    from MaxiCollection m
    JOIN dbo.Agent a ON m.idagent=a.idagent
    WHERE m.dateofcollection=dbo.RemoveTimeFromDatetime(@CollectDate)
    ORDER BY AgentCode
END
ELSE
begin
    INSERT INTO #Collect
    exec st_GetAgentAllCollection @CollectDate
END

delete from #Collect where (IdAgentCollectType=1 and IdAgentStatus!=3 and IdAgentStatus!=7)

--paginar

if @IsAdmin=1
    select
        c.IdAgent,c.AgentCode,c.AgentName,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,Sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay, sum(c.AmountByCollectPlan) AmountByCollectPlan,sum(c.CollectAmount) CollectAmount,d.DateOfDebit,d.DateOfLNPD LNPD,isnull(a.IdUser,0) IdUser,isnull(u.username,'Unassigned') UserLogin,dbo.fn_GetCallStatus(c.idagent,@CollectDate) CallStatus,dbo.fn_GetCallDate(c.idagent,@CollectDate) CallDate, isnull(Revision,0) Revision, isnull(DepositAmount,0) DepositAmount, isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=c.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) AmountHisDebt
    FROM 
        #Collect c
    join owner o on c.idowner=o.idowner       
    left join MaxiCollectionAssign a on a.idagent=c.idagent and DateOfAssign=@CollectDate
    left join users u on a.iduser=u.iduser
    left join maxicollectiondetail d on c.idagent=d.idagent and dateofcollection=@CollectDate
    left join [AgentCollectionRevision] r on c.idagent=r.idagent
    WHERE c.IdAgentClass=@IdAgentClass and c.IdAgentStatus=@IdAgentStatus
    group by   isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),c.IdAgent,c.AgentCode,c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0)
    HAVING
        round(SUM(AmountByCalendar)+SUM(AmountByLastDay)+SUM(AmountByCollectPlan),2)>0
    ORDER BY 
    AgentCode, agentName, isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'')
else
    select
        c.IdAgent,c.AgentCode,c.AgentName,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,Sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay, sum(c.AmountByCollectPlan) AmountByCollectPlan,sum(c.CollectAmount) CollectAmount,d.DateOfDebit,d.DateOfLNPD LNPD,isnull(a.IdUser,0) IdUser,isnull(u.username,'Unassigned') UserLogin,dbo.fn_GetCallStatus(c.idagent,@CollectDate) CallStatus,dbo.fn_GetCallDate(c.idagent,@CollectDate) CallDate, isnull(Revision,0) Revision, isnull(DepositAmount,0) DepositAmount, isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=c.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) AmountHisDebt
    FROM 
        #Collect c
    join owner o on c.idowner=o.idowner       
    left join MaxiCollectionAssign a on a.idagent=c.idagent and DateOfAssign=@CollectDate
    left join users u on a.iduser=u.iduser
    left join maxicollectiondetail d on c.idagent=d.idagent and dateofcollection=@CollectDate
    left join [AgentCollectionRevision] r on c.idagent=r.idagent
    WHERE c.IdAgentClass=@IdAgentClass and c.IdAgentStatus=@IdAgentStatus and c.idagent in (select idagent from MaxiCollectionAssign where iduser=@IdUser and DateOfAssign=@CollectDate)
    group by   isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),c.IdAgent,c.AgentCode,c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0)
    HAVING
        round(SUM(AmountByCalendar)+SUM(AmountByLastDay)+SUM(AmountByCollectPlan),2)>0
    ORDER BY 
    AgentCode, agentName, isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'')