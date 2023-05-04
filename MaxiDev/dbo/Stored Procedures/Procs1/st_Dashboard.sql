CREATE Procedure [dbo].[st_Dashboard]
(
    @WeeksAgo int,
    @NowWithTime Datetime,
    @Increment numeric(8,2),
    @IdUserSeller int,
    @IdUserRequester int,
    --@OnlyActiveAgents bit
    @StatusesPreselected XML
)
as
Set nocount on

Declare @tStatus table    
      (    
       id int    
      )    
    
Declare @DocHandle int    
Declare @hasStatus bit    
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @StatusesPreselected      

insert into @tStatus(id)     
select id    
FROM OPENXML (@DocHandle, '/statuses/status',1)     
WITH (id int)      
    
EXEC sp_xml_removedocument @DocHandle    

Declare @Now Datetime,@EndDate Datetime, @StartDate Datetime, @NowStart Datetime
Declare @OneMonthAgoSD DateTime,@OneMonthAgoED DateTime
Declare @TwoMonthAgoSD DateTime,@TwoMonthAgoED DateTime
Declare @ThreeMonthAgoSD DateTime,@ThreeMonthAgoED DateTime
Declare @CurrentMonthSD DateTime,@CurrentMonthED DateTime
Declare @DayOfMonth int,@TotalDaysOfCurrentMonth int

Set @Now=@NowWithTime
Select @NowStart=dbo.RemoveTimeFromDatetime(@Now)
Set @EndDate=DATEADD(WEEK,@WeeksAgo*-1,@Now)
Select  @StartDate=dbo.RemoveTimeFromDatetime(@EndDate)

Set @DayOfMonth=DAY(@Now)
Set @TotalDaysOfCurrentMonth=DAY(DATEADD(d, -DAY(DATEADD(m,1,@Now)),DATEADD(m,1,@Now)))

Select @OneMonthAgoSD= dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-1,@Now))
Select @OneMonthAgoSD=DATEADD(DAY,(DATEPART(day,@OneMonthAgoSD))*-1+1 ,@OneMonthAgoSD)
Select @OneMonthAgoED=DATEADD(MONTH,+1,@OneMonthAgoSD)


Select @TwoMonthAgoSD= dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-2,@Now))
Select @TwoMonthAgoSD=DATEADD(DAY,(DATEPART(day,@TwoMonthAgoSD))*-1+1 ,@TwoMonthAgoSD)
Select @TwoMonthAgoED=DATEADD(MONTH,+1,@TwoMonthAgoSD)

Select @ThreeMonthAgoSD= dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-3,@Now))
Select @ThreeMonthAgoSD=DATEADD(DAY,(DATEPART(day,@ThreeMonthAgoSD))*-1+1 ,@ThreeMonthAgoSD)
Select @ThreeMonthAgoED=DATEADD(MONTH,+1,@ThreeMonthAgoSD)

Select @CurrentMonthSD= dbo.RemoveTimeFromDatetime(@Now)
Select @CurrentMonthSD=DATEADD(DAY,(DATEPART(day,@CurrentMonthSD))*-1+1 ,@CurrentMonthSD)
Select @CurrentMonthED=dbo.RemoveTimeFromDatetime(@Now)+1

--Select @Now,@EndDate,@StartDate,@OneMonthAgoSD,@OneMonthAgoED,@TwoMonthAgoSD,@TwoMonthAgoED,@ThreeMonthAgoSD,@ThreeMonthAgoED,@CurrentMonthSD,@CurrentMonthED

declare @IsAllSeller bit 
set @IsAllSeller = (Select top 1 1 From [Users] where @IdUserSeller=0 and [IdUser] = @IdUserRequester and [IdUserType] = 1) 

Create Table #SellerSubordinates
	(
		IdSeller int
	)
Insert into #SellerSubordinates 
Select IdUserSeller From [Seller] Where @IdUserSeller=0 and ([IdUserSellerParent] = @IdUserRequester or [IdUserSeller] = @IdUserRequester)

------ Number of transaction Same hours weeks ago ------------------------

Select SUM(NumTran) as TotalWeeksAgo, AgentState into #T1
	from(
		select SUM(1) as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @StartDate and T.DateOfTransfer<@EndDate
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @StartDate and T.DateOfTransfer<@EndDate
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @StartDate and T.DateStatusChange<@EndDate and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @StartDate and T.DateStatusChange<@EndDate and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
	) LT
group by AgentState


------ Number of transaction Today   ------------------------


Select SUM(NumTran) as TotalToday,sum(AmountInDollars) TotalAmountInDollarsToday, AgentState into #T2
	from(
		select SUM(1) as NumTran,sum(Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2)) AmountInDollars, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @NowStart and T.DateOfTransfer<@Now
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran,sum(Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2)) AmountInDollars,A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @NowStart and T.DateOfTransfer<@Now
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran,(-1)*sum(Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2)) AmountInDollars, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
        left join dbo.TransferNotAllowedResend TA on T.IdTransfer=TA.IdTransfer  
		where T.DateStatusChange>= @NowStart and T.DateStatusChange<@Now and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran,(-1)*sum(Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2)) AmountInDollars, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
        left join dbo.TransferNotAllowedResend TA on T.IdTransferClosed=TA.IdTransfer  
		where T.DateStatusChange>= @NowStart and T.DateStatusChange<@Now and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
	) LT
