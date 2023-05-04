CREATE procedure st_SaveProfitData
(
    @DateOfProfit datetime
)
as
set arithabort on
Set nocount on

declare @StartDate datetime = @DateOfProfit
declare @EndDate datetime


Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)
Select @EndDate=dbo.RemoveTimeFromDatetime(@StartDate+1)

declare @Date1 datetime = [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(@StartDate)-1),@StartDate))
declare @Date2 datetime = [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(@EndDate)-1),@EndDate))

--ProfitData
create table #profitData
(
    IdAgent	int,
    IdCountryCurrency	int,
    IdCountry int,
    NumTrans	int,
    NumCancel	int,
    NumRej	int,
    UnclaimedNumTrans	int,
    CogsTrans	money,
    CogsCancel	money,
    CogsRej	money,
    UnclaimedCOGS money,	
    AmountTrans	money,
    AmountCancel	money,
    AmountRej	money,
    UnclaimedAmount	money,
    FxResult	money,
    FxResultCancel	money,
    FxResultRej	money,
    AgentcommissionMonthly	money,
    AgentcommissionMonthlyCancel	money,
    AgentcommissionMonthlyRej	money,
    AgentcommissionRetain	money,
    AgentcommissionRetainCancel	money,
    AgentcommissionRetainRej	money,
    AgentcommissionRetainCancelLikeReject	money,
    IncomeFeeCancelLikeReject	money,
    IncomeFee	money,
    IncomeFeeCancel	money,
    IncomeFeeRej	money,
    FxFee	money,
    FxFeeCancel	money,
    FxFeeRej	money,
    FxFeeM	money,
    FxFeeMCancel	money,
    FxFeeMRej	money,
    FxFeeR	money,
    FxFeeRCancel	money,
    FxFeeRRej	money,
    BankCommission	money,
    BankCommissionCancel	money,
    BankCommissionRej	money,
    PayerCommission	money,
    PayerCommissionCancel   money,	
    PayerCommissionRej money,
)

--obtener bankcommissions para el reporte
select distinct DateOfBankCommission,FactorNew into #bankcommission from bankcommission (nolock) where active=1 and DateOfBankCommission>=@Date1 and DateOfBankCommission<=@Date2

--obtener payercommissions para el reporte
select 
    distinct idgateway,IdPayer, IdPaymentType, CommissionNew,DateOfPayerConfigCommission into #payercommission 
from 
    payerConfigcommission c (nolock)
join 
    payerconfig x (nolock) on c.idpayerconfig=x.idpayerconfig
where 
    active=1 and DateOfPayerConfigCommission>=@Date1 and DateOfPayerConfigCommission<=@Date2
    
    
