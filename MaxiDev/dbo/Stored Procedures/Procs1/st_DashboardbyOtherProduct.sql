/********************************************************************
<Author>UNKNOW</Author>
<app>Corporative</app>
<Description>Dashboard Reporte for other products</Description>

<ChangeLog>
<log Date="13/05/2019" Author="azavala">Se agrego el proceso para el product FiServ con el fin de que muestre resultados correctos. :: Ref: 130520191601_azavala</log>
</ChangeLog>
*********************************************************************/
CREATE Procedure [dbo].[st_DashboardbyOtherProduct]
(
    @IdOtherProduct int,
    @WeeksAgo int,
    @NowWithTime Datetime,
    @Increment numeric(8,2),
    @IdUserSeller int,
    @IdUserRequester int,    
    @StatusesPreselected XML
)
as
Set nocount on

Create Table #DashboardbyOtherProduct
(
    AgentState nvarchar(max),
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
    insert into #DashboardbyOtherProduct
    exec [st_DashboardbyOtherProductBP]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=5) or (@IdOtherProduct is null)
begin        
    insert into #DashboardbyOtherProduct
    --exec [st_DashboardbyOtherProductLD]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
    exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=6) or (@IdOtherProduct is null)
begin        
    insert into #DashboardbyOtherProduct
    --exec [st_DashboardbyOtherProductTU]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
    exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=8) or (@IdOtherProduct is null)
begin        
    insert into #DashboardbyOtherProduct
    exec [st_DashboardbyOtherProductBBP]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=7) or (@IdOtherProduct is null)
begin        
    insert into #DashboardbyOtherProduct
    exec [st_DashboardbyOtherProductTTU]   @WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=9) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
    exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=10) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
    exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=11) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
    exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=12) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
    exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=13) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
		exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=14) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
    exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=16) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
		exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=17) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
		exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

if (@IdOtherProduct=18) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
		exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end

/*Inicio - 130520191601_azavala*/
if (@IdOtherProduct=19) or (@IdOtherProduct is null)
begin    
    insert into #DashboardbyOtherProduct
    exec st_DashboardbyOtherProductLN   @IdOtherProduct,@WeeksAgo,@NowWithTime,@Increment,@IdUserSeller,@IdUserRequester,@StatusesPreselected
end
/*Fin - 130520191601_azavala*/

Select 
    AgentState,
    IdOtherProduct,
    OtherProduct,
    TotalThreeMonthAgo,    
    TotalTwoMonthAgo,    
    TotalOneMonthAgo,    
    TotalCurrentMonth,    
    TransfersStatusToTarget,
    ROUND(TransferTarget,0) TransferTarget,
    TargetColor,TotalWeekAgo,
    TotalToday,    
    TotalStatus,
    TotalColor,
    AverageAmountInDollarsThreeMonthAgo,
    AverageAmountInDollarsTwoMonthAgo,
    AverageAmountInDollarsOneMonthAgo,
    AverageInDollarsCurrentMonth
from #DashboardbyOtherProduct
Order by  AgentState,OtherProduct