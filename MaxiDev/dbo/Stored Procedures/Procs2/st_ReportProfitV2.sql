CREATE procedure [dbo].[st_ReportProfitV2]
(
    @IdCountryCurrency int,
    @StartDate datetime,
    @EndDate datetime,
    @IdUserSeller int,
    @IdUserRequester int,
    @State nvarchar(2) = null,
    @Type int = null
)
as          

set arithabort on
Set nocount on

set @Type=isnull(@Type,1)

create table #profitData
(
    IdAgent	int,
    --IdCountryCurrency	int,
    IdCountry int not null default 0,
    NumTrans	int not null default 0,
    NumCancel	int not null default 0,
    NumRej	int not null default 0,
    UnclaimedNumTrans	int not null default 0,
    CogsTrans	money not null default 0,
    CogsCancel	money not null default 0,
    CogsRej	money not null default 0,
    UnclaimedCOGS money not null default 0,
    AmountTrans	money not null default 0,
    AmountCancel	money not null default 0,
    AmountRej	money not null default 0,
    UnclaimedAmount	money not null default 0,
    FxResult	money not null default 0,
    FxResultCancel	money not null default 0,
    FxResultRej	money not null default 0,
    AgentcommissionMonthly	money not null default 0,
    AgentcommissionMonthlyCancel	money not null default 0,
    AgentcommissionMonthlyRej	money not null default 0,
    AgentcommissionRetain	money not null default 0,
    AgentcommissionRetainCancel	money not null default 0,
    AgentcommissionRetainRej	money not null default 0,
    AgentcommissionRetainCancelLikeReject	money not null default 0,
    IncomeFeeCancelLikeReject	money not null default 0,
    IncomeFee	money not null default 0,
    IncomeFeeCancel	money not null default 0,
    IncomeFeeRej	money not null default 0,
    FxFee	money not null default 0,
    FxFeeCancel	money not null default 0,
    FxFeeRej	money not null default 0,
    FxFeeM	money not null default 0,
    FxFeeMCancel	money not null default 0,
    FxFeeMRej	money not null default 0,
    FxFeeR	money not null default 0,
    FxFeeRCancel	money not null default 0,
    FxFeeRRej	money not null default 0,
    BankCommission	money not null default 0,
    BankCommissionCancel	money not null default 0,
    BankCommissionRej	money not null default 0,
    PayerCommission	money not null default 0,
    PayerCommissionCancel   money not null default 0,
    PayerCommissionRej money not null default 0
)


if @IdCountryCurrency=0 set @IdCountryCurrency=null

Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)


declare @Date1 datetime = [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(@StartDate)-1),@StartDate))
declare @Date2 datetime = [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(@EndDate)-1),@EndDate))

---------Special Commission---------------

--Declare @BeginDateSpecialCommission datetime = DATEADD(day,(day(@StartDate)*-1)+1,@StartDate)



 Select  SC.IdAgent,case when @type= 1 then isnull(Idcountry,0) else IdCountry end Idcountry, SUM(SC.Commission) SpecialCommission        
 Into #tempSC                
 from [dbo].[SpecialCommissionBalance]  SC (nolock)
 join SpecialCommissionRule r on sc.IDSpecialCommissionRule=r.IDSpecialCommissionRule
 WHERE SC.[DateOfApplication]>= @StartDate AND SC.[DateOfApplication]<@EndDate
 Group by SC.IdAgent,case when @type= 1 then isnull(Idcountry,0) else IdCountry end 	

--Seller

declare @IsAllSeller bit 
set @IsAllSeller = (Select top 1 1 From [Users] (nolock) where @IdUserSeller=0 and [IdUser] = @IdUserRequester and [IdUserType] = 1) 

Create Table #SellerSubordinates
	(
		IdSeller int
	)

-------Nuevo proceso de busqueda recursiva de Sellers---------------------

declare @IdUserBaseText nvarchar(max)

set @IdUserBaseText='%/'+isnull(convert(varchar,@IdUserRequester),'0')+'/%'

;WITH items AS (
    SELECT iduser,username,userlogin 
    , 0 AS Level
    , CAST('/'+convert(varchar,iduser)+'/' as varchar(2000)) AS Path
    FROM users u (nolock)
    join seller s on u.iduser=s.iduserseller 
    WHERE idgenericstatus=1 and IdUserSellerParent is null
    
    UNION ALL

    SELECT u.iduser,u.username,u.userlogin 
    , Level + 1
    , CAST(itms.path+convert(varchar,isnull(u.iduser,''))+'/' as varchar(2000))  AS Path
    FROM users u (nolock)
    join seller s on u.iduser=s.iduserseller 
    INNER JOIN items itms ON itms.iduser = s.IdUserSellerParent
    WHERE idgenericstatus=1
)
SELECT iduser,username,userlogin,Level,Path into #SellerTree  FROM items 

Insert into #SellerSubordinates 
select iduser from #SellerTree where path like @IdUserBaseText and @IdUserSeller=0

--------------------------------------------------------------------------

Create Table #TempAgents (IdAgent int)

