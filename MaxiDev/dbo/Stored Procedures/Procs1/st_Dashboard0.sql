create Procedure [dbo].[st_Dashboard0]
(
@WeeksAgo int,
@NowWithTime Datetime,
@Increment numeric(8,2),
@IdUserSeller int,
@IdUserRequester int,
@OnlyActiveAgents bit
)
as
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
Select @CurrentMonthED=@Now

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
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @StartDate and T.DateOfTransfer<@EndDate
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @StartDate and T.DateStatusChange<@EndDate and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @StartDate and T.DateStatusChange<@EndDate and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
	) LT
group by AgentState


------ Number of transaction Today   ------------------------


Select SUM(NumTran) as TotalToday, AgentState into #T2
	from(
		select SUM(1) as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @NowStart and T.DateOfTransfer<@Now
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @NowStart and T.DateOfTransfer<@Now
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @NowStart and T.DateStatusChange<@Now and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @NowStart and T.DateStatusChange<@Now and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
	) LT
group by AgentState


------ Number of transaction One Month ago ------------------------

Select SUM(NumTran) as TotalOneMonthAgo, AgentState into #T3 
	from(
		select SUM(1) as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @OneMonthAgoSD and T.DateOfTransfer<@OneMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @OneMonthAgoSD and T.DateOfTransfer<@OneMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @OneMonthAgoSD and T.DateStatusChange<@OneMonthAgoED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @OneMonthAgoSD and T.DateStatusChange<@OneMonthAgoED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
	) LT
group by AgentState


------ Number of transaction Two Month ago ------------------------

Select SUM(NumTran) as TotalTwoMonthAgo, AgentState into #T4
	from(
		select SUM(1) as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @TwoMonthAgoSD and T.DateOfTransfer<@TwoMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @TwoMonthAgoSD and T.DateOfTransfer<@TwoMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @TwoMonthAgoSD and T.DateStatusChange<@TwoMonthAgoED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @TwoMonthAgoSD and T.DateStatusChange<@TwoMonthAgoED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
	) LT
group by AgentState


------ Number of transaction Three Month ago ------------------------

Select SUM(NumTran) as TotalThreeMonthAgo, AgentState into #T5
	from(
		select SUM(1) as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @ThreeMonthAgoSD and T.DateOfTransfer<@ThreeMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @ThreeMonthAgoSD and T.DateOfTransfer<@ThreeMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @ThreeMonthAgoSD and T.DateStatusChange<@ThreeMonthAgoED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @ThreeMonthAgoSD and T.DateStatusChange<@ThreeMonthAgoED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
	) LT
group by AgentState


------ Number of transaction Current Month ------------------------

Select SUM(NumTran) as TotalCurrentMonth, AgentState into #T6
	from(
		select SUM(1) as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @CurrentMonthSD and T.DateOfTransfer<@CurrentMonthED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1) as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateOfTransfer>= @CurrentMonthSD and T.DateOfTransfer<@CurrentMonthED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @CurrentMonthSD and T.DateStatusChange<@CurrentMonthED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
			
		union all
		select SUM(1)*-1 as NumTran, A.AgentState from TransferClosed T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where T.DateStatusChange>= @CurrentMonthSD and T.DateStatusChange<@CurrentMonthED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
		group by A.AgentState
	) LT
group by AgentState



Select distinct AgentState as AgentState into #T0 From Agent where (@OnlyActiveAgents=0 Or(IdAgentStatus in (1,4))) 
													And (@IsAllSeller = 1 Or (IdUserSeller = @IdUserSeller or IdUserSeller in (select IdSeller from #SellerSubordinates)))


Create Table #T7
(
AgentState nvarchar(max),
TotalThreeMonthAgo int,
TotalTwoMonthAgo int,
TotalOneMonthAgo int,
TotalCurrentMonth int,
TransfersStatusToTarget int,
TransferTarget Decimal(9,2),
TargetColor int,
TotalWeekAgo int,
TotalToday int,
TotalColor int,
TotalStatus int
)

Insert #T7 (AgentState,TotalThreeMonthAgo,TotalTwoMonthAgo,TotalOneMonthAgo,
TotalCurrentMonth,TotalWeekAgo,TotalToday)
Select A.AgentState,TotalThreeMonthAgo,TotalTwoMonthAgo,TotalOneMonthAgo,
TotalCurrentMonth,TotalWeeksAgo,TotalToday From #T0 A
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


Update #T7 set TransferTarget=((TotalThreeMonthAgo+TotalTwoMonthAgo+TotalOneMonthAgo)/3)*(1+(@Increment/100))
Update #T7 set TotalStatus=TotalToday-TotalWeekAgo
Update #T7 set TransfersStatusToTarget=TotalCurrentMonth-((@DayOfMonth*TransferTarget)/@TotalDaysOfCurrentMonth)
Update #T7 set TargetColor=case  when TransfersStatusToTarget>0 then 1 When  TransfersStatusToTarget<0 then 2 When TransfersStatusToTarget=0 Then 0 End
Update #T7 set TotalColor=case  when TotalStatus>0 then 1 When  TotalStatus<0 then 2 When TotalStatus=0 Then 0 End

Select 
AgentState,
TotalThreeMonthAgo,
0.0 AverageAmountInDollarsThreeMonthAgo,
TotalTwoMonthAgo,
0.0 AverageAmountInDollarsTwoMonthAgo,
TotalOneMonthAgo,
0.0 AverageAmountInDollarsOneMonthAgo,
TotalCurrentMonth,
0.0 TotalAmountInDollarsCurrentMonth,

TransfersStatusToTarget,ROUND(TransferTarget,0) TransferTarget,TargetColor,TotalWeekAgo,TotalToday,TotalColor,TotalStatus from #T7
--where   (TotalThreeMonthAgo>0 or TotalTwoMonthAgo>0 or TotalOneMonthAgo>0 or TotalCurrentMonth>0 or TotalWeekAgo>0 or TotalToday>0 )
Order by  AgentState

