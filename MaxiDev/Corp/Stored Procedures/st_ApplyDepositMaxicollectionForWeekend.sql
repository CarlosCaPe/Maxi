CREATE PROCEDURE [Corp].[st_ApplyDepositMaxicollectionForWeekend]
(
    @idagent int,
    @ApplyDate datetime,
    @TempAmount money
)
as
SET NOCOUNT ON;
declare @today int
declare @DateMaxi datetime
        
Select  @today=[dbo].[GetDayOfWeek] (@ApplyDate)         
       
if @today=6 or @today=7
begin            
    select @DateMaxi = case 
                        when @today=6 then
                            @ApplyDate-1 
                        when @today=7 then
                            @ApplyDate-2
                        else
                            @ApplyDate
                        end

    declare @IdAgentCollectType int
    declare @IdAgentClass int
    declare @IdAgentStatus int 

    set @DateMaxi=[dbo].[RemoveTimeFromDatetime](@DateMaxi)

    select                
        @IdAgentCollectType=IdAgentCollectType,
        @IdAgentClass=IdAgentClass,               
        @IdAgentStatus=IdAgentStatus
    from agent with(nolock)
    where idagent=@idagent

    if exists (select top 1 1 from maxicollection with(nolock) where idagent=@IdAgent and IdAgentCollectType=@IdAgentCollectType and DateOfCollection=@DateMaxi)
    begin
        update maxicollection set CollectAmount=CollectAmount+@TempAmount, IdAgentClass=@IdAgentClass, IdAgentStatus=@IdAgentStatus where idagent=@IdAgent and IdAgentCollectType=@IdAgentCollectType and DateOfCollection=@DateMaxi
    end
    else
    begin
        insert into maxicollection 
            (IdAgent, Amount, CollectAmount, IdAgentCollectType, DateOfCollection, IdAgentClass, IdAgentStatus, AmountByCalendar, AmountByLastDay, AmountByCollectPlan)
        values
            (@IdAgent,0,@TempAmount,@IdAgentCollectType,@DateMaxi,@IdAgentClass,@IdAgentStatus, 0, 0, 0)
    end
end
