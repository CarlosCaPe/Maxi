
CREATE procedure [dbo].[st_ApplyDepositMaxicollectionForWeekend]
(
    @idagent int,
    @ApplyDate datetime,
    @TempAmount money
)
as

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
<log Date="17/12/2018" Author="jmolina">Add ; in Insert/Update </log>
</ChangeLog>
********************************************************************/
SET NOCOUNT ON;
BEGIN TRY
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
		from [dbo].agent WITH(NOLOCK)
		where idagent=@idagent

		if exists (select 1 from [dbo].maxicollection with(nolock) where idagent=@IdAgent and IdAgentCollectType=@IdAgentCollectType and DateOfCollection=@DateMaxi)
		begin
			update [dbo].maxicollection set CollectAmount=CollectAmount+@TempAmount, IdAgentClass=@IdAgentClass, IdAgentStatus=@IdAgentStatus where idagent=@IdAgent and IdAgentCollectType=@IdAgentCollectType and DateOfCollection=@DateMaxi;
		end
		else
		begin
			insert into [dbo].maxicollection 
				(IdAgent, Amount, CollectAmount, IdAgentCollectType, DateOfCollection, IdAgentClass, IdAgentStatus, AmountByCalendar, AmountByLastDay, AmountByCollectPlan)
			values
				(@IdAgent,0,@TempAmount,@IdAgentCollectType,@DateMaxi,@IdAgentClass,@IdAgentStatus, 0, 0, 0);
		end
	end


END TRY
BEGIN CATCH
    DECLARE @ErrorMessage NVARCHAR(MAX)
    SELECT @ErrorMessage=ERROR_MESSAGE()
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_ApplyDepositMaxicollectionForWeekend', GETDATE(), @ErrorMessage)
END CATCH