------------------------------Tranfer operation--------------------------------------------------    
    
    select 
    t.IdAgent,    
    t.idgateway,
    t.idpayer,
    t.idpaymenttype,
    AmountInDollars,
    ReferenceExRate,
    ExRate,
    Fee,    
    TotalAmountToCorporate,
    AgentCommission,
    ModifierCommissionSlider,
    ModifierExchangeRateSlider,
    IdAgentCollectType,
    [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission,
     case 
        when dateoftransfer<='09/10/2014 16:14' then 
            case 
                when t.IdAgentPaymentSchema=1 and Fee+AmountInDollars = TotalAmountToCorporate  then 1
                else 2
            end
        else t.IdAgentPaymentSchema
    end
    IdAgentPaymentSchema,
    t.IdCountryCurrency,
    cc.IdCountry
    into #temp1a
	from  Transfer  t With (Nolock)    
    join agent a (Nolock) on t.idagent=a.idagent	
    join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
    where
    DateOfTransfer>@StartDate and
    DateOfTransfer<@EndDate


    insert into #profitData
    Select distinct 
	t.IdAgent,
    t.IdCountryCurrency,  
    t.IdCountry,  
	
    Count(1) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as NumTrans,
    0 as NumCancel,
    0 as NumRej,
    0 as UnclaimedNumTrans,
    
    SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as CogsTrans,
    0 as CogsCancel,
    0 as CogsRej,
    0 as UnclaimedCOGS,
	
    Sum(AmountInDollars) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AmountTrans,
    0 as AmountCancel,
    0 as AmountRej,
    0 as UnclaimedAmount,
	
    Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as FxResult,
    0 FxResultCancel,
    0 FxResultRej,
	
    SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AgentcommissionMonthly,
    0 AgentcommissionMonthlyCancel,
    0 AgentcommissionMonthlyRej,
	
    SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AgentcommissionRetain,
    0 AgentcommissionRetainCancel,
    0 AgentcommissionRetainRej,

    0 as AgentcommissionRetainCancelLikeReject,
    0 as IncomeFeeCancelLikeReject,
	
    SUM(Fee) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as IncomeFee,
    0 IncomeFeeCancel,
    0 IncomeFeeRej,
	
    SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as FxFee,
    0 FxFeeCancel,
    0 FxFeeRej,
    
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as FxFeeM,
    0 FxFeeMCancel,
    0 FxFeeMRej,
    
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as FxFeeR,
    0 FxFeeRCancel,
    0 FxFeeRRej,

    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as BankCommission,
    0 BankCommissionCancel,
    0 BankCommissionRej,
    
    sum(isnull(CommissionNew,0)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as PayerCommission,
    0 PayerCommissionCancel,
    0 PayerCommissionRej	    
	from  #temp1a  t With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype

    ------------------------------Tranfer Closed operation--------------------------------------------------

    select 
    t.IdAgent,    
    t.idgateway,
    t.idpayer,
    t.idpaymenttype,
    AmountInDollars,
    ReferenceExRate,
    ExRate,
    Fee,    
    TotalAmountToCorporate,
    AgentCommission,
    ModifierCommissionSlider,
    ModifierExchangeRateSlider,
    IdAgentCollectType,
    [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission,
     case 
        when dateoftransfer<='09/10/2014 16:14' then 
            case 
                when t.IdAgentPaymentSchema=1 and Fee+AmountInDollars = TotalAmountToCorporate  then 1
                else 2
            end
        else t.IdAgentPaymentSchema
    end
    IdAgentPaymentSchema,
    IdCountryCurrency,
    t.IdCountry    
    into #temp2a
	from  TransferClosed  t With (Nolock)    
    join agent a (Nolock) on t.idagent=a.idagent
    where
    DateOfTransfer>@StartDate and
    DateOfTransfer<@EndDate 

    insert into #profitData
	Select distinct 
    t.IdAgent,
    t.IdCountryCurrency,   
    t.IdCountry,
     
	Count(1) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as NumTrans,
    0 as NumCancel,
    0 as NumRej,
    0 as UnclaimedNumTrans,
    
    SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as CogsTrans,
    0 as CogsCancel,
    0 as CogsRej,
    0 as UnclaimedCOGS,
	
    Sum(AmountInDollars) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AmountTrans,
    0 as AmountCancel,
    0 as AmountRej,
    0 as UnclaimedAmount,
	
    Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as FxResult,
    0 FxResultCancel,
    0 FxResultRej,
	
    SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AgentcommissionMonthly,
    0 AgentcommissionMonthlyCancel,
    0 AgentcommissionMonthlyRej,

	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AgentcommissionRetain,
    0 AgentcommissionRetainCancel,
    0 AgentcommissionRetainRej,

    0 as AgentcommissionRetainCancelLikeReject,
    0 as IncomeFeeCancelLikeReject,
	
    SUM(Fee) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as IncomeFee,
    0 IncomeFeeCancel,
    0 IncomeFeeRej,

	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as FxFee,
    0 FxFeeCancel,
    0 FxFeeRej,

    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as FxFeeM,
    0 FxFeeMCancel,
    0 FxFeeMRej,

    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as FxFeeR,
    0 FxFeeRCancel,
    0 FxFeeRRej,

    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as BankCommission,
    0 BankCommissionCancel,
    0 BankCommissionRej,

    sum(isnull(CommissionNew,0)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as PayerCommission,
    0 PayerCommissionCancel,
    0 PayerCommissionRej	

	
	from #temp2a  t With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype


------------------------------Tranfer Rejected --------------------------------------------------

    select 
    t.IdAgent,    
    t.idgateway,
    t.idpayer,
    t.idpaymenttype,
    AmountInDollars,
    ReferenceExRate,
    ExRate,
    Fee,    
    TotalAmountToCorporate,
    AgentCommission,
    ModifierCommissionSlider,
    ModifierExchangeRateSlider,
    IdAgentCollectType,
    [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateStatusChange)-1),DateStatusChange)) DateOfCommission,
     case 
        when dateoftransfer<='09/10/2014 16:14' then 
            case 
                when t.IdAgentPaymentSchema=1 and Fee+AmountInDollars = TotalAmountToCorporate  then 1
                else 2
            end
        else t.IdAgentPaymentSchema
    end
    IdAgentPaymentSchema,
    t.IdCountryCurrency,
    cc.IdCountry
    into #temp3a
	from  Transfer  t With (Nolock)    
    join agent a (Nolock) on t.idagent=a.idagent
    join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	where 
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and	
    IdStatus=31

    insert into #profitData
	Select distinct 	
    t.IdAgent,
    t.IdCountryCurrency, 
    t.IdCountry,   
    
    0 as NumTrans,
    0 as NumCancel,
    Count(1) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as NumRej,
    0 as UnclaimedNumTrans,    

    0 as CogsTrans,
    0 as CogsCancel,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as CogsRej,
    0 as UnclaimedCOGS,

	0 as AmountTrans,
    0 as AmountCancel,
    Sum(AmountInDollars) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AmountRej,
    0 as UnclaimedAmount,
	    
    0 as FxResult,
    0 FxResultCancel,
    Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxResultRej,
    	
    0 as AgentcommissionMonthly,
    0 AgentcommissionMonthlyCancel,
    SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) AgentcommissionMonthlyRej,
    	
    0 as AgentcommissionRetain,
    0 AgentcommissionRetainCancel,
    SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) AgentcommissionRetainRej,

    0 as AgentcommissionRetainCancelLikeReject,
    0 as IncomeFeeCancelLikeReject,
    	
    0 as IncomeFee,
    0 IncomeFeeCancel,
    SUM(Fee) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) IncomeFeeRej,
    	
    0 as FxFee,
    0 FxFeeCancel,
    SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeRej,
        
    0 as FxFeeM,
    0 FxFeeMCancel,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeMRej,
        
    0 as FxFeeR,
    0 FxFeeRCancel,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeRRej,
        
    0 as BankCommission,
    0 BankCommissionCancel,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) BankCommissionRej,
        
    0 as PayerCommission,
    0 PayerCommissionCancel,
    sum(isnull(CommissionNew,0)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) PayerCommissionRej
    	
	from #temp3a t  With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype

------------------------------Tranfer Closed Rejected --------------------------------------------------

    select 
    t.IdAgent,    
    t.idgateway,
    t.idpayer,
    t.idpaymenttype,
    AmountInDollars,
    ReferenceExRate,
    ExRate,
    Fee,    
    TotalAmountToCorporate,
    AgentCommission,
    ModifierCommissionSlider,
    ModifierExchangeRateSlider,
    IdAgentCollectType,
    [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateStatusChange)-1),DateStatusChange)) DateOfCommission,
     case 
        when dateoftransfer<='09/10/2014 16:14' then 
            case 
                when t.IdAgentPaymentSchema=1 and Fee+AmountInDollars = TotalAmountToCorporate  then 1
                else 2
            end
        else t.IdAgentPaymentSchema
    end
    IdAgentPaymentSchema,
    IdCountryCurrency,
    t.IdCountry    
    into #temp4a
	from  TransferClosed  t With (Nolock)    
    join agent a (Nolock) on t.idagent=a.idagent
	where 
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and	
    IdStatus=31

	insert into #profitData
    Select distinct 	
    t.IdAgent,
    t.IdCountryCurrency, 
    t.IdCountry,   
    
    0 as NumTrans,
    0 as NumCancel,
    Count(1) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as NumRej,
    0 as UnclaimedNumTrans,    

    0 as CogsTrans,
    0 as CogsCancel,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as CogsRej,
    0 as UnclaimedCOGS,

	0 as AmountTrans,
    0 as AmountCancel,
    Sum(AmountInDollars) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AmountRej,
    0 as UnclaimedAmount,
	    
    0 as FxResult,
    0 FxResultCancel,
    Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxResultRej,
    	
    0 as AgentcommissionMonthly,
    0 AgentcommissionMonthlyCancel,
    SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) AgentcommissionMonthlyRej,
    	
    0 as AgentcommissionRetain,
    0 AgentcommissionRetainCancel,
    SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) AgentcommissionRetainRej,

    0 as AgentcommissionRetainCancelLikeReject,
    0 as IncomeFeeCancelLikeReject,
    	
    0 as IncomeFee,
    0 IncomeFeeCancel,
    SUM(Fee) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) IncomeFeeRej,
    	
    0 as FxFee,
    0 FxFeeCancel,
    SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeRej,
        
    0 as FxFeeM,
    0 FxFeeMCancel,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeMRej,
        
    0 as FxFeeR,
    0 FxFeeRCancel,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeRRej,
        
    0 as BankCommission,
    0 BankCommissionCancel,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) BankCommissionRej,
        
    0 as PayerCommission,
    0 PayerCommissionCancel,
    sum(isnull(CommissionNew,0)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) PayerCommissionRej
    	
	from #temp4a  t With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype

------------------------------Tranfer Cancel --------------------------------------------------

    select 
    t.idtransfer,
    t.IdAgent,
    t.idgateway,
    t.idpayer,
    t.idpaymenttype,
    AmountInDollars,
	CASE 
                WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  0  
                --ELSE T.AmountInDollars
                when TN.IdTransfer is not null then 0
                else            
                case (rc.returnallcomission) 
                        when 1 then  0
                        else AgentCommissionExtra       
                    end
            END	
	AgentCommissionExtra,
    ReferenceExRate,
    ExRate,
    Fee,    
    TotalAmountToCorporate,
    AgentCommission,
    ModifierCommissionSlider,
    ModifierExchangeRateSlider,
    IdAgentCollectType,
    [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateStatusChange)-1),DateStatusChange)) DateOfCommission,
    case 
        when dateoftransfer<='09/10/2014 16:14' then 
            case 
                when t.IdAgentPaymentSchema=1 and Fee+AmountInDollars = TotalAmountToCorporate  then 1
                else 2
            end
        else t.IdAgentPaymentSchema
    end
    IdAgentPaymentSchema,
    t.IdCountryCurrency,
    cc.IdCountry
    into #temp5a
    from Transfer T   With (Nolock)
    join agent a (Nolock) on t.idagent=a.idagent	
    join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	left join TransferNotAllowedResend TN (Nolock) on TN.IdTransfer =T.IdTransfer
	left join reasonforcancel rc (Nolock) on t.idreasonforcancel=rc.idreasonforcancel
	where 
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and    
	IdStatus=22

    insert into #profitData
	Select distinct 
	t.IdAgent,
    t.IdCountryCurrency,    
    t.IdCountry,
	    
    0 as NumTrans,
    COUNT(1) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as NumCancel,
    0 as NumRej,
    0 as UnclaimedNumTrans,
        
    0 as CogsTrans,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as CogsCancel,
    0 as CogsRej,
    0 as UnclaimedCOGS,
    	
    0 as AmountTrans,
    SUM(AmountInDollars-case when IdAgentPaymentSchema=1 then 0 else AgentCommissionExtra end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AmountCancel,
    0 as AmountRej,
    0 as UnclaimedAmount,

	0 as FxResult,
    SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxResultCancel,
    0 FxResultRej,

    0 as AgentcommissionMonthly,
    SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) AgentcommissionMonthlyCancel,
    0 AgentcommissionMonthlyRej,	
    
    0 as AgentcommissionRetain,
    SUM(case when IdAgentPaymentSchema=2 Then 0 else 0 end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AgentcommissionRetainCancel,
    0 AgentcommissionRetainRej,

    SUM(case when TA.IdTransfer is null then 0 else (case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AgentcommissionRetainCancelLikeReject,
    SUM(case when TA.IdTransfer is null then 0 else Fee end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as IncomeFeeCancelLikeReject,

    0 as IncomeFee,
    SUM(Fee) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) IncomeFeeCancel,
    0 IncomeFeeRej,
    	
    0 as FxFee,
    SUM(ModifierCommissionSlider+ModifierExchangeRateSlider) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeCancel,
    0 FxFeeRej,
        
    0 as FxFeeM,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeMCancel,
    0 FxFeeMRej,
         
    0 as FxFeeR,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeRCancel,
    0 FxFeeRRej,	
	
    0 as BankCommission,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) BankCommissionCancel,
    0 BankCommissionRej,
        
    0 as PayerCommission,
    sum(isnull(CommissionNew,0)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) PayerCommissionCancel,
    0 PayerCommissionRej	
	    
	from #temp5a T   With (Nolock)
	left join dbo.TransferNotAllowedResend TA (Nolock) on T.IdTransfer=TA.IdTransfer
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype

------------------------------Tranfer Closed Cancel --------------------------------------------------

    select 
    t.idtransferclosed,
    t.IdAgent,
    t.idgateway,
    t.idpayer,
    t.idpaymenttype,  
	AmountInDollars,
	CASE 
                WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  0  
                --ELSE T.AmountInDollars
                when TN.IdTransfer is not null then 0
                else            
                case (rc.returnallcomission) 
                        when 1 then  0
                        else AgentCommissionExtra       
                    end
            END	
	AgentCommissionExtra,
    ReferenceExRate,
    ExRate,
    Fee,    
    TotalAmountToCorporate,
    AgentCommission,
    ModifierCommissionSlider,
    ModifierExchangeRateSlider,
    IdAgentCollectType,
    [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateStatusChange)-1),DateStatusChange)) DateOfCommission,
    case 
        when dateoftransfer<='09/10/2014 16:14' then 
            case 
                when t.IdAgentPaymentSchema=1 and Fee+AmountInDollars = TotalAmountToCorporate  then 1
                else 2
            end
        else t.IdAgentPaymentSchema
    end
    IdAgentPaymentSchema,
    IdCountryCurrency,
    t.IdCountry
    into #temp6a
    from TransferClosed T   With (Nolock)
    join agent a (Nolock) on t.idagent=a.idagent	
	left join TransferNotAllowedResend TN (Nolock) on TN.IdTransfer =T.IdTransferClosed
	left join reasonforcancel rc (Nolock) on t.idreasonforcancel=rc.idreasonforcancel
	where 
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and    
	IdStatus=22

    insert into #profitData
	Select distinct 
	t.IdAgent,
    t.IdCountryCurrency,    
    t.IdCountry,
	    
    0 as NumTrans,
    COUNT(1) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as NumCancel,
    0 as NumRej,
    0 as UnclaimedNumTrans,
        
    0 as CogsTrans,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as CogsCancel,
    0 as CogsRej,
    0 as UnclaimedCOGS,
    	
    0 as AmountTrans,
    SUM(AmountInDollars-case when IdAgentPaymentSchema=1 then 0 else AgentCommissionExtra end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AmountCancel,
    0 as AmountRej,
    0 as UnclaimedAmount,

	0 as FxResult,
    SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxResultCancel,
    0 FxResultRej,

    0 as AgentcommissionMonthly,
    SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) AgentcommissionMonthlyCancel,
    0 AgentcommissionMonthlyRej,	
    
    0 as AgentcommissionRetain,
    SUM(case when IdAgentPaymentSchema=2 Then 0 else 0 end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AgentcommissionRetainCancel,
    0 AgentcommissionRetainRej,

    SUM(case when TA.IdTransfer is null then 0 else (case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as AgentcommissionRetainCancelLikeReject,
    SUM(case when TA.IdTransfer is null then 0 else Fee end) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as IncomeFeeCancelLikeReject,

    0 as IncomeFee,
    SUM(Fee) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) IncomeFeeCancel,
    0 IncomeFeeRej,
    	
    0 as FxFee,
    SUM(ModifierCommissionSlider+ModifierExchangeRateSlider) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeCancel,
    0 FxFeeRej,
        
    0 as FxFeeM,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeMCancel,
    0 FxFeeMRej,
         
    0 as FxFeeR,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) FxFeeRCancel,
    0 FxFeeRRej,	
	
    0 as BankCommission,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) BankCommissionCancel,
    0 BankCommissionRej,
        
    0 as PayerCommission,
    sum(isnull(CommissionNew,0)) over (Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) PayerCommissionCancel,
    0 PayerCommissionRej		
	from #temp6a T   With (Nolock)
	left join dbo.TransferNotAllowedResend TA (Nolock) on T.IdTransferClosed=TA.IdTransfer
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype

------------------------------Tranfer Unclaimed --------------------------------------------------
    
    insert into #profitData
	Select distinct 
	IdAgent,    
    t.IdCountryCurrency,    
    cc.IdCountry,

    0 as NumTrans,
    0 as NumCancel,
    0 as NumRej,
    COUNT(1) over(Partition by t.IdAgent,t.IdCountryCurrency,cc.IdCountry) as UnclaimedNumTrans,

    0 as CogsTrans,
    0 as CogsCancel,
    0 as CogsRej,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,t.IdCountryCurrency,cc.IdCountry) as UnclaimedCOGS,
    
    0 as AmountTrans,
    0 as AmountCancel,
    0 as AmountRej,
    SUM(AmountInDollars) over(Partition by t.IdAgent,t.IdCountryCurrency,cc.IdCountry) as UnclaimedAmount,
	 
	0 as FxResult,
    0 FxResultCancel,
    0 FxResultRej,
	
    0 as AgentcommissionMonthly,
    0 AgentcommissionMonthlyCancel,
    0 AgentcommissionMonthlyRej,
	
    0 as AgentcommissionRetain,
    0 AgentcommissionRetainCancel,
    0 AgentcommissionRetainRej,

    0 as AgentcommissionRetainCancelLikeReject,
    0 as IncomeFeeCancelLikeReject,
	
    0 as IncomeFee,
    0 IncomeFeeCancel,
    0 IncomeFeeRej,
	
    0 as FxFee,
    0 FxFeeCancel,
    0 FxFeeRej,
    
    0 as FxFeeM,
    0 FxFeeMCancel,
    0 FxFeeMRej,
    
    0 as FxFeeR,
    0 FxFeeRCancel,
    0 FxFeeRRej,

    0 as BankCommission,
    0 BankCommissionCancel,
    0 BankCommissionRej,
    
    0 as PayerCommission,
    0 PayerCommissionCancel,
    0 PayerCommissionRej	 
	    
	from Transfer  t With (Nolock)
    join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	where 
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=27 
    
	
	------------------------------Tranfer Closed Unclaimed --------------------------------------------------	
	
    insert into #profitData
	Select distinct 
	IdAgent,    
    t.IdCountryCurrency,    
    t.IdCountry,

    0 as NumTrans,
    0 as NumCancel,
    0 as NumRej,
    COUNT(1) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as UnclaimedNumTrans,

    0 as CogsTrans,
    0 as CogsCancel,
    0 as CogsRej,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as UnclaimedCOGS,
    
    0 as AmountTrans,
    0 as AmountCancel,
    0 as AmountRej,
    SUM(AmountInDollars) over(Partition by t.IdAgent,t.IdCountryCurrency,t.IdCountry) as UnclaimedAmount,
	 
	0 as FxResult,
    0 FxResultCancel,
    0 FxResultRej,
	
    0 as AgentcommissionMonthly,
    0 AgentcommissionMonthlyCancel,
    0 AgentcommissionMonthlyRej,
	
    0 as AgentcommissionRetain,
    0 AgentcommissionRetainCancel,
    0 AgentcommissionRetainRej,

    0 as AgentcommissionRetainCancelLikeReject,
    0 as IncomeFeeCancelLikeReject,
	
    0 as IncomeFee,
    0 IncomeFeeCancel,
    0 IncomeFeeRej,
	
    0 as FxFee,
    0 FxFeeCancel,
    0 FxFeeRej,
    
    0 as FxFeeM,
    0 FxFeeMCancel,
    0 FxFeeMRej,
    
    0 as FxFeeR,
    0 FxFeeRCancel,
    0 FxFeeRRej,

    0 as BankCommission,
    0 BankCommissionCancel,
    0 BankCommissionRej,
    
    0 as PayerCommission,
    0 PayerCommissionCancel,
    0 PayerCommissionRej		
	from TransferClosed  t With (Nolock)    
	where 
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=27 


