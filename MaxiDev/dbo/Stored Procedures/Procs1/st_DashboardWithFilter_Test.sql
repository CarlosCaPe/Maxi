
CREATE Procedure [dbo].[st_DashboardWithFilter_Test]
(
    @WeeksAgo int,
    @NowWithTime Datetime,
    @Increment numeric(8,2),
    @IdUserSeller int,
    @IdUserRequester int,
    --@OnlyActiveAgents bit
    @StatusesPreselected XML,
    @Type int = null,
    @IdCountry int = null,
    @IdGateway int = null,
    @IdPayer int = null
    
)
as
SET ARITHABORT on
--Set nocount on
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

set @Type=isnull(@Type,1)

declare @Country nvarchar(max)
declare @Gateway nvarchar(max)
declare @Payer nvarchar(max)

select @Country=countryname from country where idcountry=@IdCountry
select @Gateway=gatewayname from gateway where idgateway=@IdGateway
select @Payer=payername from payer where idpayer=@IdPayer

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

------ Number of transaction Same hours weeks ago ------------------------
--declare @type int  =2

Select SUM(NumTran) as TotalWeeksAgo, IdGeneric into #T1
	from(
		select SUM(1) as NumTran, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then c.idcountry when @type=4 then a.iduserseller end IdGeneric from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
		where T.DateOfTransfer>= @StartDate and T.DateOfTransfer<@EndDate
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)
		group by case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then c.idcountry when @type=4 then a.iduserseller end
			
		union all
		select SUM(1) as NumTran, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then c.idcountry when @type=4 then a.iduserseller end IdGeneric from TransferClosed T --WITH(INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
		where T.DateOfTransfer>= @StartDate and T.DateOfTransfer<@EndDate
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)
		group by case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then c.idcountry when @type=4 then a.iduserseller end
			
		union all
		select SUM(1)*-1 as NumTran, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then c.idcountry when @type=4 then a.iduserseller end IdGeneric from Transfer T
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
		where T.DateStatusChange>= @StartDate and T.DateStatusChange<@EndDate and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)
		group by case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then c.idcountry when @type=4 then a.iduserseller end 
			
		union all
		select SUM(1)*-1 as NumTran, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then c.idcountry when @type=4 then a.iduserseller end IdGeneric from TransferClosed T --WITH(INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
		where T.DateStatusChange>= @StartDate and T.DateStatusChange<@EndDate and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)
		group by case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then c.idcountry when @type=4 then a.iduserseller end 
	) LT
group by IdGeneric

------ Number of transaction Today   ------------------------

--#tempT1
select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tempT1 from Transfer T with (nolock)
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
		where T.DateOfTransfer>= @NowStart and T.DateOfTransfer<@Now
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)
--#tempT2
select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tempT2 from TransferClosed T --with (nolock, INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
		where T.DateOfTransfer>= @NowStart and T.DateOfTransfer<@Now
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)

--#tempT3
select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tempT3 from Transfer T with (nolock)
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
        left join dbo.TransferNotAllowedResend TA on T.IdTransfer=TA.IdTransfer  
		where T.DateStatusChange>= @NowStart and T.DateStatusChange<@Now and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)

--#tempT4
select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tempT4 from TransferClosed T --with (nolock, INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
        left join dbo.TransferNotAllowedResend TA on T.IdTransferClosed=TA.IdTransfer  
		where T.DateStatusChange>= @NowStart and T.DateStatusChange<@Now and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)

--acumulado
Select SUM(NumTran) as TotalToday,sum(AmountInDollars) TotalAmountInDollarsToday, IdGeneric into #T2
	from(		
        select SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
        from #tempT1 T
        left join bankcommission b on b.DateOfBankCommission=DateOfCommission and b.active=1
        left join payerconfig x on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
        left join payerconfigcommission p on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1 
		group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
		union all
		
        select SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
        from #tempT2 T
        left join bankcommission b on b.DateOfBankCommission=DateOfCommission and b.active=1
        left join payerconfig x on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
        left join payerconfigcommission p on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
		group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
		union all
		
        select SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
        from #tempT3 T
        left join bankcommission b on b.DateOfBankCommission=DateOfCommission and b.active=1
        left join payerconfig x on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
        left join payerconfigcommission p on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
		group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
		union all
		
        select SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
        from #tempT4 T
        left join bankcommission b on b.DateOfBankCommission=DateOfCommission and b.active=1
        left join payerconfig x on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
        left join payerconfigcommission p on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
		group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
	) LT
group by IdGeneric


------ Number of transaction One Month ago ------------------------

Select SUM(NumTran) as TotalOneMonthAgo,sum(AmountInDollars) TotalAmountInDollarsOneMonthAgo, IdGeneric  into #T3 
	from(
		select Numtran, AmountInDollars, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then t.idcountry when @type=4 then a.iduserseller end IdGeneric from DashboardForGatewayCountry T
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
		where T.Date>= @OneMonthAgoSD and T.Date<@OneMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))		
                and a.idagentstatus in (select id from @tStatus)
                and t.idcountry=isnull(@idcountry,t.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)	
	) LT