Create Table #Temp
(
Id int identity(1,1),
IdAgent Int,
AgentName nvarchar(max),
AgentCode nvarchar(max),
IdSalesRep int,
SalesRep nvarchar(max)
)

Insert into #TempAgents (IdAgent)
	Select Distinct t.IdAgent from profitdata t (nolock)    
	where dateofprofitdata>=@StartDate and dateofprofitdata<@EndDate and IdCountryCurrency=isnull(@IdCountryCurrency,IdCountryCurrency)
    union
     select ab.IDAGENT 
    from 
        agentbalance  ab With (Nolock)
    join 
        AgentOtherCharge oc  (nolock) on ab.idagentbalance=oc.idagentbalance and oc.IdOtherChargesMemo in (6,9,13,19,4,5,11,12,16,17,18,24,25)	
    where 
        ab.DateOfMovement>=@StartDate and
        ab.DateOfMovement<@EndDate and
        (ab.typeofmovement='CGO' OR ab.typeofmovement='DEBT')		
    union
    Select  
	ac.idAgent
	from 
        AgentCollectionDetail o  (Nolock)    
    inner join 
	    AgentCollection AC  (nolock) on AC.IdAgentCollection = o.IdAgentCollection 	
	where 
    o.DateofLastChange>=@StartDate and
    o.DateofLastChange<@EndDate	
    union    
    Select  SC.IdAgent            
        from [dbo].[SpecialCommissionBalance]  SC  (nolock)		
    WHERE SC.[DateOfApplication]>= @StartDate AND SC.[DateOfApplication]<@EndDate	        

	Insert into #Temp (IdAgent, AgentName, AgentCode,SalesRep,IdSalesRep)
	Select t.IdAgent, A.AgentName, A.AgentCode, isnull(UserName,''),a.IdUserSeller
	from #TempAgents T
	inner join Agent A (nolock) on (A.IdAgent = T.IdAgent) and a.AgentState=isnull(@State,a.AgentState)
    left join users u (nolock) on u.iduser=a.IdUserSeller
	where @IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates))    

    
