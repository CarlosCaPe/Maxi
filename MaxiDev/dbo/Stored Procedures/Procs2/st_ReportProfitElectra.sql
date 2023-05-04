CREATE procedure [dbo].[st_ReportProfitElectra]
(
--@IdCountryCurrency int,
@StartDate datetime,
@EndDate datetime,
@IdUserSeller int,
@IdUserRequester int
)
as              
Set nocount on

Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)

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
Payercommission money,
Result money,
OtherCharges money,
NetResult money,
UnclaimedNumTrans Int,
UnclaimedAmount money,
UnclaimedCOGS Money
)



Insert into #TempAgents (IdAgent)
	Select Distinct IdAgent from Transfer with (nolock)
	--where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
	where DateOfTransfer>@StartDate and DateOfTransfer<@EndDate and idpayer=504
	
	Union
	Select IdAgent from TransferClosed  with (nolock)
	--where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
	where DateOfTransfer>@StartDate and DateOfTransfer<@EndDate and idpayer=504
	
	Union
	Select IdAgent from TransferClosed  with (nolock)
	--where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
	where DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22) and idpayer=504
	
	Union
	Select IdAgent from Transfer  with (nolock)
	--where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
	where	DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22) and idpayer=504
	
	Union
	Select IdAgent from Transfer  with (nolock)
	--where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
	where DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (27) and idpayer=504

	Insert into #Temp (IdAgent, AgentName, AgentCode)
	Select t.IdAgent, A.AgentName, A.AgentCode 
	from #TempAgents T
	inner join Agent A on (A.IdAgent = T.IdAgent)
	where @IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates))



	Select distinct 
	IdAgent,
	Count(1) over(Partition by IdAgent) as NumTrans1,
	Sum(AmountInDollars) over(Partition by IdAgent) as AmountTrans1,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by IdAgent) as FxResult1,
	SUM(case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionMonthly1,
	SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionRetain1,
	SUM(Fee) over (Partition by IdAgent) as IncomeFee1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by IdAgent) as FxFee1
	into #temp1
	from  Transfer  With (Nolock)
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
	where
    DateOfTransfer>@StartDate and
    DateOfTransfer<@EndDate and
	IdAgent in (Select IdAgent from #TempAgents)  and idpayer=504



	Select distinct 
	idAgent,
	Count(1) over(Partition by IdAgent) as NumTrans2,
	Sum(AmountInDollars) over(Partition by IdAgent) as AmountTrans2,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by IdAgent) as FxResult2,
	SUM(case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionMonthly2,
	SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionRetain2,
	SUM(Fee) over (Partition by IdAgent) as IncomeFee2,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by IdAgent) as FxFee2
	into #temp2 
	from TransferClosed   With (Nolock)
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
	where
    DateOfTransfer>@StartDate and
    DateOfTransfer<@EndDate and
	IdAgent in (Select IdAgent from #TempAgents)  and idpayer=504
	


	Select distinct 
	idAgent,
	Count(1) over(Partition by IdAgent) as NumTransRej1,
	Sum(AmountInDollars) over(Partition by IdAgent) as AmountTransRej1,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by IdAgent) as FxResultRej1,
	SUM(case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionMonthlyRej1,
	SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionRetainRej1,
	SUM(Fee) over (Partition by IdAgent) as IncomeFeeRej1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by IdAgent) as FxFeeRej1
	into #temp3 
	from Transfer   With (Nolock)
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
	where
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=31  and idpayer=504
	



	Select distinct 
	idAgent,
	Count(1) over(Partition by IdAgent) as NumTrans2Rej,
	Sum(AmountInDollars) over(Partition by IdAgent) as AmountTrans2Rej,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over (Partition by IdAgent) as FxResult2Rej,
	SUM(case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionMonthly2Rej,
	SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) over (Partition by IdAgent) as AgentcommissionRetain2Rej,
	SUM(Fee) over (Partition by IdAgent) as IncomeFee2Rej,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  over (Partition by IdAgent) as FxFee2Rej
	into #temp4 
	from TransferClosed   With (Nolock)
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
	where
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=31  and idpayer=504
	


	Select distinct 
	idAgent,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by IdAgent) as CogsCancel1,
	COUNT(1) over(Partition by IdAgent)  as NumCancel1,
	SUM(AmountInDollars) over(Partition by IdAgent) as AmountCancel1,
	SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over(Partition by IdAgent) as FxResultCancel1,
	SUM(case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end) over(Partition by IdAgent)  as AgentcommissionMonthlyCan1,
	SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then 0 else 0 end) over(Partition by IdAgent) as AgentcommissionRetainCan1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider) over(Partition by IdAgent) as FxFeeCan1,
	SUM(Fee) over(Partition by IdAgent) as IncomeFeeCan1,
	SUM(case when TA.IdTransfer is null then 0 else Fee end) over(Partition by IdAgent) as IncomeFeeCancelLikeReject1,
	SUM(case when TA.IdTransfer is null then 0 else (case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) end) over(Partition by IdAgent) as AgentcommissionRetainCancelLikeReject1
	into #temp5 
	from Transfer T   With (Nolock)
	left join dbo.TransferNotAllowedResend TA on T.IdTransfer=TA.IdTransfer
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
	where
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=22  and idpayer=504

		
	Select distinct 
	T.idAgent,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by T.IdAgent) as CogsCancel2,
	COUNT(1) over(Partition by T.IdAgent)  as NumCancel2,
	SUM(AmountInDollars) over(Partition by T.IdAgent) as AmountCancel2,
	SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) over(Partition by T.IdAgent) as FxResultCancel2,
	SUM(case when Fee+AmountInDollars =TotalAmountToCorporate Then AgentCommission else 0 end) over(Partition by T.IdAgent)  as AgentcommissionMonthlyCan2,
	SUM(case when Fee+AmountInDollars <>TotalAmountToCorporate Then 0 else 0 end) over(Partition by T.IdAgent) as AgentcommissionRetainCan2,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider) over(Partition by T.IdAgent) as FxFeeCan2,
	SUM(Fee) over(Partition by T.IdAgent) as IncomeFeeCan2,
	SUM(case when TA.IdTransfer is null then 0 else Fee end) over(Partition by T.IdAgent) as IncomeFeeCancelLikeReject2,
	SUM(case when TA.IdTransfer is null then 0 else (case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) end) over(Partition by T.IdAgent) as AgentcommissionRetainCancelLikeReject2
	into #temp6
	from TransferClosed T   With (Nolock)
	left join dbo.TransferNotAllowedResend TA on T.IdTransferClosed=TA.IdTransfer
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
	where
    T.DateStatusChange>@StartDate and
    T.DateStatusChange<@EndDate and
	T.IdStatus=22  and idpayer=504


	Select distinct 
	idAgent,
	Sum(Amount) over(Partition by IdAgent) as OtherCharges1
	into #temp7
	from AgentOtherCharge   With (Nolock)
	where 
    ChargeDate>@StartDate and
    ChargeDate<@EndDate 
	


    
	Select distinct 
	idAgent,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by IdAgent) as UnclaimedCOGS1,
	COUNT(1) over(Partition by IdAgent) as UnclaimedNumTrans1,
	SUM(AmountInDollars) over(Partition by IdAgent) as UnclaimedAmount1
	into #temp8
	from Transfer   With (Nolock)
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
	where
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=27  and idpayer=504
	
		
	
	Select distinct 
	idAgent,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by IdAgent) as UnclaimedCOGSClosed,
	COUNT(1) over(Partition by IdAgent) as UnclaimedNumTransClosed,
	SUM(AmountInDollars) over(Partition by IdAgent) as UnclaimedAmountClosed
	into #temp9
	from TransferClosed   With (Nolock)
	--where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
	where
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=27  and idpayer=504
	



	Select 
	A.*,
	B.NumTrans1,
	B.AmountTrans1,
	B.FxResult1,
	B.AgentcommissionMonthly1,
	B.AgentcommissionRetain1,
	B.IncomeFee1,
	B.FxFee1,
	C.NumTrans2,
	C.AmountTrans2,
	C.FxResult2,
	C.AgentcommissionMonthly2,
	C.AgentcommissionRetain2,
	C.IncomeFee2,
	C.FxFee2,
	D.NumTransRej1,
	D.AmountTransRej1,
	D.FxResultRej1,
	D.AgentcommissionMonthlyRej1,
	D.AgentcommissionRetainRej1,
	D.IncomeFeeRej1,
	D.FxFeeRej1,
	E.NumTrans2Rej,
	E.AmountTrans2Rej,
	E.FxResult2Rej,
	E.AgentcommissionMonthly2Rej,
	E.AgentcommissionRetain2Rej,
	E.IncomeFee2Rej,
	E.FxFee2Rej,
	F.CogsCancel1,
	F.NumCancel1,
	F.AmountCancel1,
	F.FxResultCancel1,
	F.AgentcommissionMonthlyCan1,
	F.AgentcommissionRetainCan1,
	F.FxFeeCan1,
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
	G.IncomeFeeCan2,
	G.IncomeFeeCancelLikeReject2,
	G.AgentcommissionRetainCancelLikeReject2,
	H.OtherCharges1,
	I.UnclaimedCOGS1,
	I.UnclaimedNumTrans1,
	I.UnclaimedAmount1,
	J.UnclaimedCOGSClosed,
	J.UnclaimedNumTransClosed,
	J.UnclaimedAmountClosed
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
	
	
	

	Update #Result set
	NumTrans=IsNull(NumTrans1,0)+IsNull(NumTrans2,0)-IsNull(NumTransRej1,0)-IsNull(NumTrans2Rej,0),
	NumCancel=IsNull(NumCancel1,0)+IsNull(NumCancel2,0),
	AmountTrans=IsNull(AmountTrans1,0)+IsNull(AmountTrans2,0)-IsNull(AmountTransRej1,0)-IsNull(AmountTrans2Rej,0),
	OtherCharges=IsNull(OtherCharges1,0),
	CogsCancel=IsNull(CogsCancel1,0)+IsNull(CogsCancel2,0),
	AmountCancel=IsNull(AmountCancel1,0)+IsNull(AmountCancel2,0),
	FxResult=IsNull(FxResult1,0)+IsNull(FxResult2,0)-IsNull(FxResultRej1,0)-IsNull(FxResult2Rej,0)-IsNull(FxResultCancel1,0)-IsNull(FxResultCancel2,0),
	AgentcommissionMonthly=IsNull(AgentcommissionMonthly1,0)+IsNull(AgentcommissionMonthly2,0)-IsNull(AgentcommissionMonthlyRej1,0)-IsNull(AgentcommissionMonthly2Rej,0)-IsNull(AgentcommissionMonthlyCan1,0)-IsNull(AgentcommissionMonthlyCan2,0),
	AgentcommissionRetain=IsNull(AgentcommissionRetain1,0)+IsNull(AgentcommissionRetain2,0)-IsNull(AgentcommissionRetainRej1,0)-IsNull(AgentcommissionRetain2Rej,0)-IsNull(AgentcommissionRetainCan1,0)-IsNull(AgentcommissionRetainCan2,0)-IsNull(AgentcommissionRetainCancelLikeReject1,0)-IsNull(AgentcommissionRetainCancelLikeReject2,0),
	IncomeFee=IsNull(IncomeFee1,0)+IsNull(IncomeFee2,0)-IsNull(IncomeFeeRej1,0)-IsNull(IncomeFee2Rej,0)-IsNull(IncomeFeeCancelLikeReject1,0)-IsNull(IncomeFeeCancelLikeReject2,0), 
	FxFee=IsNull(FxFee1,0)+IsNull(FxFee2,0)-IsNull(FxFeeRej1,0)-IsNull(FxFee2Rej,0),
	UnclaimedNumTrans=IsNull(UnclaimedNumTrans1,0)+IsNull(UnclaimedNumTransClosed,0),
	UnclaimedAmount=IsNull(UnclaimedAmount1,0)+IsNull(UnclaimedAmountClosed,0),
	UnclaimedCOGS=IsNull(UnclaimedCOGS1,0)+IsNull(UnclaimedCOGSClosed,0)

	

	Update #Result set AgentcommissionMonthly=AgentcommissionMonthly-FxFee where AgentcommissionMonthly >0
	Update #Result set AgentcommissionRetain=AgentcommissionRetain-FxFee where AgentcommissionRetain >0
	Update #Result set NumNet=NumTrans-NumCancel,AmountNet=AmountTrans-AmountCancel,Result=IncomeFee-AgentcommissionMonthly-AgentcommissionRetain
	Update #Result set Payercommission=0,CogsNet=AmountNet-FxResult
	Update #Result set OtherCharges=0 where OtherCharges is null
	Update #Result set NetResult=FxResult+OtherCharges+Result,CogsTrans= CogsCancel+CogsNet




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
	Payercommission,
	Result ,
	OtherCharges,
	NetResult,
	UnclaimedNumTrans,
	UnclaimedAmount,
	UnclaimedCOGS
	from #Result
	Order by AgentCode