group by AgentState


------ Number of transaction One Month ago ------------------------

Select SUM(NumTran) as TotalOneMonthAgo,sum(AmountInDollars) TotalAmountInDollarsOneMonthAgo, AgentState into #T3 
	from(
		select Numtran, AmountInDollars, A.AgentState from Dashboard T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.Date>= @OneMonthAgoSD and T.Date<@OneMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))		
                and a.idagentstatus in (select id from @tStatus)			
	) LT
group by AgentState


------ Number of transaction Two Month ago ------------------------

Select SUM(NumTran) as TotalTwoMonthAgo,sum(AmountInDollars) TotalAmountInDollarsTwoMonthAgo, AgentState into #T4
	from(
		select Numtran, AmountInDollars, A.AgentState from Dashboard T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.Date>= @TwoMonthAgoSD and T.Date<@TwoMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)		
	) LT
group by AgentState


------ Number of transaction Three Month ago ------------------------

Select SUM(NumTran) as TotalThreeMonthAgo,sum(AmountInDollars) TotalAmountInDollarsThreeMonthAgo, AgentState into #T5
	from(
		select Numtran, AmountInDollars, A.AgentState from Dashboard T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.Date>= @ThreeMonthAgoSD and T.Date<@ThreeMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))		
                and a.idagentstatus in (select id from @tStatus)		
	) LT
group by AgentState


------ Number of transaction Current Month ------------------------

Select SUM(NumTran) as TotalCurrentMonth,sum(AmountInDollars) TotalAmountInDollarsCurrentMonth, AgentState into #T6
	from(
		select SUM(1) as NumTran,sum(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0)) AmountInDollars, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @CurrentMonthSD and T.DateOfTransfer<@CurrentMonthED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran,sum(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0)) AmountInDollars, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @CurrentMonthSD and T.DateOfTransfer<@CurrentMonthED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran,(-1)*sum(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0)) AmountInDollars, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @CurrentMonthSD and T.DateStatusChange<@CurrentMonthED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran,(-1)*sum(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0)) AmountInDollars, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @CurrentMonthSD and T.DateStatusChange<@CurrentMonthED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
		group by A.AgentState
	) LT
group by AgentState

--create table #T6
--(
--    TotalCurrentMonth int,
--    TotalAmountInDollarsCurrentMonth money,
--    AgentState nvarchar(max)
--)

--if dbo.RemoveTimeFromDatetime(@NowWithTime)=dbo.RemoveTimeFromDatetime(getdate())
--begin
--insert into #T6
--Select SUM(NumTran) as TotalCurrentMonth,sum(AmountInDollars) TotalAmountInDollarsCurrentMonth, AgentState --into #T6
--	from(
--		select Numtran, AmountInDollars, A.AgentState from Dashboard T
--		Join Agent A on (T.IdAgent=A.IdAgent)
--		where T.Date>= @CurrentMonthSD and T.Date<@CurrentMonthED
--				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))		
--                and a.idagentstatus in (select id from @tStatus)		
--        union all
--        select TotalToday Numtran,TotalAmountInDollarsToday AmountInDollars,AgentState from  #T2
--	) LT
--group by AgentState
--end
--else
--begin
--insert into #T6
--Select SUM(NumTran) as TotalCurrentMonth,sum(AmountInDollars) TotalAmountInDollarsCurrentMonth, AgentState --into #T6
--	from(
--		select Numtran, AmountInDollars, A.AgentState from Dashboard T
--		Join Agent A on (T.IdAgent=A.IdAgent)
--		where T.Date>= @CurrentMonthSD and T.Date<@CurrentMonthED
--				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))		
--                and a.idagentstatus in (select id from @tStatus)		        
--	) LT
--group by AgentState
--end