insert into ProfitData
select 
    IdAgent,IdCountryCurrency,IdCountry,
    sum(NumTrans)NumTrans,
    sum(NumCancel)NumCancel,
    sum(NumRej)NumRej,
    sum(UnclaimedNumTrans)UnclaimedNumTrans,
    sum(CogsTrans)CogsTrans,
    sum(CogsCancel)CogsCancel,
    sum(CogsRej)CogsRej,
    sum(UnclaimedCOGS)UnclaimedCOGS,
    sum(AmountTrans)AmountTrans,
    sum(AmountCancel)AmountCancel,
    sum(AmountRej)AmountRej,
    sum(UnclaimedAmount)UnclaimedAmount,
    sum(FxResult)FxResult,
    sum(FxResultCancel)FxResultCancel,
    sum(FxResultRej)FxResultRej,
    sum(AgentcommissionMonthly)AgentcommissionMonthly,
    sum(AgentcommissionMonthlyCancel)AgentcommissionMonthlyCancel,
    sum(AgentcommissionMonthlyRej)AgentcommissionMonthlyRej,
    sum(AgentcommissionRetain)AgentcommissionRetain,
    sum(AgentcommissionRetainCancel)AgentcommissionRetainCancel,
    sum(AgentcommissionRetainRej)AgentcommissionRetainRej,
    sum(AgentcommissionRetainCancelLikeReject)AgentcommissionRetainCancelLikeReject,
    sum(IncomeFeeCancelLikeReject)IncomeFeeCancelLikeReject,
    sum(IncomeFee)IncomeFee,
    sum(IncomeFeeCancel)IncomeFeeCancel,
    sum(IncomeFeeRej)IncomeFeeRej,
    sum(FxFee)FxFee,
    sum(FxFeeCancel)FxFeeCancel,
    sum(FxFeeRej)FxFeeRej,
    sum(FxFeeM)FxFeeM,
    sum(FxFeeMCancel)FxFeeMCancel,
    sum(FxFeeMRej)FxFeeMRej,
    sum(FxFeeR)FxFeeR,
    sum(FxFeeRCancel)FxFeeRCancel,
    sum(FxFeeRRej)FxFeeRRej,
    sum(BankCommission)BankCommission,
    sum(BankCommissionCancel)BankCommissionCancel,
    sum(BankCommissionRej)BankCommissionRej,
    sum(PayerCommission)PayerCommission,
    sum(PayerCommissionCancel)PayerCommissionCancel,
    sum(PayerCommissionRej)PayerCommissionRej,
    @StartDate DateOfProfitData
from #profitData
group by IdAgent,IdCountryCurrency,IdCountry