CREATE Procedure [Corp].[st_GetMaxiCollectionByClass]
(
    @CollectDate DATETIME,
    @IdAgentStatus int,
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

--Inicializacion de variables
SELECT @CollectDate=dbo.RemoveTimeFromDatetime(@CollectDate)

select @IsAdmin=isadmin from [CollectionUsers] WITH (NOLOCK) where iduser=@IdUser
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
    exec [Corp].[st_GetAgentAllCollection] @CollectDate
END

delete from #Collect where (IdAgentCollectType=1 and IdAgentStatus!=3 and IdAgentStatus!=7)

if (isnull(@AllStatus,0)=0)
begin
    delete from #Collect where IdAgentStatus=2 or IdAgentStatus=6 or IdAgentStatus=5
end

if @IsAdmin=1
SELECT 
    c.IdAgentClass, 
    s.Name AgentClass,
    SUM(AmountByCalendar) AmountByCalendar, 
    SUM(AmountByLastDay) AmountByLastDay, 
    SUM(AmountByCollectPlan) AmountByCollectPlan, 
    SUM(CollectAmount) CollectAmount
FROM 
    #Collect c
JOIN 
    dbo.AgentClass s WITH (NOLOCK) ON c.IdAgentClass=s.IdAgentClass
where 
    c.IdAgentStatus=@IdAgentStatus
GROUP BY 
    c.IdAgentClass,s.name  
HAVING
    round(SUM(AmountByCalendar)+SUM(AmountByLastDay)+SUM(AmountByCollectPlan),2)>0
ORDER BY 
    s.name
else

SELECT 
    c.IdAgentClass, 
    s.Name AgentClass,
    SUM(AmountByCalendar) AmountByCalendar, 
    SUM(AmountByLastDay) AmountByLastDay, 
    SUM(AmountByCollectPlan) AmountByCollectPlan, 
    SUM(CollectAmount) CollectAmount
FROM 
    #Collect c
JOIN 
    dbo.AgentClass s WITH (NOLOCK) ON c.IdAgentClass=s.IdAgentClass
where 
    c.IdAgentStatus=@IdAgentStatus and 
	(
		(c.idagent in (select idagent from MaxiCollectionAssign WITH (NOLOCK) where iduser=@IdUser and DateOfAssign=@CollectDate))
		or
		(c.idagent in (select idagent from collection.Group_Assigment WITH (NOLOCK) where IdUserAssign=@IdUser))
	)
GROUP BY 
    c.IdAgentClass,s.name 
HAVING
    round(SUM(AmountByCalendar)+SUM(AmountByLastDay)+SUM(AmountByCollectPlan),2)>0
ORDER BY 
    s.name
