CREATE PROCEDURE [dbo].[st_SaveMaxiCollection]
(
    @CollectDate DATETIME
)
as
--declaracion de variables
declare @IdCollect int
declare @IdAgent int
declare @CollectAmount money
declare @IdAgentCollectType int
declare @IdAgentClass int
declare @IdAgentStatus int
declare @AmountByCalendar MONEY
declare @AmountByLastDay MONEY 
declare @AmountByCollectPlan MONEY

CREATE TABLE #Collect
(
    IdCollect int identity (1,1) not null,
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
INSERT INTO #Collect
exec st_GetAgentAllCollection @CollectDate

While exists (Select top 1 1 from #Collect)      
Begin   
     
     select top 1 
        @IdCollect=IdCollect,
        @IdAgent=IdAgent,
        @IdAgentCollectType=IdAgentCollectType,
        @IdAgentClass=IdAgentClass,
        @IdAgentStatus=IdAgentStatus,
        @CollectAmount=CollectAmount,
        @AmountByCalendar=AmountByCalendar,
        @AmountByLastDay=AmountByLastDay,
        @AmountByCollectPlan=AmountByCollectPlan 
     from 
        #Collect
    
     if exists (select top 1 1 from maxicollection where idagent=@IdAgent and IdAgentCollectType=@IdAgentCollectType and DateOfCollection=@CollectDate)
     begin
        update maxicollection set CollectAmount=@CollectAmount, IdAgentClass=@IdAgentClass, IdAgentStatus=@IdAgentStatus where idagent=@IdAgent and IdAgentCollectType=@IdAgentCollectType and DateOfCollection=@CollectDate
     end
     else
     begin
        insert into maxicollection 
        (IdAgent, Amount, CollectAmount, IdAgentCollectType, DateOfCollection, IdAgentClass, IdAgentStatus, AmountByCalendar, AmountByLastDay, AmountByCollectPlan)
        values
        (@IdAgent,@AmountByCalendar+@AmountByLastDay+@AmountByCollectPlan,@CollectAmount,@IdAgentCollectType,@CollectDate,@IdAgentClass,@IdAgentStatus, @AmountByCalendar, @AmountByLastDay, @AmountByCollectPlan)
     end

     Delete #Collect where IdCollect=@IdCollect     
end 