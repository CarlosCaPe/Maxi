CREATE PROCEDURE [dbo].[st_GetMaxiCollectionDetailForAssign]
(
    @CollectDate DATETIME,
    @IdAgentStatus INT,
    @IdAgentClass INT,
    @IdUser INT--,
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
SELECT @CollectDate=convert(DATE,@CollectDate)

select @IsAdmin=isadmin from [CollectionUsers] where iduser=@IdUser
set @IsAdmin=isnull(@IsAdmin,0)

--Obtener de historico
IF (@CollectDate<convert(DATE,GETDATE()))
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
    from MaxiCollection m (nolock)
    JOIN dbo.Agent a (nolock) ON m.idagent=a.idagent
    WHERE m.dateofcollection >=@CollectDate AND m.dateofcollection < dateadd(day,1,@CollectDate)
    ORDER BY AgentCode
END
ELSE
BEGIN
    INSERT INTO #Collect
    exec st_GetAgentAllCollectionForAssign @CollectDate
END

delete from #Collect where (IdAgentCollectType=1 and IdAgentStatus!=3 and IdAgentStatus!=7)


--Obtenemos la ultima asignacion de cada agencia
SELECT A.IdMaxiCollectionAssign, A.IdAgent, A.IdUser, A.DateOfAssign
INTO #LastMaxiCollectionAssign
FROM
(
SELECT ROW_NUMBER() OVER (PARTITION BY IdAgent ORDER BY DateOfAssign DESC) AS rownum, *
FROM MaxiCollectionAssign
WHERE DateOfAssign <= @CollectDate
) A
WHERE A.rownum = 1


SELECT * FROM #LastMaxiCollectionAsign

--paginar

SELECT idagent,SUM(amount) dep  into #deposits 
from agentdeposit (nolock) 
WHERE DateOfLastChange >= @CollectDate AND DateOfLastChange < dateadd(day,1,@CollectDate) group by idagent

if @IsAdmin=1
    select t.IdAgent,AgentCode,AgentState,AgentName,OwnerName,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,CollectAmount+isnull(dep,0) CollectAmount,DateOfDebit,DateOfLNPD LNPD,IdUser,UserLogin,CallStatus,CallDate, Revision, DepositAmount, case when DateOfDebit is not null then isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=t.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) else 0 end AmountHisDebt 
    from
    (
        select
            c.IdAgent,c.AgentCode,c.AgentState,c.AgentName,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,Sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay, sum(c.AmountByCollectPlan) AmountByCollectPlan,sum(c.CollectAmount) CollectAmount,d.DateOfDebit,d.DateOfLNPD,isnull(a.IdUser,0) IdUser,isnull(u.username,'Unassigned') UserLogin,dbo.fn_GetCallStatus(c.idagent,@CollectDate) CallStatus,dbo.fn_GetCallDate(c.idagent,@CollectDate) CallDate, isnull(Revision,0) Revision, isnull(DepositAmount,0) DepositAmount
        FROM 
            #Collect c
        join owner o (nolock)
         	on o.idowner=c.idowner       
        join 
            agent ag (nolock) on 
             ag.idagent=c.idagent
        left join #LastMaxiCollectionAssign a (nolock)
        	 on a.idagent=c.idagent 
        	 /*and DateOfAssign=@CollectDate*/
        left join users u (nolock)
        	 on u.iduser=a.iduser
        left join maxicollectiondetail d (nolock)
        	 on d.idagent=c.idagent 
        	 and dateofcollection=@CollectDate
        left join [AgentCollectionRevision] r on 
        		r.idagent=c.idagent
       WHERE    
        c.IdAgentClass=@IdAgentClass 
        and c.IdAgentStatus=@IdAgentStatus
        and
        ((AmountByLastDay>0 and ag.idagentcollecttype in (1,2))
         or (ag.idagentcollecttype not in (1,2)) 
         or (AmountByLastDay>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ) 
         or (AmountByCalendar>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ))
        group by   isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),c.IdAgent,c.AgentCode,c.AgentState,c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0)
    )t
    left join
    /*(
        --select idagent,SUM(amount) dep  from agentdeposit (nolock) WHERE dbo.RemoveTimeFromDatetime(DateOfLastChange)=@CollectDate group by idagent
    )d*/#deposits d on t.idagent=d.idagent
    ORDER BY 
        AgentCode, agentName, AgentState, OwnerName
else
select t.IdAgent,AgentCode,AgentState, AgentName,OwnerName,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,CollectAmount+isnull(dep,0) CollectAmount,DateOfDebit,DateOfLNPD LNPD,IdUser,UserLogin,CallStatus,CallDate, Revision, DepositAmount, case when DateOfDebit is not null then isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=t.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) else 0 end AmountHisDebt 
from
    (
        select
            c.IdAgent,c.AgentCode, c.AgentState, c.AgentName,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,Sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay, sum(c.AmountByCollectPlan) AmountByCollectPlan,sum(c.CollectAmount) CollectAmount,d.DateOfDebit,d.DateOfLNPD,isnull(a.IdUser,0) IdUser,isnull(u.username,'Unassigned') UserLogin,dbo.fn_GetCallStatus(c.idagent,@CollectDate) CallStatus,dbo.fn_GetCallDate(c.idagent,@CollectDate) CallDate, isnull(Revision,0) Revision, isnull(DepositAmount,0) DepositAmount
        FROM 
            #Collect c
        join owner o (nolock) on c.idowner=o.idowner       
        join 
            agent ag (nolock) on c.idagent=ag.idagent
        left join #LastMaxiCollectionAssign a (nolock) ON
         a.idagent = c.idagent /*and DateOfAssign=@CollectDate*/
        left join users u (nolock) on 
         u.iduser=a.iduser
        left join maxicollectiondetail d (nolock) on 
        	d.idagent=c.idagent 
        	and dateofcollection=@CollectDate
        left join [AgentCollectionRevision] r 
        	on r.idagent=c.idagent
       WHERE     
       		c.IdAgentClass=@IdAgentClass 
       	and c.IdAgentStatus=@IdAgentStatus 
       	AND ((AmountByLastDay>0 and ag.idagentcollecttype in (1,2)) 
       		or (ag.idagentcollecttype not in (1,2)) 
       		or (AmountByLastDay>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ) 
       		or (AmountByCalendar>0 and (ag.idagentstatus=3 or ag.idagentstatus=7) ))
        group by   isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),c.IdAgent,c.AgentCode,c.AgentState,c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0)
    )t
    left join
    /*(
        --select idagent,SUM(amount) dep  from agentdeposit (nolock) WHERE dbo.RemoveTimeFromDatetime(DateOfLastChange)=@CollectDate group by idagent
    )d*/#deposits d on t.idagent=d.idagent
    ORDER BY 
        AgentCode, agentName, AgentState, OwnerName
        
/*        
DROP TABLE #Collect
DROP TABLE #deposits
DROP TABLE #LastMaxiCollectionAsign     
*/

