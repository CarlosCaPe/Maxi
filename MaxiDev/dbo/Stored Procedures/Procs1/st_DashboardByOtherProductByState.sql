
CREATE Procedure [dbo].[st_DashboardByOtherProductByState]
(
    @IdOtherProduct int,
    @WeeksAgo int,
    @NowWithTime Datetime,
    @Increment numeric(8,2),
    @IdUserSeller int,
    @State nvarchar(2),
    @IdUserRequester int,    
    @StatusesPreselected XML
)
as
Set nocount on

Create Table #DashboardByOtherProductByState
(
    IdAgent int,
    AgentCode nvarchar(max),
    AgentName nvarchar(max),
    AgentStatus nvarchar(max),
    IdStatus int,
    IdOtherProduct int,
    OtherProduct nvarchar(max),
    TotalThreeMonthAgo int,
    AverageAmountInDollarsThreeMonthAgo money,
    TotalTwoMonthAgo int,
    AverageAmountInDollarsTwoMonthAgo money,
    TotalOneMonthAgo int,
    AverageAmountInDollarsOneMonthAgo money,
    TotalCurrentMonth int,
    AverageInDollarsCurrentMonth money,
    TransfersStatusToTarget int,
    TransferTarget Decimal(9,2),
    TargetColor int,
    TotalWeekAgo int,
    TotalToday int,
    TotalColor int,
    TotalStatus int
)

--1 Billpaumet BP
--5	Long Distance LD
--6	Top Up TU

if (@IdOtherProduct=1) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [st_DashboardbyOtherProductByStateBP]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=5) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    --exec [st_DashboardbyOtherProductByStateLD]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
    exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=6) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    --exec [st_DashboardbyOtherProductByStateTU]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
    exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end


if (@IdOtherProduct=8) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [st_DashboardbyOtherProductByStateBBP]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end


if (@IdOtherProduct=7) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [st_DashboardbyOtherProductByStateTTU]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=9) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=10) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=11) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=12) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=13) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
		exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=14) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=16) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
		exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=17) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
		exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=18) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
		exec st_DashboardbyOtherProductByStateLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

Select     
    idagent,
    AgentCode, 
    AgentName, 
    AgentStatus, 
    IdStatus,
    IdOtherProduct,
    OtherProduct,
    TotalThreeMonthAgo,    
    TotalTwoMonthAgo,    
    TotalOneMonthAgo,    
	TotalCurrentMonth,    
    TransfersStatusToTarget,
    ROUND(TransferTarget,0) TransferTarget,
    TargetColor,
    TotalWeekAgo,
    TotalToday,    
    TotalStatus,
    TotalColor,
    AverageAmountInDollarsThreeMonthAgo,
    AverageAmountInDollarsTwoMonthAgo,
    AverageAmountInDollarsOneMonthAgo,
    AverageInDollarsCurrentMonth
from #DashboardByOtherProductByState t 
order by AgentCode,OtherProduct