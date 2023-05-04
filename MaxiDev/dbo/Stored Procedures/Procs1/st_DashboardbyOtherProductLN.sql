
CREATE Procedure [dbo].[st_DashboardbyOtherProductLN]
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
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
set arithabort on
Set nocount on
declare @OtherProductPrefix nvarchar(max)

select @OtherProductPrefix=typeofmovement from AgentBalanceHelper where idotherproduct=@IdOtherProduct and isdebit=1

Declare @TransactionStatusForPositive table
      (    
       id int    
      ) 

--Para LN 30=Paid, 22=Cancel 
insert into @TransactionStatusForPositive
values
(30),(22)

Declare @TransactionStatusForNegative table
(    
    id int    
)    

--Para LN 22=Cancel
insert into @TransactionStatusForNegative
values
(22)

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


declare @IsAllSeller bit 
set @IsAllSeller = (Select top 1 1 From [Users] where @IdUserSeller=0 and [IdUser] = @IdUserRequester and [IdUserType] = 1) 

Create Table #SellerSubordinates
	(
		IdSeller int
	)

/*
Insert into #SellerSubordinates 
Select IdUserSeller From [Seller] Where @IdUserSeller=0 and ([IdUserSellerParent] = @IdUserRequester or [IdUserSeller] = @IdUserRequester)
*/
-------Nuevo proceso de busqueda recursiva de Sellers---------------------

declare @IdUserBaseText nvarchar(max)

set @IdUserBaseText='%/'+isnull(convert(varchar,@IdUserRequester),'0')+'/%'

;WITH items AS (
    SELECT iduser,username,userlogin 
    , 0 AS Level
    , CAST('/'+convert(varchar,iduser)+'/' as varchar(2000)) AS Path
    FROM users u
    join seller s on u.iduser=s.iduserseller 
    WHERE idgenericstatus=1 and IdUserSellerParent is null
    
    UNION ALL

    SELECT u.iduser,u.username,u.userlogin 
    , Level + 1
    , CAST(itms.path+convert(varchar,isnull(u.iduser,''))+'/' as varchar(2000))  AS Path
    FROM users u
    join seller s on u.iduser=s.iduserseller 
    INNER JOIN items itms ON itms.iduser = s.IdUserSellerParent
    WHERE idgenericstatus=1
)
SELECT iduser,username,userlogin,Level,Path into #SellerTree  FROM items

Insert into #SellerSubordinates 
select iduser from #SellerTree where path like @IdUserBaseText and @IdUserSeller=0

--------------------------------------------------------------------------

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


------ Number of transaction Same hours weeks ago @StartDate,@EndDate------------------------

Select SUM(NumTran) as TotalWeeksAgo, AgentState into #T1
	from(
		select SUM(1) as NumTran, A.AgentState from operation.ProductTransfer T 
		Join Agent A on (T.IdAgent=A.IdAgent)
		where t.DateOfCreation>= @StartDate and t.DateOfCreation<@EndDate and t.idstatus in (select id from @TransactionStatusForPositive)
				and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState
			
		union all

		select SUM(1)*-1 as NumTran, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where t.DateOfCancel>= @StartDate and t.DateOfCancel<@EndDate and t.idstatus in (select id from @TransactionStatusForNegative)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState
	) LT
group by AgentState


------ Number of transaction Today  @NowStart,@Now ------------------------


Select SUM(NumTran) as TotalToday,sum(AmountInDollars) TotalAmountInDollarsToday, AgentState into #T2
	from(
		select SUM(1) as NumTran,sum(CorpCommission) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where t.DateOfCreation>= @NowStart and t.DateOfCreation<@Now and t.idstatus in (select id from @TransactionStatusForPositive)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState		
			
		union all

		select SUM(1)*(-1) as NumTran,sum(CorpCommission)*(-1) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)        
		where t.DateOfCancel>= @NowStart and t.DateOfCancel<@Now and t.idstatus in (select id from @TransactionStatusForNegative)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState		
	) LT
group by AgentState


