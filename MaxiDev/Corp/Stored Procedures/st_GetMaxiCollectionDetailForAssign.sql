CREATE PROCEDURE [Corp].[st_GetMaxiCollectionDetailForAssign]
(
    @CollectDate 	DATETIME,
    @IdAgentStatus 	INT,
    @IdAgentClass 	INT,
    @IdUser 		INT
)
AS

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
SELECT @CollectDate = convert(DATE, @CollectDate)

SELECT @IsAdmin = isadmin FROM [CollectionUsers] WHERE iduser = @IdUser
SET @IsAdmin = isnull(@IsAdmin, 0)


--Obtener de historico
IF (@CollectDate < convert(DATE, GETDATE()))
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
    FROM MaxiCollection m (nolock)
    JOIN dbo.Agent a (nolock) ON m.idagent = a.idagent
    WHERE m.dateofcollection >= @CollectDate AND m.dateofcollection < dateadd(day, 1, @CollectDate)
    ORDER BY AgentCode
END
ELSE
BEGIN
    INSERT INTO #Collect
    EXEC st_GetAgentAllCollectionForAssign @CollectDate
END

DELETE FROM #Collect WHERE (IdAgentCollectType=1 AND IdAgentStatus!=3 AND IdAgentStatus!=7)


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


SELECT idagent, SUM(amount) dep  
INTO #deposits 
FROM agentdeposit (nolock) 
WHERE DateOfLastChange >= @CollectDate 
	AND DateOfLastChange < dateadd(day,1,@CollectDate) 
GROUP BY idagent

if @IsAdmin=1
    select t.IdAgent,AgentCode,AgentState,AgentName,OwnerName,AmountByCalendar,AmountByLastDay,AmountByCollectPlan,CollectAmount+isnull(dep,0) CollectAmount,DateOfDebit,DateOfLNPD LNPD,IdUser,UserLogin,CallStatus,CallDate, Revision, DepositAmount, case when DateOfDebit is not null then isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=t.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) else 0 end AmountHisDebt 
    from
    (
        SELECT
            c.IdAgent,
            c.AgentCode,
            c.AgentState,
            c.AgentName,
            isnull(o.Name, '') + ' ' + isnull(o.lastname, '') + ' ' + isnull(o.secondlastname, '') AS OwnerName,
            Sum(c.AmountByCalendar) AS AmountByCalendar,
            sum(c.AmountByLastDay) AS AmountByLastDay, 
            sum(c.AmountByCollectPlan) AS AmountByCollectPlan,
            sum(c.CollectAmount) AS CollectAmount,
            d.DateOfDebit,
            d.DateOfLNPD,
            isnull(a.IdUser,0) AS IdUser,
            isnull(u.username,'Unassigned') AS UserLogin,
            dbo.fn_GetCallStatus(c.idagent,@CollectDate) AS CallStatus,
            dbo.fn_GetCallDate(c.idagent,@CollectDate) AS CallDate, 
            isnull(Revision,0) AS Revision, 
            isnull(DepositAmount,0) AS DepositAmount
        FROM 
            #Collect c
        INNER JOIN owner o (nolock) ON o.idowner = c.idowner       
        INNER JOIN agent ag (nolock) ON ag.idagent = c.idagent
        LEFT JOIN #LastMaxiCollectionAssign a (nolock) ON a.idagent = c.idagent 
        LEFT JOIN users u (nolock) ON u.iduser = a.iduser
        LEFT JOIN maxicollectiondetail d (nolock) ON d.idagent = c.idagent 
        	 									AND dateofcollection = @CollectDate
        LEFT JOIN [AgentCollectionRevision] r ON r.idagent=c.idagent
       	WHERE  c.IdAgentClass = @IdAgentClass 
        	AND c.IdAgentStatus = @IdAgentStatus
      		AND ((AmountByLastDay > 0 AND ag.idagentcollecttype IN (1,2))
         	OR (ag.idagentcollecttype not in (1,2)) 
         	OR (AmountByLastDay>0 AND (ag.idagentstatus=3 OR ag.idagentstatus=7) ) 
         	OR (AmountByCalendar>0 AND (ag.idagentstatus=3 OR ag.idagentstatus=7) ))
        GROUP BY isnull(o.Name, '') + ' ' + isnull(o.lastname, '') + ' ' + isnull(o.secondlastname, ''), c.IdAgent, c.AgentCode, c.AgentState, c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0)
    )t
    LEFT JOIN #deposits d ON t.idagent = d.idagent
    ORDER BY AgentCode, agentName, AgentState, OwnerName
