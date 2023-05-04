CREATE  Procedure [Corp].[st_GetMaxiCollectionDetail]
(
    @CollectDate DATETIME,
    @IdAgentStatus int,
    @IdAgentClass INT,
    @IdUser int,
    @AllStatus bit = null
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

/*
	DECLARE @SUPERTEXT VARCHAR(max)
	DECLARE @initializetime DATETIME = getdate()
	SET @SUPERTEXT='@CollectDate='+isnull(Convert(VARCHAR,@CollectDate),'NULL')
		+'@IdAgentStatus='+isnull(Convert(VARCHAR,@IdAgentStatus),'NULL')
		+'@IdAgentClass='+isnull(Convert(VARCHAR,@IdAgentClass),'NULL')
		+'@IdUser='+isnull(Convert(VARCHAR,@IdUser),'NULL')
		+'@AllStatus='+isnull(Convert(VARCHAR,@AllStatus),'NULL')
	
		*/
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
    from MaxiCollection m WITH (NOLOCK)
		JOIN dbo.Agent a WITH (NOLOCK) ON m.idagent=a.idagent
    WHERE m.dateofcollection=dbo.RemoveTimeFromDatetime(@CollectDate)
    ORDER BY AgentCode
END
ELSE
begin
    INSERT INTO #Collect
    exec st_GetAgentAllCollection @CollectDate
END


 CREATE NONCLUSTERED INDEX TMP_Collect1 ON #Collect (idAgentStatus)


 delete from #Collect where (IdAgentCollectType=1 and IdAgentStatus!=3 and IdAgentStatus!=7)

if (isnull(@AllStatus,0)=0)
begin
    delete from #Collect where IdAgentStatus=2 or IdAgentStatus=6 or IdAgentStatus=5
END


--Obtener la ultima asignacion de cada agencia
SELECT A.IdMaxiCollectionAssign, A.IdAgent, A.IdUser, A.DateOfAssign
INTO #LastMaxiCollectionAssign
FROM
(
	SELECT ROW_NUMBER() OVER (PARTITION BY IdAgent ORDER BY DateOfAssign DESC) AS rownum, *
	FROM MaxiCollectionAssign
	WHERE DateOfAssign <= @CollectDate
) A
WHERE A.rownum = 1

--paginar

if @IsAdmin=1
    select
        c.IdAgent, c.AgentCode,c.AgentState, c.AgentName,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,Sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay, sum(c.AmountByCollectPlan) AmountByCollectPlan,sum(c.CollectAmount) CollectAmount,d.DateOfDebit,d.DateOfLNPD LNPD,isnull(a.IdUser,0) IdUser,isnull(u.username,'Unassigned') UserLogin,dbo.fn_GetCallStatus(c.idagent,@CollectDate) CallStatus,dbo.fn_GetCallDate(c.idagent,@CollectDate) CallDate, isnull(Revision,0) Revision, isnull(DepositAmount,0) DepositAmount, case when DateOfDebit is not null then isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=c.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) else 0 end AmountHisDebt, 
		--ADD GROUP ASSIGMENT FIELDS
		c.IdAgentStatus,isnull(ga.idgroups,0) IdGroup,
		isnull(ga.groupname,'') GroupAssigned,isnull(ga.AgentClass,'') AgentClass,isnull(ga.username,'') GroupUserName

    FROM 
        #Collect c
    join owner o WITH (NOLOCK) on c.idowner=o.idowner       
    left join #LastMaxiCollectionAssign a WITH (NOLOCK) on a.idagent=c.idagent 
    left join users u WITH (NOLOCK) on a.iduser=u.iduser
    left join maxicollectiondetail d WITH (NOLOCK) on c.idagent=d.idagent and dateofcollection=@CollectDate
    left join [AgentCollectionRevision] r WITH (NOLOCK) on c.idagent=r.idagent
	left join collection.Group_Assigment ga WITH (NOLOCK) on ga.idagent=c.idagent
    WHERE c.IdAgentClass=case when @IdAgentClass=0 then c.IdAgentClass else @IdAgentClass end and c.IdAgentStatus= case when @IdAgentStatus=0 then c.IdAgentStatus else @IdAgentStatus end
    group by   isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),c.IdAgent,c.AgentCode, c.AgentState, c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0),
				--ADD GROUP ASSIGMENT FIELDS
				c.IdAgentStatus,ga.idgroups,
				ga.groupname,ga.AgentClass,ga.username
    HAVING
        round(SUM(AmountByCalendar)+SUM(AmountByLastDay)+SUM(AmountByCollectPlan),2)>0
   ORDER BY 
    AgentCode, agentName, AgentState, isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'')