group by IdGeneric

------ Number of transaction Two Month ago ------------------------

Select SUM(NumTran) as TotalTwoMonthAgo,sum(AmountInDollars) TotalAmountInDollarsTwoMonthAgo, IdGeneric into #T4
	from(
		select Numtran, AmountInDollars, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then T.idcountry when @type=4 then a.iduserseller end IdGeneric from DashboardForGatewayCountry T
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
		where T.Date>= @TwoMonthAgoSD and T.Date<@TwoMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
                and a.idagentstatus in (select id from @tStatus)		
                and t.idcountry=isnull(@idcountry,t.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)
	) LT
group by IdGeneric


------ Number of transaction Three Month ago ------------------------

Select SUM(NumTran) as TotalThreeMonthAgo,sum(AmountInDollars) TotalAmountInDollarsThreeMonthAgo, IdGeneric into #T5
	from(
		select Numtran, AmountInDollars, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then T.idcountry when @type=4 then a.iduserseller end IdGeneric from DashboardForGatewayCountry T
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
		where T.Date>= @ThreeMonthAgoSD and T.Date<@ThreeMonthAgoED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))		
                and a.idagentstatus in (select id from @tStatus)		
                and t.idcountry=isnull(@idcountry,t.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)
	) LT
group by IdGeneric


------ Number of transaction Current Month ------------------------

--#tempM1
select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tempM1 from Transfer T with (nolock)
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
		where T.DateOfTransfer>= @CurrentMonthSD and T.DateOfTransfer<@CurrentMonthED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)
--#tempM2
select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tempM2 from TransferClosed T --with (nolock, INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
		where T.DateOfTransfer>= @CurrentMonthSD and T.DateOfTransfer<@CurrentMonthED
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)

--#tempM3
select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tempM3 from Transfer T with (nolock)
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
        left join dbo.TransferNotAllowedResend TA on T.IdTransfer=TA.IdTransfer  
		where T.DateStatusChange>= @CurrentMonthSD and T.DateStatusChange<@CurrentMonthED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)

