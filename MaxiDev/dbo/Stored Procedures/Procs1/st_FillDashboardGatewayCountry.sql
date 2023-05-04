CREATE Procedure [dbo].[st_FillDashboardGatewayCountry]
/********************************************************************
<Author>Not Known</Author>
<app>MaxiJob</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as
set nocount on

declare @BeginDate datetime
declare @EndDate datetime
declare @TmpDate datetime
declare @MonthAgoSD datetime
declare @MonthAgoED datetime
declare @id int

set @BeginDate='2004-02-01 00:00:00.000'
set @EndDate=[dbo].[RemoveTimeFromDatetime](getdate())

declare @dates table
(
    id int identity(1,1),
    BeginDate datetime,
    EndDate datetime
)

truncate table DashboardForGatewayCountry

while (@BeginDate <@EndDate)
begin
    set @TmpDate=DATEADD(month, 1,@BeginDate)

    if @TmpDate>@EndDate 
        set @TmpDate = @EndDate

    insert into @dates
    values
    (@BeginDate,@TmpDate)

    set @BeginDate=@TmpDate
end

--delete from @dates where id!=1

while exists (select 1 from @dates)
begin
    select @id=id, @MonthAgoSD=BeginDate, @MonthAgoED=EndDate from @dates order by id desc

    select t.idagent,a.IdAgentCollectType,t.idpaymenttype,t.idgateway,t.idpayer,c.idcountry, A.AgentState,t.idcountrycurrency, Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars,AmountInDollars AmountInDollarsForCommission,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tmp1
    from [Transfer] T with (nolock)
    Join Agent A with(nolock) on (T.IdAgent=A.IdAgent)
    join countrycurrency c with(nolock) on t.idcountrycurrency=c.idcountrycurrency
    where T.DateOfTransfer>= @MonthAgoSD and T.DateOfTransfer<@MonthAgoED

    select t.idagent,a.IdAgentCollectType,t.idpaymenttype,t.idgateway,t.idpayer,c.idcountry, A.AgentState,t.idcountrycurrency, Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars,AmountInDollars AmountInDollarsForCommission,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tmp2
    from TransferClosed T with (nolock)
    Join Agent A with(nolock) on (T.IdAgent=A.IdAgent)
    join countrycurrency c with(nolock) on t.idcountrycurrency=c.idcountrycurrency
    where T.DateOfTransfer>= @MonthAgoSD and T.DateOfTransfer<@MonthAgoED

    select t.idagent,a.IdAgentCollectType,t.idpaymenttype,t.idgateway,t.idpayer,c.idcountry, A.AgentState,t.idcountrycurrency, Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars,AmountInDollars AmountInDollarsForCommission,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tmp3
    from [Transfer] T with (nolock)
    Join Agent A with(nolock) on (T.IdAgent=A.IdAgent)
    join countrycurrency c with(nolock) on t.idcountrycurrency=c.idcountrycurrency
    left join dbo.TransferNotAllowedResend TA with(nolock) on T.IdTransfer=TA.IdTransfer  
    where T.DateStatusChange>= @MonthAgoSD and T.DateStatusChange<@MonthAgoED and T.IdStatus in (22,31)

    select t.idagent,a.IdAgentCollectType,t.idpaymenttype,t.idgateway,t.idpayer,c.idcountry, A.AgentState,t.idcountrycurrency, Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars,AmountInDollars AmountInDollarsForCommission,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission into #tmp4
    from TransferClosed T with (nolock)
    Join Agent A with(nolock) on (T.IdAgent=A.IdAgent)
    join countrycurrency c with(nolock) on t.idcountrycurrency=c.idcountrycurrency
    left join dbo.TransferNotAllowedResend TA with(nolock) on T.IdTransferClosed=TA.IdTransfer  
    where T.DateStatusChange>= @MonthAgoSD and T.DateStatusChange<@MonthAgoED and T.IdStatus in (22,31)
        
    insert into DashboardForGatewayCountry    
    Select idagent,idgateway,idpayer,idcountry, AgentState, SUM(NumTran) as NumTran,sum(AmountInDollars) TotalAmountInDollars, @MonthAgoSD 'Date'
	from(
          select t.idagent,t.idgateway,t.idpayer,idcountry,AgentState,SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars                
          from 
                #tmp1 t
          left join bankcommission b with(nolock) on b.DateOfBankCommission=DateOfCommission and b.active=1
          left join payerconfig x with(nolock) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
          left join payerconfigcommission p with(nolock) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
          group by idagent,t.idgateway,t.idpayer,idcountry, AgentState
          
          union all

          select t.idagent,t.idgateway,t.idpayer,idcountry,AgentState,SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars          
          from 
                #tmp2 t
          left join bankcommission b with(nolock) on b.DateOfBankCommission=DateOfCommission and b.active=1
          left join payerconfig x with(nolock) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
          left join payerconfigcommission p with(nolock) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
          group by idagent,t.idgateway,t.idpayer,idcountry, AgentState

          union all

          select t.idagent,t.idgateway,t.idpayer,idcountry,AgentState,SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars
          from 
                #tmp3 t
          left join bankcommission b with(nolock) on b.DateOfBankCommission=DateOfCommission and b.active=1
          left join payerconfig x with(nolock) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
          left join payerconfigcommission p with(nolock) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
          group by idagent,t.idgateway,t.idpayer,idcountry, AgentState

          union all

          select t.idagent,t.idgateway,t.idpayer,idcountry,AgentState,SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars
          from 
                #tmp4 t
          left join bankcommission b with(nolock) on b.DateOfBankCommission=DateOfCommission and b.active=1
          left join payerconfig x with(nolock) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
          left join payerconfigcommission p with(nolock) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
          group by idagent,t.idgateway,t.idpayer,idcountry, AgentState
    ) LT
    group by idagent,idgateway,idpayer,idcountry, AgentState
    order by AgentState,idagent,idgateway,idpayer,idcountry

    drop table #tmp1
    drop table #tmp2
    drop table #tmp3
    drop table #tmp4

    delete from @dates where id=@id
end