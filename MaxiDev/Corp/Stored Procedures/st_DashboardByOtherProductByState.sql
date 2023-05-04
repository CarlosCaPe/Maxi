
/********************************************************************
<Author>--</Author>
<app>Chronos</app>
<Description>Obtiene definición de Dashboard por estado, según Other Product indicado.</Description>

<ChangeLog>
<log Date="21/07/2022" Author="jdarellano" Name="#1">Se agrega condición para Other Product Bp, proveedor Fiserv.</log>
<log Date="28/07/2022" Author="jdarellano" Name="#2">Fix: Se agrega variable @State a la llamada del proveedor Fiserv.</log>
</ChangeLog>
*********************************************************************/

CREATE PROCEDURE [Corp].[st_DashboardByOtherProductByState]
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
    exec [Corp].[st_DashboardbyOtherProductByStateBP]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=5) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    --exec [Corp].[st_DashboardbyOtherProductByStateLD]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
    exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=6) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    --exec [Corp].[st_DashboardbyOtherProductByStateTU]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
    exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end


if (@IdOtherProduct=8) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [Corp].[st_DashboardbyOtherProductByStateBBP]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end


if (@IdOtherProduct=7) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [Corp].[st_DashboardbyOtherProductByStateTTU]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=9) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=10) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=11) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=12) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=13) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
		exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=14) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
    exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=16) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
		exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=17) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
		exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=18) or (@IdOtherProduct is null)
begin    
    insert into #DashboardByOtherProductByState
		exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=19) or (@IdOtherProduct is null)--#1
begin    
    insert into #DashboardByOtherProductByState
    exec [Corp].[st_DashboardbyOtherProductByStateLN]   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@State,@IdUserRequester,@StatusesPreselected--#2
end--#1

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