else
    select
        c.IdAgent,c.AgentCode,c.AgentState, c.AgentName,isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') OwnerName,Sum(c.AmountByCalendar) AmountByCalendar,sum(c.AmountByLastDay) AmountByLastDay, sum(c.AmountByCollectPlan) AmountByCollectPlan,sum(c.CollectAmount) CollectAmount,d.DateOfDebit,d.DateOfLNPD LNPD,isnull(a.IdUser,0) IdUser,isnull(u.username,'Unassigned') UserLogin,dbo.fn_GetCallStatus(c.idagent,@CollectDate) CallStatus,dbo.fn_GetCallDate(c.idagent,@CollectDate) CallDate, isnull(Revision,0) Revision, isnull(DepositAmount,0) DepositAmount, case when DateOfDebit is not null then isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=c.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) else 0 end AmountHisDebt,
		--ADD GROUP ASSIGMENT FIELDS
		c.IdAgentStatus,isnull(ga.idgroups,0) IdGroup,
		isnull(ga.groupname,'') GroupAssigned,isnull(ga.AgentClass,'') AgentClass,isnull(ga.username,'') GroupUserName
    FROM 
        #Collect c
    join owner o WITH (NOLOCK) on c.idowner=o.idowner       
    left join #LastMaxiCollectionAssign a WITH (NOLOCK) on a.idagent=c.idagent
    left join users u WITH (NOLOCK) on a.iduser=u.iduser
    left join maxicollectiondetail d WITH (NOLOCK) on c.idagent=d.idagent and dateofcollection=@CollectDate
    left join [AgentCollectionRevision] r WITH (NOLOCK) on c.idagent=r.idagent
	left join collection.Group_Assigment ga WITH (NOLOCK) on ga.idagent=c.idagent
    WHERE c.IdAgentClass=case when @IdAgentClass=0 then c.IdAgentClass else @IdAgentClass end and c.IdAgentStatus=case when @IdAgentStatus=0 then c.IdAgentStatus else @IdAgentStatus end and 
	(	
		(c.idagent in (select idagent from MaxiCollectionAssign (nolock) where iduser=@IdUser and DateOfAssign=@CollectDate))
		or
		(c.idagent in (select idagent from collection.Group_Assigment (nolock) where IdUserAssign=@IdUser))
	)
	group by   isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,''),c.IdAgent,c.AgentCode, c.AgentState, c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0),
				--ADD GROUP ASSIGMENT FIELDS
				c.IdAgentStatus,ga.idgroups,
				ga.groupname ,ga.AgentClass,ga.username
    HAVING
        round(SUM(AmountByCalendar)+SUM(AmountByLastDay)+SUM(AmountByCollectPlan),2)>0
    ORDER BY 
    AgentCode, agentName, AgentState, isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'')
    
    DROP TABLE #Collect
    /*
	DECLARE @endproceduretime DATETIME = getdate()
	IF (datediff(millisecond,@initializetime,@endproceduretime) > 1500) BEGIN 
	INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure, ErrorDate, ErrorMessage) 
	VALUES ('st_GetMaxiCollectionDetail', getdate(),Convert(VARCHAR,datediff(millisecond,@initializetime,@endproceduretime))+'ms '+@SUPERTEXT)
	END 
	*/
	