------ Number of transaction One Month ago @OneMonthAgoSD,@OneMonthAgoED------------------------

Select SUM(NumTran) as TotalOneMonthAgo,sum(AmountInDollars) TotalAmountInDollarsOneMonthAgo, AgentState into #T3 
	from(
        select SUM(1) as NumTran,sum(CorpCommission) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where t.DateOfCreation>= @OneMonthAgoSD and t.DateOfCreation<@OneMonthAgoED and t.idstatus in (select id from @TransactionStatusForPositive)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState		
			
		union all

		select SUM(1)*(-1) as NumTran,sum(CorpCommission)*(-1) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)        
		where t.DateOfCancel>= @OneMonthAgoSD and t.DateOfCancel<@OneMonthAgoED and t.idstatus in (select id from @TransactionStatusForNegative)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState					
	) LT
group by AgentState


------ Number of transaction Two Month ago @TwoMonthAgoSD,@TwoMonthAgoED ------------------------

Select SUM(NumTran) as TotalTwoMonthAgo,sum(AmountInDollars) TotalAmountInDollarsTwoMonthAgo, AgentState into #T4 
	from(
        select SUM(1) as NumTran,sum(CorpCommission) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where t.DateOfCreation>= @TwoMonthAgoSD and t.DateOfCreation<@TwoMonthAgoED and t.idstatus in (select id from @TransactionStatusForPositive)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState		
			
		union all

		select SUM(1)*(-1) as NumTran,sum(CorpCommission)*(-1) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)        
		where t.DateOfCancel>= @TwoMonthAgoSD and t.DateOfCancel<@TwoMonthAgoED and t.idstatus in (select id from @TransactionStatusForNegative)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState					
	) LT
group by AgentState

------ Number of transaction Three Month ago @ThreeMonthAgoSD,@ThreeMonthAgoED------------------------

Select SUM(NumTran) as TotalThreeMonthAgo,sum(AmountInDollars) TotalAmountInDollarsThreeMonthAgo, AgentState into #T5 
	from(
        select SUM(1) as NumTran,sum(CorpCommission) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where t.DateOfCreation>= @ThreeMonthAgoSD and t.DateOfCreation<@ThreeMonthAgoED and t.idstatus in (select id from @TransactionStatusForPositive)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState		
			
		union all

		select SUM(1)*(-1) as NumTran,sum(CorpCommission)*(-1) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)        
		where t.DateOfCancel>= @ThreeMonthAgoSD and t.DateOfCancel<@ThreeMonthAgoED and t.idstatus in (select id from @TransactionStatusForNegative)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState					
	) LT
group by AgentState

------ Number of transaction Current Month @CurrentMonthSD,@CurrentMonthED------------------------

Select SUM(NumTran) as TotalCurrentMonth,sum(AmountInDollars) TotalAmountInDollarsCurrentMonth, AgentState into #T6
	from(
        select SUM(1) as NumTran,sum(CorpCommission) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
		where t.DateOfCreation>= @CurrentMonthSD and t.DateOfCreation<@CurrentMonthED and t.idstatus in (select id from @TransactionStatusForPositive)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState		
			
		union all

		select SUM(1)*(-1) as NumTran,sum(CorpCommission)*(-1) AmountInDollars, A.AgentState from operation.ProductTransfer T
		Join Agent A on (T.IdAgent=A.IdAgent)        
		where t.DateOfCancel>= @CurrentMonthSD and t.DateOfCancel<@CurrentMonthED and t.idstatus in (select id from @TransactionStatusForNegative)
		        and t.Amount>0
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)
                and idotherproduct=@IdOtherProduct
		group by A.AgentState					
	) LT
group by AgentState

Select distinct AgentState as AgentState into #T0 From Agent where IdAgentStatus in (select id from @tStatus) 
													And (@IsAllSeller = 1 Or (IdUserSeller = @IdUserSeller or IdUserSeller in (select IdSeller from #SellerSubordinates)))


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
    @IdOtherProduct IdOtherProduct,
    @OtherProductPrefix OtherProduct,
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