ELSE
SELECT t.IdAgent,AgentCode,AgentState, AgentName, OwnerName, AmountByCalendar, AmountByLastDay, AmountByCollectPlan,CollectAmount+isnull(dep,0) CollectAmount,DateOfDebit,DateOfLNPD LNPD,IdUser,UserLogin,CallStatus,CallDate, Revision, DepositAmount, case when DateOfDebit is not null then isnull((select top 1 sum(amount)-sum(collectamount) amount from maxicollection m where dateofcollection < @CollectDate and  m.Idagent=t.idagent group by m.idagent,dateofcollection order by dateofcollection desc),0) else 0 end AmountHisDebt 
FROM 
    (
        select
            c.IdAgent,
            c.AgentCode, 
            c.AgentState, 
            c.AgentName,
            isnull(o.Name,'')+' '+isnull(o.lastname,'')+' '+isnull(o.secondlastname,'') AS OwnerName,
            Sum(c.AmountByCalendar) AS AmountByCalendar,
            sum(c.AmountByLastDay) AS AmountByLastDay, 
            sum(c.AmountByCollectPlan) AS AmountByCollectPlan,
            sum(c.CollectAmount) AS CollectAmount,
            d.DateOfDebit,
            d.DateOfLNPD,
            isnull(a.IdUser,0) AS IdUser,
            isnull(u.username,'Unassigned') AS UserLogin,
            dbo.fn_GetCallStatus(c.idagent,@CollectDate) AS CallStatus,
            dbo.fn_GetCallDate(c.idagent,@CollectDate) AS CallDate, 
            isnull(Revision,0) Revision, isnull(DepositAmount,0) AS DepositAmount
        FROM 
            #Collect c 
        INNER JOIN owner o (nolock) ON c.idowner = o.idowner       
        INNER JOIN agent ag (nolock) ON c.idagent = ag.idagent
        LEFT JOIN #LastMaxiCollectionAssign a (nolock) ON a.idagent = c.idagent 
        LEFT JOIN users u (nolock) ON u.iduser = a.iduser
        LEFT JOIN maxicollectiondetail d (nolock) ON d.idagent = c.idagent 
        										AND dateofcollection = @CollectDate
        LEFT JOIN [AgentCollectionRevision] r ON r.idagent = c.idagent
       	WHERE     
       		c.IdAgentClass = @IdAgentClass 
       	AND c.IdAgentStatus = @IdAgentStatus 
       	AND ((AmountByLastDay > 0 AND ag.idagentcollecttype IN (1, 2)) 
       		OR (ag.idagentcollecttype NOT IN (1, 2)) 
       		OR (AmountByLastDay > 0 AND (ag.idagentstatus = 3 OR ag.idagentstatus = 7) ) 
       		OR (AmountByCalendar > 0 AND (ag.idagentstatus = 3 OR ag.idagentstatus = 7) ))
        GROUP BY isnull(o.Name,'') + ' ' + isnull(o.lastname, '') + ' ' + isnull(o.secondlastname, ''), c.IdAgent, c.AgentCode,c.AgentState,c.AgentName,a.iduser,u.username,d.DateOfDebit,d.DateOfLNPD, isnull(Revision,0), isnull(DepositAmount,0)
    ) t
    LEFT JOIN #deposits d ON t.idagent = d.idagent
    ORDER BY AgentCode, agentName, AgentState, OwnerName
        
        
DROP TABLE #deposits
DROP TABLE #Collect   
DROP TABLE #LastMaxiCollectionAssign


