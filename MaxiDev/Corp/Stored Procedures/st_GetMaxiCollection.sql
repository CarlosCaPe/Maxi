CREATE Procedure [Corp].[st_GetMaxiCollection]
(
    @CollectDate DATETIME,
    @IdUser int,
    @AllStatus bit = null
)
as
SET ARITHABORT ON
--declaracion de variables
declare @IsAdmin int
declare @IsUser int
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

select @IsUser=IsUser from [CollectionUsers] with(nolock) where iduser=@IdUser
set @IsUser=isnull(@IsUser,0)

--Obtener de historico
IF (@CollectDate<dbo.RemoveTimeFromDatetime(GETDATE()))
BEGIN   
	print 'all' 
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
    exec [Corp].[st_GetAgentAllCollection] @CollectDate
END

delete from #Collect where (IdAgentCollectType=1 and IdAgentStatus!=3 and IdAgentStatus!=7)

if (isnull(@AllStatus,0)=0)
begin
    delete from #Collect where IdAgentStatus=2 or IdAgentStatus=6 or IdAgentStatus=5
end

IF (@IsAdmin=1 OR @IsUser=1)  --DAG 08/05/17
begin
SELECT 
    c.IdAgentStatus, 
    AgentStatus,
    SUM(AmountByCalendar) AmountByCalendar, 
    SUM(AmountByLastDay) AmountByLastDay, 
    SUM(AmountByCollectPlan) AmountByCollectPlan, 
    SUM(CollectAmount) CollectAmount    
FROM 
    #Collect c
JOIN 
    dbo.AgentStatus s with(nolock) ON c.IdAgentStatus=s.IdAgentStatus
GROUP BY 
    c.IdAgentStatus,AgentStatus
HAVING
    round(SUM(AmountByCalendar)+SUM(AmountByLastDay)+SUM(AmountByCollectPlan),2)>0
ORDER BY AgentStatus
end
else
begin
SELECT 
    c.IdAgentStatus, 
    AgentStatus,
    SUM(AmountByCalendar) AmountByCalendar, 
    SUM(AmountByLastDay) AmountByLastDay, 
    SUM(AmountByCollectPlan) AmountByCollectPlan, 
    SUM(CollectAmount) CollectAmount
FROM 
    #Collect c
JOIN 
    dbo.AgentStatus s with(nolock) ON c.IdAgentStatus=s.IdAgentStatus
where 
	(
		c.idagent in (select idagent from MaxiCollectionAssign with(nolock) where iduser=@IdUser and DateOfAssign=@CollectDate)
		or
		c.idagent in (select idagent from collection.Group_Assigment with(nolock) where IdUserAssign=@IdUser)
	)
GROUP BY 
    c.IdAgentStatus,AgentStatus
HAVING
    round(SUM(AmountByCalendar)+SUM(AmountByLastDay)+SUM(AmountByCollectPlan),2)>0
ORDER BY AgentStatus

end