Select distinct AgentState as AgentState into #T0 From Agent where IdAgentStatus in (select id from @tStatus) 
													And (@IsAllSeller = 1 Or (IdUserSeller = @IdUserSeller or IdUserSeller in (select IdSeller from #SellerSubordinates)))


Create Table #T7
(
AgentState nvarchar(max),
TotalThreeMonthAgo int,
TotalAmountInDollarsThreeMonthAgo money,
TotalTwoMonthAgo int,
TotalAmountInDollarsTwoMonthAgo money,
TotalOneMonthAgo int,
TotalAmountInDollarsOneMonthAgo money,
TotalCurrentMonth int,
TotalAmountInDollarsCurrentMonth money,
TransfersStatusToTarget int,
TransferTarget Decimal(9,2),
TargetColor int,
TotalWeekAgo int,
TotalToday int,
TotalColor int,
TotalStatus int
)

Insert #T7 (AgentState,TotalThreeMonthAgo,TotalAmountInDollarsThreeMonthAgo,TotalTwoMonthAgo,TotalAmountInDollarsTwoMonthAgo,TotalOneMonthAgo,TotalAmountInDollarsOneMonthAgo,
TotalCurrentMonth,TotalAmountInDollarsCurrentMonth,TotalWeekAgo,TotalToday)
Select A.AgentState,TotalThreeMonthAgo,TotalAmountInDollarsThreeMonthAgo,TotalTwoMonthAgo,TotalAmountInDollarsTwoMonthAgo,TotalOneMonthAgo,TotalAmountInDollarsOneMonthAgo,
TotalCurrentMonth,TotalAmountInDollarsCurrentMonth,TotalWeeksAgo,TotalToday From #T0 A
Full JOIN #T1 B on (A.AgentState=B.AgentState)
Full join #T2 C on (A.AgentState=C.AgentState)
Full Join #T3 D on (A.AgentState=D.AgentState)
Full Join #T4 E on (A.AgentState=E.AgentState)
Full Join #T5 F on (A.AgentState=F.AgentState)
Full Join #T6 G on (A.AgentState=G.AgentState)

Update #T7 set TotalThreeMonthAgo=0 where TotalThreeMonthAgo is null
Update #T7 set TotalTwoMonthAgo=0 where TotalTwoMonthAgo is null
Update #T7 set TotalOneMonthAgo=0 where TotalOneMonthAgo is null
Update #T7 set TotalCurrentMonth=0 where TotalCurrentMonth is null
Update #T7 set TotalWeekAgo=0 where TotalWeekAgo is null
Update #T7 set TotalToday=0 where TotalToday is null
--nuevo
Update #T7 set TotalAmountInDollarsOneMonthAgo=0 where TotalAmountInDollarsOneMonthAgo is null
Update #T7 set TotalAmountInDollarsTwoMonthAgo=0 where TotalAmountInDollarsTwoMonthAgo is null
Update #T7 set TotalAmountInDollarsThreeMonthAgo=0 where TotalAmountInDollarsThreeMonthAgo is null
Update #T7 set TotalAmountInDollarsCurrentMonth=0 where TotalAmountInDollarsCurrentMonth is null

Update #T7 set TransferTarget=((TotalThreeMonthAgo+TotalTwoMonthAgo+TotalOneMonthAgo)/3)*(1+(@Increment/100))
Update #T7 set TotalStatus=TotalToday-TotalWeekAgo
Update #T7 set TransfersStatusToTarget=TotalCurrentMonth-((@DayOfMonth*TransferTarget)/@TotalDaysOfCurrentMonth)
Update #T7 set TargetColor=case  when TransfersStatusToTarget>0 then 1 When  TransfersStatusToTarget<0 then 2 When TransfersStatusToTarget=0 Then 0 End
Update #T7 set TotalColor=case  when TotalStatus>0 then 1 When  TotalStatus<0 then 2 When TotalStatus=0 Then 0 End

Select 
    AgentState,
    TotalThreeMonthAgo,
    round(case TotalThreeMonthAgo when 0 then 0 else TotalAmountInDollarsThreeMonthAgo/case when TotalThreeMonthAgo>0 then 1* TotalThreeMonthAgo else -1* TotalThreeMonthAgo end  end,2) AverageAmountInDollarsThreeMonthAgo,
    TotalTwoMonthAgo,
    round(case TotalTwoMonthAgo when 0 then 0 else TotalAmountInDollarsTwoMonthAgo/case when TotalTwoMonthAgo >0 then 1*  TotalTwoMonthAgo else -1*  TotalTwoMonthAgo end  end,2) AverageAmountInDollarsTwoMonthAgo,
    TotalOneMonthAgo,
    round(case TotalOneMonthAgo when 0 then 0 else TotalAmountInDollarsOneMonthAgo/case when TotalOneMonthAgo > 0 then 1* TotalOneMonthAgo else -1* TotalOneMonthAgo end  end,2) AverageAmountInDollarsOneMonthAgo,
    TotalCurrentMonth,
    round(case TotalCurrentMonth when 0 then 0 else TotalAmountInDollarsCurrentMonth/case when TotalCurrentMonth > 0 then 1* TotalCurrentMonth else -1* TotalCurrentMonth end  end,2) TotalAmountInDollarsCurrentMonth,
    TransfersStatusToTarget,
    ROUND(TransferTarget,0) TransferTarget,
    TargetColor,TotalWeekAgo,
    TotalToday,
    TotalColor,
    TotalStatus 
from #T7
--where   (TotalThreeMonthAgo>0 or TotalTwoMonthAgo>0 or TotalOneMonthAgo>0 or TotalCurrentMonth>0 or TotalWeekAgo>0 or TotalToday>0 )
Order by  AgentState