--#tempM4
select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tempM4 from TransferClosed T --with (nolock, INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
		Join Agent A on (T.IdAgent=A.IdAgent)
        join  state s on s.idcountry=18 and a.agentstate=s.statecode
        join countrycurrency c on t.idcountrycurrency=c.idcountrycurrency
        left join dbo.TransferNotAllowedResend TA on T.IdTransferClosed=TA.IdTransfer  
		where T.DateStatusChange>= @CurrentMonthSD and T.DateStatusChange<@CurrentMonthED and T.IdStatus in (22,31)
				and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
                and a.idagentstatus in (select id from @tStatus)
                and c.idcountry=isnull(@idcountry,c.idcountry)
                and t.idgateway=isnull(@idgateway,t.idgateway)
                and t.idpayer=isnull(@idpayer,t.idpayer)



--acumulado
Select SUM(NumTran) as TotalCurrentMonth,sum(AmountInDollars) TotalAmountInDollarsCurrentMonth, IdGeneric into #T6
	from(
	    select SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
        from #tempM1 T
        left join bankcommission b on b.DateOfBankCommission=DateOfCommission and b.active=1
        left join payerconfig x on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
        left join payerconfigcommission p on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
		group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
		union all
		
        select SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
        from #tempM2 T
        left join bankcommission b on b.DateOfBankCommission=DateOfCommission and b.active=1
        left join payerconfig x on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
        left join payerconfigcommission p on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
		group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
		union all
		
        select SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
        from #tempM3 T
        left join bankcommission b on b.DateOfBankCommission=DateOfCommission and b.active=1
        left join payerconfig x on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
        left join payerconfigcommission p on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
		group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end
			
		union all
		
        select SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
        from #tempM4 T
        left join bankcommission b on b.DateOfBankCommission=DateOfCommission and b.active=1
        left join payerconfig x on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
        left join payerconfigcommission p on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
		group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
	) LT
group by IdGeneric

create table #T0
(
    IdGeneric int 
)

if (@type=1)
begin
    insert into #T0
    Select distinct s.IdState as IdGeneric 
    From Agent 
    join  state s on s.idcountry=18 and agentstate=s.statecode
    where IdAgentStatus in (select id from @tStatus) And (@IsAllSeller = 1 Or (IdUserSeller = @IdUserSeller or IdUserSeller in (select IdSeller from #SellerSubordinates)))
end

if (@type=2)
begin
    if (isnull(@IdGateway,0)=0)
    begin

        select distinct IdGeneric into #TMPGateway from
        (
            select distinct IdGeneric from #t1
            union all
            select distinct IdGeneric from #t2
            union all
            select distinct IdGeneric from #t3
            union all
            select distinct IdGeneric from #t4
            union all
            select distinct IdGeneric from #t5
            union all
            select distinct IdGeneric from #t6
        )t

        insert into #T0
        select idgateway as IdGeneric from gateway where /*status=1 and */idgateway in 
        (
            select IdGeneric from #TMPGateway
        )
    end
    else
    begin
        insert into #T0
        select idgateway as IdGeneric from gateway where /*status=1 and */idgateway = @IdGateway
    end
end

if (@type=3)
begin
    if (isnull(@IdCountry,0)=0)
    begin

        select distinct IdGeneric into #TMPCountry from
        (
            select distinct IdGeneric from #t1
            union all
            select distinct IdGeneric from #t2
            union all
            select distinct IdGeneric from #t3
            union all
            select distinct IdGeneric from #t4
            union all
            select distinct IdGeneric from #t5
            union all
            select distinct IdGeneric from #t6
        )t

        insert into #T0
        select idcountry as IdGeneric from country  where idcountry in
        (
            select IdGeneric from #TMPCountry
        )
    end
    else
    begin
        insert into #T0
        select idcountry as IdGeneric from country  where idcountry=@IdCountry
    end
end

if (@type=4)
begin
    if (isnull(@IdUserSeller,0)=0)
    begin
        if (isnull(@IsAllSeller,0)=0)
        begin
            insert into #T0
                select IdSeller from #SellerSubordinates a
                join users u on a.IdSeller=u.iduser
                where  u.idgenericstatus in (1, 3)
        end
        else
        begin
            insert into #T0
            Select distinct a.iduserSeller as IdGeneric 
            From Agent a    
            join users u on a.iduserSeller=u.iduser
            where  u.idgenericstatus in (1, 3) or iduserseller in (4271) 
        end
    end
    else
    begin    
        insert into #T0
        Select distinct a.iduserSeller as IdGeneric 
        From Agent a    
        join users u on a.iduserSeller=u.iduser
        where  u.idgenericstatus in (1, 3) and iduserSeller=@IdUserSeller
    end
end

Create Table #T7
(
IdGeneric int,
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

Insert #T7 (IdGeneric,TotalThreeMonthAgo,TotalAmountInDollarsThreeMonthAgo,TotalTwoMonthAgo,TotalAmountInDollarsTwoMonthAgo,TotalOneMonthAgo,TotalAmountInDollarsOneMonthAgo,
TotalCurrentMonth,TotalAmountInDollarsCurrentMonth,TotalWeekAgo,TotalToday)
Select A.IdGeneric,TotalThreeMonthAgo,TotalAmountInDollarsThreeMonthAgo,TotalTwoMonthAgo,TotalAmountInDollarsTwoMonthAgo,TotalOneMonthAgo,TotalAmountInDollarsOneMonthAgo,
TotalCurrentMonth,TotalAmountInDollarsCurrentMonth,TotalWeeksAgo,TotalToday From #T0 A
Full JOIN #T1 B on (A.IdGeneric=B.IdGeneric)
Full join #T2 C on (A.IdGeneric=C.IdGeneric)
Full Join #T3 D on (A.IdGeneric=D.IdGeneric)
Full Join #T4 E on (A.IdGeneric=E.IdGeneric)
Full Join #T5 F on (A.IdGeneric=F.IdGeneric)
Full Join #T6 G on (A.IdGeneric=G.IdGeneric)

SELECT IdGenericA = A.IdGeneric, IdGenericB = B.IdGeneric, IdGenericC = C.IdGeneric, IdGenericD = D.IdGeneric, IdGenericE = E.IdGeneric, IdGenericF = F.IdGeneric, IdGenericG = G.IdGeneric Into #ValidateGeneric
From #T0 A
Full JOIN #T1 B on (A.IdGeneric=B.IdGeneric)
Full join #T2 C on (A.IdGeneric=C.IdGeneric)
Full Join #T3 D on (A.IdGeneric=D.IdGeneric)
Full Join #T4 E on (A.IdGeneric=E.IdGeneric)
Full Join #T5 F on (A.IdGeneric=F.IdGeneric)
Full Join #T6 G on (A.IdGeneric=G.IdGeneric)

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
    IdGeneric,
    case when @type=1 then statecode when @type=2 then gatewayname when @type=3 then CountryName when @type=4 then UserName end GenricName,
    
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
    TotalStatus,
    isnull(@Country,'') Country, 
    isnull(@Gateway,'') Gateway, 
    isnull(@Payer,'') Payer
from #T7 t
left join state s on s.idstate=t.IdGeneric
left join gateway g on g.IdGateway=t.IdGeneric
left join country c on c.IdCountry=t.IdGeneric
left join users u on u.iduser=t.IdGeneric
--where   (TotalThreeMonthAgo>0 or TotalTwoMonthAgo>0 or TotalOneMonthAgo>0 or TotalCurrentMonth>0 or TotalWeekAgo>0 or TotalToday>0 )
Order by  GenricName

Select * from #ValidateGeneric

/*
select distinct idgeneric from
(
select distinct idgeneric from #t1
union all
select distinct idgeneric from #t2
union all
select distinct idgeneric from #t3
union all
select distinct idgeneric from #t4
union all
select distinct idgeneric from #t5
union all
select distinct idgeneric from #t6
) t

select distinct idgeneric from #t0

*/