------------------------------Other Charges  --------------------------------------------------
    select  DISTINCT
        ab.IDAGENT ,Sum(case when ab.DebitOrCredit='Credit' then ab.Amount else ab.Amount*(-1) end) over(Partition by ab.IdAgent) OtherCharges1,        
        Sum(case when oc.IdOtherChargesMemo in (6,9,13,19) then case when ab.DebitOrCredit='Credit' then ab.Amount else ab.Amount*(-1) end else 0 end) over(Partition by ab.IdAgent) OtherChargesC1,
        Sum(case when oc.IdOtherChargesMemo in (4,5,11,12,16,17,18,24,25) then case when ab.DebitOrCredit!='Credit' then ab.Amount else ab.Amount*(-1) end else 0 end) over(Partition by ab.IdAgent) OtherChargesD1
        into #temp7
    from 
        agentbalance  ab With (Nolock)
    join AgentOtherCharge oc on ab.idagentbalance=oc.idagentbalance and oc.IdOtherChargesMemo in (6,9,13,19,4,5,11,12,16,17,18,24,25)
    where 
        ab.DateOfMovement>=@StartDate and
        ab.DateOfMovement<@EndDate and
        (ab.typeofmovement='CGO' OR ab.typeofmovement='DEBT')


    Select  distinct
	ac.idAgent,
	Sum(o.AmountToPay) 	over(Partition by ac.IdAgent) as OtherCharges2,
    Sum(case when o.AmountToPay>0 then o.AmountToPay else 0 end) over(Partition by IdAgent) OtherChargesC2,
    Sum(case when o.AmountToPay<0 then o.AmountToPay*(-1) else 0 end) over(Partition by IdAgent) OtherChargesD2
    into #temp10
	from 
        AgentCollectionDetail o  With (Nolock)    
    inner join 
	    AgentCollection AC on AC.IdAgentCollection = o.IdAgentCollection 
	where 
    o.DateofLastChange>=@StartDate and
    o.DateofLastChange<@EndDate

    insert into #profitData
    select 
    IdAgent, 
    case when @type= 1 then 0 else IdCountry end IdCountry,
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
    sum(PayerCommissionRej)PayerCommissionRej
    from profitdata where dateofprofitdata>=@StartDate and dateofprofitdata<@EndDate and idagent in(select idagent #TempAgents) and IdCountryCurrency=isnull(@IdCountryCurrency,IdCountryCurrency)
    group by IdAgent,case when @type= 1 then 0 else IdCountry end

    if (@Type=1)
    begin
        insert into #ProfitData 
        (IdAgent)
        select idagent from #TempAgents where idagent not in (select idagent from #ProfitData)
    end

select t.IdAgent,AgentCode,AgentName,NumTrans,NumCancel,NumNet,AmountTrans,AmountCancel,AmountNet,CogsTrans,CogsCancel,CogsNet,FxResult,IncomeFee,AgentcommissionMonthly,AgentcommissionRetain,FxFeeM,FxFeeR,SpecialCommission,PayerCommission,UnclaimedAmount,UnclaimedCOGS,OtherCharges,OtherChargesC,OtherChargesD,Result,NetResult,case when NumNet!=0 then netresult/NumNet else 0 end Margin,isnull(UserName,'') Parent,SalesRep, isnull(CountryCode,'') CountryCode from(
    select 
        pd.IdAgent,
        AgentCode,
        AgentName,	
        pd.IdCountry,
        NumTrans,
        NumRej+NumCancel NumCancel,
        NumTrans-(NumRej+NumCancel) NumNet, --NumTrans-NumCancel
        AmountTrans,
        (AmountCancel+AmountRej) AmountCancel,
        AmountTrans-(AmountCancel+AmountRej) AmountNet, --AmountTrans-AmountCancel
        (CogsCancel+CogsRej) + ((AmountTrans-(AmountCancel+AmountRej))-(FxResult-FxResultCancel-FxResultRej)) CogsTrans,
        CogsCancel+CogsRej CogsCancel,
        (AmountTrans-(AmountCancel+AmountRej))-(FxResult-FxResultCancel-FxResultRej) CogsNet, --AmountNet-FxResult 
        FxResult-FxResultCancel-FxResultRej FxResult,
        IncomeFee-IncomeFeeRej-IncomeFeeCancelLikeReject IncomeFee,
        case when AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej>0 then AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej-(FxFeeM-FxFeeMRej) else AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej end AgentcommissionMonthly,
        case when AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject>0 then AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject-(FxFeeR-FxFeeRRej) else AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject end AgentcommissionRetain,
        FxFeeM-FxFeeMRej FxFeeM,
        FxFeeR-FxFeeRRej FxFeeR,
        isnull(SpecialCommission,0) SpecialCommission,
        case when PayerCommission-PayerCommissionCancel-PayerCommissionRej>0 then PayerCommission-PayerCommissionCancel-PayerCommissionRej else 0 end PayerCommission,
        UnclaimedAmount,
        UnclaimedCOGS,
        IsNull(OtherCharges1,0)+IsNull(OtherCharges2,0) OtherCharges,
        IsNull(OtherChargesC1,0)+IsNull(OtherChargesC2,0) OtherChargesC,
        IsNull(OtherChargesD1,0)+IsNull(OtherChargesD2,0) OtherChargesD,
        (FxResult-FxResultCancel-FxResultRej)+(IncomeFee-IncomeFeeRej-IncomeFeeCancelLikeReject)-(case when AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej>0 then AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej-(FxFeeM-FxFeeMRej) else AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej end)-(case when AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject>0 then AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject-(FxFeeR-FxFeeRRej) else AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject end)-(FxFee-FxFeeRej)- (case when PayerCommission-PayerCommissionCancel-PayerCommissionRej>0 then PayerCommission-PayerCommissionCancel-PayerCommissionRej else 0 end)+(UnclaimedAmount)-(UnclaimedCOGS) Result, --FxResult+IncomeFee-AgentcommissionMonthly-AgentcommissionRetain-FxFee-PayerCommission+UnclaimedAmount-UnclaimedCOGS
        (FxResult-FxResultCancel-FxResultRej)+(IncomeFee-IncomeFeeRej-IncomeFeeCancelLikeReject)-(case when AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej>0 then AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej-(FxFeeM-FxFeeMRej) else AgentcommissionMonthly-AgentcommissionMonthlyCancel-AgentcommissionMonthlyRej end)-(case when AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject>0 then AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject-(FxFeeR-FxFeeRRej) else AgentcommissionRetain-AgentcommissionRetainCancel-AgentcommissionRetainRej-AgentcommissionRetainCancelLikeReject end)-(FxFee-FxFeeRej)- (case when PayerCommission-PayerCommissionCancel-PayerCommissionRej>0 then PayerCommission-PayerCommissionCancel-PayerCommissionRej else 0 end)-(UnclaimedAmount)+(UnclaimedCOGS)-(IsNull(OtherChargesC1,0)+IsNull(OtherChargesC2,0))+(IsNull(OtherChargesD1,0)+IsNull(OtherChargesD2,0))-isnull(SpecialCommission,0)  NetResult, --FxResult+IncomeFee-AgentcommissionMonthly-AgentcommissionRetain-FxFee-PayerCommission-UnclaimedAmount+UnclaimedCOGS-OtherChargesC+OtherChargesD-SpecialCommission
        (select IdUserSellerParent from Seller (nolock) where IdUserSeller=IdSalesRep) IdUserSellerParent,
        SalesRep
    from #profitData pd
    left join #tempSC sc on pd.idagent=sc.idagent and pd.IdCountry=sc.Idcountry
    left join #temp7 oc1 on pd.IdAgent=oc1.IdAgent
    left join #temp10 oc2 on pd.IdAgent=oc2.IdAgent
    join #Temp ad on pd.IdAgent=ad.IdAgent
    --order by pd.idagent
) t
left join users u (nolock) on u.iduser=isnull(IdUserSellerParent,0)
left join country c (nolock) on t.IdCountry=c.IdCountry
Order by AgentCode