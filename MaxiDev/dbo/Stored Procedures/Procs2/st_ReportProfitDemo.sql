create procedure [dbo].[st_ReportProfitDemo]
(
@IdCountryCurrency int,
@StartDate datetime,
@EndDate datetime,
@IdUserSeller int,
@IdUserRequester int
)
as          

set arithabort on
Set nocount on

Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)


declare @Date1 datetime = [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(@StartDate)-1),@StartDate))
declare @Date2 datetime = [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(@EndDate)-1),@EndDate))

--obtener bankcommissions para el reporte
select distinct DateOfBankCommission,FactorNew into #bankcommission from bankcommission where active=1 and DateOfBankCommission>=@Date1 and DateOfBankCommission<=@Date2

--obtener payercommissions para el reporte
select 
    distinct idgateway,IdPayer, IdPaymentType, CommissionNew,DateOfPayerConfigCommission into #payercommission 
from 
    payerConfigcommission c
join 
    payerconfig x on c.idpayerconfig=x.idpayerconfig
where 
    active=1 and DateOfPayerConfigCommission>=@Date1 and DateOfPayerConfigCommission<=@Date2

declare @IsAllSeller bit 
set @IsAllSeller = (Select top 1 1 From [Users] where @IdUserSeller=0 and [IdUser] = @IdUserRequester and [IdUserType] = 1) 

Create Table #SellerSubordinates
	(
		IdSeller int
	)
Insert into #SellerSubordinates 
Select IdUserSeller From [Seller] Where @IdUserSeller=0 and ([IdUserSellerParent] = @IdUserRequester or [IdUserSeller] = @IdUserRequester)

Create Table #TempAgents (IdAgent int)

Create Table #Temp
(
Id int identity(1,1),
IdAgent Int,
AgentName nvarchar(max),
AgentCode nvarchar(max),
SalesRep nvarchar(max),
NumTrans int,
NumCancel int,
NumNet int,
AmountTrans money,
AmountCancel money,
AmountNet money,
CogsTrans money,
CogsCancel money,
CogsNet money,
FxResult money,
IncomeFee money,
AgentcommissionMonthly money,
AgentcommissionRetain money,
FxFee money,
FxFeeM money,
FxFeeR money,
Result money,
OtherCharges money,
NetResult money,
UnclaimedNumTrans Int,
UnclaimedAmount money,
UnclaimedCOGS Money,
BankCommission float,
PayerCommission money
)



Insert into #TempAgents (IdAgent)
	Select Distinct IdAgent from Transfer 
	where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		and DateOfTransfer>@StartDate and DateOfTransfer<@EndDate
	
	Union
	Select IdAgent from TransferClosed
	where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		and DateOfTransfer>@StartDate and DateOfTransfer<@EndDate
	
	Union
	Select IdAgent from TransferClosed
	where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)
	
	Union
	Select IdAgent from Transfer
	where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)
	
	Union
	Select IdAgent from Transfer
	where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (27)

	Insert into #Temp (IdAgent, AgentName, AgentCode,SalesRep)
	Select t.IdAgent, A.AgentName, A.AgentCode, isnull(UserName,'')
	from #TempAgents T
	inner join Agent A on (A.IdAgent = T.IdAgent)
    left join users u on u.iduser=a.IdUserSeller
	where @IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates))    

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
    IdAgentPaymentSchema
    into #temp1a
	from  Transfer  t With (Nolock)    
    join agent a on t.idagent=a.idagent
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateOfTransfer>@StartDate and
    DateOfTransfer<@EndDate and
	t.IdAgent in (Select IdAgent from #TempAgents)


	Select distinct 
	t.IdAgent,
	Count(1) over(Partition by t.IdAgent) as NumTrans1,
	Sum(AmountInDollars) over(Partition by t.IdAgent) as AmountTrans1,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by t.IdAgent) as FxResult1,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over (Partition by t.IdAgent) as AgentcommissionMonthly1,
	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) over (Partition by t.IdAgent) as AgentcommissionRetain1,
	SUM(Fee) over (Partition by t.IdAgent) as IncomeFee1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by t.IdAgent) as FxFee1,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeM1,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeR1,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent) as BankCommission1,
    sum(isnull(CommissionNew,0)) over (Partition by t.IdAgent) as PayerCommission1
	into #temp1
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
    IdAgentPaymentSchema
    into #temp2a
	from  TransferClosed  t With (Nolock)    
    join agent a on t.idagent=a.idagent
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateOfTransfer>@StartDate and
    DateOfTransfer<@EndDate and
	t.IdAgent in (Select IdAgent from #TempAgents)

	Select distinct 
	t.idAgent,
	Count(1) over(Partition by t.IdAgent) as NumTrans2,
	Sum(AmountInDollars) over(Partition by t.IdAgent) as AmountTrans2,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by t.IdAgent) as FxResult2,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over (Partition by t.IdAgent) as AgentcommissionMonthly2,
	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) over (Partition by t.IdAgent) as AgentcommissionRetain2,
	SUM(Fee) over (Partition by t.IdAgent) as IncomeFee2,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by t.IdAgent) as FxFee2,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeM2,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeR2,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent) as BankCommission2,
    sum(isnull(CommissionNew,0)) over (Partition by t.IdAgent) as PayerCommission2
	into #temp2 
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
    IdAgentPaymentSchema
    into #temp3a
	from  Transfer  t With (Nolock)    
    join agent a on t.idagent=a.idagent
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	t.IdAgent in (Select IdAgent from #TempAgents) and
    IdStatus=31

	Select distinct 
	idAgent,
	Count(1) over(Partition by IdAgent) as NumTransRej1,
	Sum(AmountInDollars) over(Partition by IdAgent) as AmountTransRej1,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by IdAgent) as FxResultRej1,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionMonthlyRej1,
	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionRetainRej1,
	SUM(Fee) over (Partition by IdAgent) as IncomeFeeRej1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by IdAgent) as FxFeeRej1,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeRejM1,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeRejR1,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent) as BankCommission3,
    sum(isnull(CommissionNew,0)) over (Partition by IdAgent) as PayerCommission3
	into #temp3 
	from #temp3a t  With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    --DateStatusChange>@StartDate and
    --DateStatusChange<@EndDate and
	--IdStatus=31

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
    IdAgentPaymentSchema
    into #temp4a
	from  TransferClosed  t With (Nolock)    
    join agent a on t.idagent=a.idagent
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	t.IdAgent in (Select IdAgent from #TempAgents) and
    IdStatus=31

	Select distinct 
	idAgent,
	Count(1) over(Partition by IdAgent) as NumTrans2Rej,
	Sum(AmountInDollars) over(Partition by IdAgent) as AmountTrans2Rej,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by IdAgent) as FxResult2Rej,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionMonthly2Rej,
	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionRetain2Rej,
	SUM(Fee) over (Partition by IdAgent) as IncomeFee2Rej,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by IdAgent) as FxFee2Rej,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeM2Rej,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeR2Rej,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent) as BankCommission4,
    sum(isnull(CommissionNew,0)) over (Partition by IdAgent) as PayerCommission4
	into #temp4 
	from #temp4a  t With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    --DateStatusChange>@StartDate and
    --DateStatusChange<@EndDate and
	--IdStatus=31

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
    IdAgentPaymentSchema
    into #temp5a
    from Transfer T   With (Nolock)
    join agent a on t.idagent=a.idagent	
	left join TransferNotAllowedResend TN on TN.IdTransfer =T.IdTransfer
	left join reasonforcancel rc on t.idreasonforcancel=rc.idreasonforcancel
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
    t.IdAgent in (Select IdAgent from #TempAgents) and
	IdStatus=22

	Select distinct 
	idAgent,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by IdAgent) as CogsCancel1,
	COUNT(1) over(Partition by IdAgent)  as NumCancel1,
	SUM(AmountInDollars-case when IdAgentPaymentSchema=1 then 0 else AgentCommissionExtra end) over(Partition by T.IdAgent) as AmountCancel1,
	SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over(Partition by IdAgent) as FxResultCancel1,
	SUM(case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end) over(Partition by IdAgent)  as AgentcommissionMonthlyCan1,
	SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then 0 else 0 end) over(Partition by IdAgent) as AgentcommissionRetainCan1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider) over(Partition by IdAgent) as FxFeeCan1,
    SUM(case when Fee+AmountInDollars=TotalAmountToCorporate Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeCanM1,
    SUM(case when Fee+AmountInDollars<>TotalAmountToCorporate Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeCanR1,
	SUM(Fee) over(Partition by IdAgent) as IncomeFeeCan1,
	SUM(case when TA.IdTransfer is null then 0 else Fee end) over(Partition by IdAgent) as IncomeFeeCancelLikeReject1,
	SUM(case when TA.IdTransfer is null then 0 else (case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) end) over(Partition by IdAgent) as AgentcommissionRetainCancelLikeReject1,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent) as BankCommission5,
    sum(isnull(CommissionNew,0)) over (Partition by IdAgent) as PayerCommission5
	into #temp5 
	from #temp5a T   With (Nolock)
	left join dbo.TransferNotAllowedResend TA on T.IdTransfer=TA.IdTransfer
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    --DateStatusChange>@StartDate and
    --DateStatusChange<@EndDate and
	--IdStatus=22
    		
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
    IdAgentPaymentSchema
    into #temp6a
    from TransferClosed T   With (Nolock)
    join agent a on t.idagent=a.idagent	
	left join TransferNotAllowedResend TN on TN.IdTransfer =T.IdTransferClosed
	left join reasonforcancel rc on t.idreasonforcancel=rc.idreasonforcancel
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
    t.IdAgent in (Select IdAgent from #TempAgents) and
	IdStatus=22

	Select distinct 
	T.idAgent,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by T.IdAgent) as CogsCancel2,
	COUNT(1) over(Partition by T.IdAgent)  as NumCancel2,
	SUM(AmountInDollars-case when IdAgentPaymentSchema=1 then 0 else AgentCommissionExtra end) over(Partition by T.IdAgent) as AmountCancel2,
	SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over(Partition by T.IdAgent) as FxResultCancel2,
	SUM(case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end) over(Partition by T.IdAgent)  as AgentcommissionMonthlyCan2,
	SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then 0 else 0 end) over(Partition by T.IdAgent) as AgentcommissionRetainCan2,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider) over(Partition by T.IdAgent) as FxFeeCan2,
    SUM(case when Fee+AmountInDollars=TotalAmountToCorporate Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeCanM2,
    SUM(case when Fee+AmountInDollars<>TotalAmountToCorporate Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) over (Partition by t.IdAgent) as FxFeeCanR2,
	SUM(Fee) over(Partition by T.IdAgent) as IncomeFeeCan2,
	SUM(case when TA.IdTransfer is null then 0 else Fee end) over(Partition by T.IdAgent) as IncomeFeeCancelLikeReject2,
	SUM(case when TA.IdTransfer is null then 0 else (case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) end) over(Partition by T.IdAgent) as AgentcommissionRetainCancelLikeReject2,
    sum(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollars*FactorNew,0) end) over (Partition by t.IdAgent) as BankCommission6,
    sum(isnull(CommissionNew,0)) over (Partition by IdAgent) as PayerCommission6
	into #temp6
	from #temp6a T   With (Nolock)
	left join dbo.TransferNotAllowedResend TA on T.IdTransferClosed=TA.IdTransfer
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    --T.DateStatusChange>@StartDate and
    --T.DateStatusChange<@EndDate and
	--T.IdStatus=22 


	--Select distinct 
	--o.idAgent,
	--Sum(case when B.DebitOrCredit='Credit' then o.Amount else o.Amount*(-1) end) over(Partition by o.IdAgent) as OtherCharges1
	--into #temp7
	--from AgentOtherCharge o  With (Nolock)
 --   join 
 --       AgentBalance B on O.IDAGENT = B.IDAGENT AND O.IdAgentBalance = B.IdAgentBalance
	--where 
 --   ChargeDate>=@StartDate and
 --   ChargeDate<@EndDate 

    ------------------------------Other Charges  --------------------------------------------------
    select  DISTINCT
        IDAGENT ,Sum(case when DebitOrCredit='Credit' then Amount else Amount*(-1) end) over(Partition by IdAgent) OtherCharges1	
        into #temp7
    from 
        agentbalance  With (Nolock)
    where 
        DateOfMovement>=@StartDate and
        DateOfMovement<@EndDate and
        (typeofmovement='CGO' OR typeofmovement='DEBT')


    Select  distinct
	ac.idAgent,
	Sum(o.AmountToPay) 	over(Partition by ac.IdAgent) as OtherCharges2
    into #temp10
	from 
        AgentCollectionDetail o  With (Nolock)    
    inner join 
	    AgentCollection AC on AC.IdAgentCollection = o.IdAgentCollection 
	where 
    o.DateofLastChange>=@StartDate and
    o.DateofLastChange<@EndDate-- and ac.idagent=45
    --group by ac.idagent

    ------------------------------Tranfer Unclaimed --------------------------------------------------

	Select distinct 
	idAgent,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by IdAgent) as UnclaimedCOGS1,
	COUNT(1) over(Partition by IdAgent) as UnclaimedNumTrans1,
	SUM(AmountInDollars) over(Partition by IdAgent) as UnclaimedAmount1
	into #temp8
	from Transfer   With (Nolock)
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=27 
	
	------------------------------Tranfer Closed Unclaimed --------------------------------------------------	
	
	Select distinct 
	idAgent,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by IdAgent) as UnclaimedCOGSClosed,
	COUNT(1) over(Partition by IdAgent) as UnclaimedNumTransClosed,
	SUM(AmountInDollars) over(Partition by IdAgent) as UnclaimedAmountClosed
	into #temp9
	from TransferClosed   With (Nolock)
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=27 
	

    ------------------------------Calculate OutPut --------------------------------------------------

	Select 
	A.*,
	B.NumTrans1,
	B.AmountTrans1,
	B.FxResult1,
	B.AgentcommissionMonthly1,
	B.AgentcommissionRetain1,
	B.IncomeFee1,
	B.FxFee1,
    B.FxFeeM1,
    B.FxFeeR1,
	C.NumTrans2,
	C.AmountTrans2,
	C.FxResult2,
	C.AgentcommissionMonthly2,
	C.AgentcommissionRetain2,
	C.IncomeFee2,
	C.FxFee2,
    C.FxFeeM2,
    C.FxFeeR2,
	D.NumTransRej1,
	D.AmountTransRej1,
	D.FxResultRej1,
	D.AgentcommissionMonthlyRej1,
	D.AgentcommissionRetainRej1,
	D.IncomeFeeRej1,
	D.FxFeeRej1,
    D.FxFeeRejM1,
    D.FxFeeRejR1,
	E.NumTrans2Rej,
	E.AmountTrans2Rej,
	E.FxResult2Rej,
	E.AgentcommissionMonthly2Rej,
	E.AgentcommissionRetain2Rej,
	E.IncomeFee2Rej,
	E.FxFee2Rej,
    E.FxFeeM2Rej,
    E.FxFeeR2Rej,
	F.CogsCancel1,
	F.NumCancel1,
	F.AmountCancel1,
	F.FxResultCancel1,
	F.AgentcommissionMonthlyCan1,
	F.AgentcommissionRetainCan1,
	F.FxFeeCan1,
    F.FxFeeCanM1,
    F.FxFeeCanR1,
	F.IncomeFeeCan1,
	F.IncomeFeeCancelLikeReject1,
	F.AgentcommissionRetainCancelLikeReject1,
	G.CogsCancel2,
	G.NumCancel2,
	G.AmountCancel2,
	G.FxResultCancel2,
	G.AgentcommissionMonthlyCan2,
	G.AgentcommissionRetainCan2,
	G.FxFeeCan2,
    G.FxFeeCanM2,
    G.FxFeeCanR2,
	G.IncomeFeeCan2,
	G.IncomeFeeCancelLikeReject2,
	G.AgentcommissionRetainCancelLikeReject2,
	H.OtherCharges1,
    k.OtherCharges2,
	I.UnclaimedCOGS1,
	I.UnclaimedNumTrans1,
	I.UnclaimedAmount1,
	J.UnclaimedCOGSClosed,
	J.UnclaimedNumTransClosed,
	J.UnclaimedAmountClosed,
    b.BankCommission1,
    c.BankCommission2,
    d.BankCommission3,
    e.BankCommission4,
    f.BankCommission5,
    g.BankCommission6,
    b.PayerCommission1,
    c.PayerCommission2,
    d.PayerCommission3,
    e.PayerCommission4,
    f.PayerCommission5,
    g.PayerCommission6
	into #Result
	from #temp A
	Left Join #temp1 B on (A.IdAgent=B.IdAgent)
	Left Join #temp2 C on (A.IdAgent=C.IdAgent)
	Left Join #temp3 D on (A.IdAgent=D.IdAgent)
	Left Join #temp4 E on (A.IdAgent=E.IdAgent)
	Left Join #temp5 F on (A.IdAgent=F.IdAgent)
	Left Join #temp6 G on (A.IdAgent=G.IdAgent)
	Left Join #temp7 H on (A.IdAgent=H.IdAgent)
	Left Join #temp8 I on (A.IdAgent=I.IdAgent)
	Left Join #temp9 J on (A.IdAgent=J.IdAgent)
    Left Join #temp10 k on (A.IdAgent=k.IdAgent)	
	

	Update #Result set
	NumTrans=IsNull(NumTrans1,0)+IsNull(NumTrans2,0)-IsNull(NumTransRej1,0)-IsNull(NumTrans2Rej,0),
	NumCancel=IsNull(NumCancel1,0)+IsNull(NumCancel2,0),
	AmountTrans=IsNull(AmountTrans1,0)+IsNull(AmountTrans2,0)-IsNull(AmountTransRej1,0)-IsNull(AmountTrans2Rej,0),
	OtherCharges=IsNull(OtherCharges1,0)+IsNull(OtherCharges2,0),
	CogsCancel=IsNull(CogsCancel1,0)+IsNull(CogsCancel2,0),
	AmountCancel=IsNull(AmountCancel1,0)+IsNull(AmountCancel2,0),
	FxResult=IsNull(FxResult1,0)+IsNull(FxResult2,0)-IsNull(FxResultRej1,0)-IsNull(FxResult2Rej,0)-IsNull(FxResultCancel1,0)-IsNull(FxResultCancel2,0),
	AgentcommissionMonthly=IsNull(AgentcommissionMonthly1,0)+IsNull(AgentcommissionMonthly2,0)-IsNull(AgentcommissionMonthlyRej1,0)-IsNull(AgentcommissionMonthly2Rej,0)-IsNull(AgentcommissionMonthlyCan1,0)-IsNull(AgentcommissionMonthlyCan2,0),
	AgentcommissionRetain=IsNull(AgentcommissionRetain1,0)+IsNull(AgentcommissionRetain2,0)-IsNull(AgentcommissionRetainRej1,0)-IsNull(AgentcommissionRetain2Rej,0)-IsNull(AgentcommissionRetainCan1,0)-IsNull(AgentcommissionRetainCan2,0)-IsNull(AgentcommissionRetainCancelLikeReject1,0)-IsNull(AgentcommissionRetainCancelLikeReject2,0),
	IncomeFee=IsNull(IncomeFee1,0)+IsNull(IncomeFee2,0)-IsNull(IncomeFeeRej1,0)-IsNull(IncomeFee2Rej,0)-IsNull(IncomeFeeCancelLikeReject1,0)-IsNull(IncomeFeeCancelLikeReject2,0), 
	FxFee=IsNull(FxFee1,0)+IsNull(FxFee2,0)-IsNull(FxFeeRej1,0)-IsNull(FxFee2Rej,0),
    FxFeeM=IsNull(FxFeeM1,0)+IsNull(FxFeeM2,0)-IsNull(FxFeeRejM1,0)-IsNull(FxFeeM2Rej,0),
    FxFeeR=IsNull(FxFeeR1,0)+IsNull(FxFeeR2,0)-IsNull(FxFeeRejR1,0)-IsNull(FxFeeR2Rej,0),
	UnclaimedNumTrans=IsNull(UnclaimedNumTrans1,0)+IsNull(UnclaimedNumTransClosed,0),
	UnclaimedAmount=IsNull(UnclaimedAmount1,0)+IsNull(UnclaimedAmountClosed,0),
	UnclaimedCOGS=IsNull(UnclaimedCOGS1,0)+IsNull(UnclaimedCOGSClosed,0),
    BankCommission= IsNull(BankCommission1,0) +IsNull(BankCommission2,0) -IsNull(BankCommission3,0) -IsNull(BankCommission4,0) -IsNull(BankCommission5,0) -IsNull(BankCommission6,0),---IsNull(BankCommission3,0)-IsNull(BankCommission4,0),
    PayerCommission=IsNull(PayerCommission1,0)+IsNull(PayerCommission2,0)-IsNull(PayerCommission3,0)-IsNull(PayerCommission4,0)-IsNull(PayerCommission5,0)-IsNull(PayerCommission6,0)---IsNull(PayerCommission3,0)-IsNull(PayerCommission4,0)
	

	--Update #Result set AgentcommissionMonthly=AgentcommissionMonthly-FxFee where AgentcommissionMonthly >0
	--Update #Result set AgentcommissionRetain=AgentcommissionRetain-FxFee where AgentcommissionRetain >0
    Update #Result set AgentcommissionMonthly=AgentcommissionMonthly-FxFeeM where AgentcommissionMonthly >0
	Update #Result set AgentcommissionRetain=AgentcommissionRetain-FxFeeR where AgentcommissionRetain >0
	Update #Result set NumNet=NumTrans-NumCancel,AmountNet=AmountTrans-AmountCancel,Result=IncomeFee-AgentcommissionMonthly-AgentcommissionRetain
	Update #Result set /*Payercommission=0,*/CogsNet=AmountNet-FxResult
	Update #Result set OtherCharges=0 where OtherCharges is null
	Update #Result set NetResult=FxResult+OtherCharges+Result,CogsTrans= CogsCancel+CogsNet


    ------------------------------Output --------------------------------------------------

	Select 
	IdAgent,AgentName,AgentCode,
	NumTrans,
	NumCancel,
	NumNet,
	AmountTrans,
	AmountCancel,
	AmountNet,
	CogsTrans,
	CogsCancel,
	CogsNet,
	FxResult,
	IncomeFee ,
	AgentcommissionMonthly ,
	AgentcommissionRetain,
	FxFee,
    FxFeeM,
    FxFeeR,
	--Payercommission,
	Result ,
	OtherCharges,
	NetResult,
	UnclaimedNumTrans,
	UnclaimedAmount,
	UnclaimedCOGS,
    case when PayerCommission>0 then PayerCommission else 0 end PayerCommission,
    case when BankCommission>0 then BankCommission else 0 end BankCommission,
    SalesRep
	from #Result
	Order by AgentCode