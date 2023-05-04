CREATE  procedure [Corp].[st_ReportProfitVCountry]
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
/********************************************************************
<Author>???</Author>
<app>Corporate</app>
<Description>Gets Profit Report</Description>

<ChangeLog>
<log Date="12/06/2017" Author="Forced Indexes in TransferClosed">   </log>
<log Date="24/01/2018" Author="jdarellano" Name="#1">Performance: se elimina index forzado de tabla "AgentBalance".</log>
<log Date="26/01/2018" Author="jmolina" Name="#2">Performance: Mejora en proceso de consultas".</log>
<log Date="01/11/2018" Author="jmolina" Name="#3">Se agrega filtro para payerconfig solo activos(IdGenericStatus = 1)".</log>
<log Date="01/03/2018" Author="jmolina" Name="#4">Se agrega IdCountryCurrency en las comisiones de pagadores y se agrega al join de calculo de remesas".</log>
<log Date="07/03/2018" Author="jmolina" Name="#5">Cambia metodo de agrupado en calculos de remeasas, se elimina el over partition By y se asigna el Group BY)".</log>

</ChangeLog>

*********************************************************************/
--------------------------------
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
--------------------------------

set arithabort on
--Set nocount on

set @Type=isnull(@Type,1)

Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)


declare @Date1 datetime = [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(@StartDate)-1),@StartDate))
declare @Date2 datetime = [dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(@EndDate)-1),@EndDate))

declare @ReportCorpType bit

if (exists (select 1 from Users (nolock) where idUser=@IdUserRequester and IdUserType=1 ) and @IdUserSeller=0)
	BEGIN
		set @ReportCorpType=1
	END
ELSE
	BEGIN
		set @ReportCorpType=0
	END

---------Special Commission---------------

--Declare @BeginDateSpecialCommission datetime = DATEADD(day,(day(@StartDate)*-1)+1,@StartDate)

 Select  SC.IdAgent,      
         SUM(SC.Commission) SpecialCommission        
 Into #tempSC                
 from [dbo].[SpecialCommissionBalance]  SC (nolock)
 join SpecialCommissionRule r (nolock) on sc.IDSpecialCommissionRule=r.IDSpecialCommissionRule
 WHERE SC.[DateOfApplication]>= @StartDate AND SC.[DateOfApplication]<@EndDate
 Group by 
        SC.IdAgent
         	

--obtener bankcommissions para el reporte
select distinct DateOfBankCommission,FactorNew into #bankcommission from bankcommission (nolock) where active=1 and DateOfBankCommission>=@Date1 and DateOfBankCommission<=@Date2

--obtener payercommissions para el reporte
select 
    distinct idgateway,IdPayer, IdPaymentType, CommissionNew,DateOfPayerConfigCommission, IdCountryCurrency into #payercommission --#4
from 
    payerConfigcommission c (nolock)
join 
    --payerconfig x (nolock) on c.idpayerconfig=x.idpayerconfig 
	payerconfig x (nolock) on c.idpayerconfig=x.idpayerconfig and x.IdPayerConfig not in (711,807)
where 
    active=1 and DateOfPayerConfigCommission>=@Date1 and DateOfPayerConfigCommission<=@Date2 and x.IdGenericStatus = 1 --#3

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
    join seller s (nolock) on u.iduser=s.iduserseller 
    WHERE idgenericstatus=1 and IdUserSellerParent is null
    
    UNION ALL

    SELECT u.iduser,u.username,u.userlogin 
    , Level + 1
    , CAST(itms.path+convert(varchar,isnull(u.iduser,''))+'/' as varchar(2000))  AS Path
    FROM users u (nolock)
    join seller s (nolock) on u.iduser=s.iduserseller 
    INNER JOIN items itms ON itms.iduser = s.IdUserSellerParent
    WHERE idgenericstatus=1
)
SELECT iduser,username,userlogin,Level,Path into #SellerTree  FROM items

Insert into #SellerSubordinates 
select iduser from #SellerTree where path like @IdUserBaseText and @IdUserSeller=0

--------------------------------------------------------------------------

Create Table #TempAgents (IdAgent int,IdCountry int, IdCountryCurrency int)

Create Table #Temp
(
Id int identity(1,1),
IdAgent Int,
IdCountry Int,
IdCountryCurrency int,
AgentName nvarchar(max),
AgentCode nvarchar(max),
IdSalesRep int,
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
OtherChargesD money,
OtherChargesC money,
NetResult money,
UnclaimedNumTrans Int,
UnclaimedAmount money,
UnclaimedCOGS Money,
BankCommission float,
PayerCommission money
)

if @Type=1
begin
--#2
    Insert into #TempAgents (IdAgent,Idcountry, IdCountryCurrency)
	    Select Distinct t.IdAgent, 0 IdCountry, 0 IdCountryCurrency 
		  from [dbo].[Transfer] AS t (nolock)
	     where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		   and DateOfTransfer>@StartDate 
		   and DateOfTransfer<@EndDate
		    OR (
		        DateStatusChange>@StartDate 
			and DateStatusChange<@EndDate 
			and IdStatus in (31,22, 27)
		   )
	    Union
	    Select t.IdAgent, 0 IdCountry, 0 IdCountryCurrency  
		  from TransferClosed AS t (nolock) -- WITH (nolock,INDEX(ixDateOfTransfer))
	     where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		   and DateOfTransfer>@StartDate 
		   and DateOfTransfer<@EndDate
		    OR (
		         DateStatusChange>@StartDate 
			 and DateStatusChange<@EndDate 
			 and IdStatus in (31,22)
		   )
	    Union
	    /*Select t.IdAgent, 0 IdCountry, 0 IdCountryCurrency  from TransferClosed t  WITH (nolock,INDEX(ix10_TransferClosed))
	    where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)
	    Union
	    Select t.IdAgent, 0 IdCountry, 0 IdCountryCurrency  from Transfer t  (nolock)    
	    where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)
        Union    
	    Select t.IdAgent, 0 IdCountry, 0 IdCountryCurrency  from Transfer t  (nolock)    
	    where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (27)    
        union*/
		--#2
         select ab.IDAGENT, 0 IdCountry, 0 IdCountryCurrency  
        from 
            --agentbalance  ab With (Nolock, index(ix2_agentbalance))
			agentbalance  ab With (Nolock)--#1
        join 
            AgentOtherCharge oc  (nolock) on ab.idagentbalance=oc.idagentbalance and oc.IdOtherChargesMemo in (6,9,13,19,4,5,11,12,16,17,18,24,25)	
        where 
            ab.DateOfMovement>=@StartDate and
            ab.DateOfMovement<@EndDate and
            (ab.typeofmovement='CGO' OR ab.typeofmovement='DEBT')		
        union
        Select  
	    ac.idAgent, 0 IdCountry, 0 IdCountryCurrency 
	    from 
            AgentCollectionDetail o  (Nolock)    
        inner join 
	        AgentCollection AC  (nolock) on AC.IdAgentCollection = o.IdAgentCollection 	
	    where 
        o.DateofLastChange>=@StartDate and
        o.DateofLastChange<@EndDate	
        union    
        Select  SC.IdAgent, 0 IdCountry, 0 IdCountryCurrency             
            from [dbo].[SpecialCommissionBalance]  SC  (nolock)		
        WHERE SC.[DateOfApplication]>= @StartDate AND SC.[DateOfApplication]<@EndDate	
end

if @Type=2
begin 
--#2
        Insert into #TempAgents (IdAgent,Idcountry,IdCountryCurrency)
	    Select Distinct t.IdAgent, IdCountry, 0 IdCountryCurrency   
		from [dbo].[Transfer] as t (nolock)    
			join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	    where t.IdCountryCurrency= case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End 
		    and DateOfTransfer>@StartDate 
			and DateOfTransfer<@EndDate
			 OR (
		        DateStatusChange>@StartDate 
			and DateStatusChange<@EndDate 
			and IdStatus in (31,22, 27)
		   )
	    Union
	    Select t.IdAgent, IdCountry, 0 IdCountryCurrency   
		from [dbo].[TransferClosed] t (nolock) --WITH (nolock,INDEX(ixDateOfTransfer))
	    where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		    and DateOfTransfer>@StartDate 
			and DateOfTransfer<@EndDate
			 OR (
		         DateStatusChange>@StartDate 
			 and DateStatusChange<@EndDate 
			 and IdStatus in (31, 22)
		   )
	    /*Union
	    Select t.IdAgent, IdCountry, 0 IdCountryCurrency   from TransferClosed t  WITH (nolock,INDEX(ix10_TransferClosed))
	    where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)
	    Union
	    Select t.IdAgent, IdCountry, 0 IdCountryCurrency   from Transfer t  (nolock)    
        join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	    where t.IdCountryCurrency= case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)
        Union    
	    Select t.IdAgent, IdCountry, 0 IdCountryCurrency   from Transfer t  (nolock)    
        join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	    where t.IdCountryCurrency= case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (27)*/                     
			--#2
        /*union    
        Select  SC.IdAgent, IdCountry, 0 IdCountryCurrency              
            from [dbo].[SpecialCommissionBalance]  SC  (nolock)		
        join SpecialCommissionRule r (nolock) on sc.IdSpecialCommissionRule=r.IdSpecialCommissionRule
        WHERE SC.[DateOfApplication]>= @StartDate AND SC.[DateOfApplication]<@EndDate
        */
end

if @Type=3
begin 
--#2
        Insert into #TempAgents (IdAgent,Idcountry,IdCountryCurrency)
	    Select Distinct t.IdAgent, 0 IdCountry, t.IdCountryCurrency   
		  from [dbo].[Transfer] t (nolock)    
          join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	     where t.IdCountryCurrency= case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End 
		   and DateOfTransfer>@StartDate 
		   and DateOfTransfer<@EndDate
			OR (
		        DateStatusChange>@StartDate 
			and DateStatusChange<@EndDate 
			and IdStatus in (31, 22, 27)
		   )
	    Union
	    Select t.IdAgent, 0 IdCountry, t.IdCountryCurrency  
		  from [dbo].TransferClosed t (nolock) --WITH (nolock,INDEX(ixDateOfTransfer))
	     where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		   and DateOfTransfer>@StartDate 
		   and DateOfTransfer<@EndDate
			OR (
		         DateStatusChange>@StartDate 
			 and DateStatusChange<@EndDate 
			 and IdStatus in (31, 22)
		   )
	   /* Union
	    Select t.IdAgent, 0 IdCountry, t.IdCountryCurrency   from TransferClosed t  WITH (nolock,INDEX(ix10_TransferClosed))
	    where IdCountryCurrency= case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)
	    Union
	    Select t.IdAgent, 0 IdCountry, t.IdCountryCurrency  from Transfer t  (nolock)    
        join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	    where t.IdCountryCurrency= case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (31,22)
        Union    
	    Select t.IdAgent, 0 IdCountry, t.IdCountryCurrency   from Transfer t  (nolock)    
        join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	    where t.IdCountryCurrency= case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End 
		    and DateStatusChange>@StartDate and DateStatusChange<@EndDate and IdStatus in (27)                     */
			--#2
        /*union    
        Select  SC.IdAgent,0 IdCountry, 0 IdCountryCurrency              
            from [dbo].[SpecialCommissionBalance]  SC  (nolock)		
        join SpecialCommissionRule r (nolock) on sc.IdSpecialCommissionRule=r.IdSpecialCommissionRule
        WHERE SC.[DateOfApplication]>= @StartDate AND SC.[DateOfApplication]<@EndDate	*/
end

	Insert into #Temp (IdAgent,IdCountry,IdCountryCurrency, AgentName, AgentCode,SalesRep,IdSalesRep)
	Select t.IdAgent,t.IdCountry,t.IdCountryCurrency, A.AgentName, A.AgentCode, isnull(UserName,''),a.IdUserSeller
	from #TempAgents T
	inner join Agent A (nolock) on (A.IdAgent = T.IdAgent) and a.AgentState=isnull(@State,a.AgentState)
    left join users u (nolock) on u.iduser=a.IdUserSeller
	where @IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates))    

    ------------------------------Tranfer operation--------------------------------------------------

    select 
    t.IdAgent,  
    IdCountry, --case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,
    t.IdCountryCurrency, --case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency,
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
	IdAgentBankDeposit
    into #temp1a
	from  [dbo].[Transfer]  t With (Nolock)    
    join agent a (Nolock) on t.idagent=a.idagent
    join CountryCurrency cc (Nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	where t.IdCountryCurrency=case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End  and
    DateOfTransfer>@StartDate and
    DateOfTransfer<@EndDate and
	t.IdAgent in (Select IdAgent from #TempAgents)

	Select distinct 
	t.IdAgent,
    case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,--IdCountry,
    case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency, --t.IdCountryCurrency,
	Count(1) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as NumTrans1,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as CogsTrans1,
	Sum(AmountInDollars) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AmountTrans1,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxResult1,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionMonthly1,
	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionRetain1,
	SUM(Fee) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as IncomeFee1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFee1,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeM1,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeR1,
    sum(case when IdAgentBankDeposit in ( 43, 46, 42) then 0 else isnull(AmountInDollars*FactorNew,0) end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as BankCommission1,
    sum(isnull(CommissionNew,0)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as PayerCommission1
	into #temp1
	from  #temp1a  t --With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype and t.IdCountryCurrency = p.IdCountryCurrency --#4
	GROUP BY t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end, case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end --#5
	
	DROP TABLE #temp1a

    ------------------------------Tranfer Closed operation--------------------------------------------------

    select 
    t.IdAgent,  
    IdCountry, --case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,
    t.IdCountryCurrency, --case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency,
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
	IdAgentBankDeposit
    into #temp2a
	from  TransferClosed  t With (Nolock)    
    join agent a (nolock) on t.idagent=a.idagent
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateOfTransfer>@StartDate and
    DateOfTransfer<@EndDate and
	t.IdAgent in (Select IdAgent from #TempAgents)

	Select distinct 
	t.idAgent,
    case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,--IdCountry,
    case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency, --t.IdCountryCurrency,
	Count(1) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as NumTrans2,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as CogsTrans2,
	Sum(AmountInDollars) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AmountTrans2,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxResult2,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionMonthly2,
	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionRetain2,
	SUM(Fee) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as IncomeFee2,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFee2,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeM2,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeR2,
    sum(case when IdAgentBankDeposit in ( 43, 46, 42) then 0 else isnull(AmountInDollars*FactorNew,0) end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as BankCommission2,
    sum(isnull(CommissionNew,0)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as PayerCommission2
	into #temp2 
	from #temp2a  t With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype and t.IdCountryCurrency = p.IdCountryCurrency--#4
	GROUP BY t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end, case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end --#5

	DROP TABLE #temp2a
    ------------------------------Tranfer Rejected --------------------------------------------------

    select 
    t.IdAgent,    
    IdCountry, --case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,
    t.IdCountryCurrency, --case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency,
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
	IdAgentBankDeposit
    into #temp3a
	from  Transfer  t With (Nolock)  
    join agent a (nolock) on t.idagent=a.idagent
    join CountryCurrency cc (nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	where t.IdCountryCurrency=case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	t.IdAgent in (Select IdAgent from #TempAgents) and
    IdStatus=31

	Select distinct 
	idAgent,
    case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,--IdCountry,
    case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency, --t.IdCountryCurrency,
	Count(1) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as NumTransRej1,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as CogsRej1,
	Sum(AmountInDollars) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AmountTransRej1,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxResultRej1,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionMonthlyRej1,
	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionRetainRej1,
	SUM(Fee) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as IncomeFeeRej1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeRej1,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeRejM1,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeRejR1,
    sum(case when IdAgentBankDeposit in ( 43, 46, 42) then 0 else isnull(AmountInDollars*FactorNew,0) end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as BankCommission3,
    sum(isnull(CommissionNew,0)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as PayerCommission3
	into #temp3 
	from #temp3a t -- With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype and t.IdCountryCurrency = p.IdCountryCurrency--#4
	GROUP BY t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end, case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end --#5

	DROP TABLE #temp3a
    ------------------------------Tranfer Closed Rejected --------------------------------------------------

    select 
    t.IdAgent,    
    IdCountry, --case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,
    t.IdCountryCurrency, --case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency,
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
	IdAgentBankDeposit
    into #temp4a
	from  TransferClosed  t With (Nolock)    
    join agent a (nolock) on t.idagent=a.idagent
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	t.IdAgent in (Select IdAgent from #TempAgents) and
    IdStatus=31

	Select distinct 
	idAgent,
    case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,--IdCountry,
    case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency, --t.IdCountryCurrency,
	Count(1) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as NumTrans2Rej,
    SUM((AmountInDollars*ExRate)/ReferenceExRate) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as CogsRej2,
	Sum(AmountInDollars) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AmountTrans2Rej,
	Sum(Round(((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxResult2Rej,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionMonthly2Rej,
	SUM(case when IdAgentPaymentSchema=2 Then AgentCommission else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionRetain2Rej,
	SUM(Fee) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as IncomeFee2Rej,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider)  /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFee2Rej,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeM2Rej,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeR2Rej,
    sum(case when IdAgentBankDeposit in ( 43, 46, 42) then 0 else isnull(AmountInDollars*FactorNew,0) end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as BankCommission4,
    sum(isnull(CommissionNew,0)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as PayerCommission4
	into #temp4 
	from #temp4a  t --With (Nolock)
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype and t.IdCountryCurrency = p.IdCountryCurrency--#4
	GROUP BY t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end, case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end --#5

	DROP TABLE #temp4a

    ------------------------------Tranfer Cancel --------------------------------------------------

    select 
    t.idtransfer,
    t.IdAgent,
    IdCountry, --case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,
    t.IdCountryCurrency, --case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency,
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
	IdAgentBankDeposit
    into #temp5a
    from Transfer T   With (Nolock)
    join agent a (nolock) on t.idagent=a.idagent	
    join CountryCurrency cc (nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	left join TransferNotAllowedResend TN (nolock) on TN.IdTransfer =T.IdTransfer
	left join reasonforcancel rc (nolock) on t.idreasonforcancel=rc.idreasonforcancel
	where t.IdCountryCurrency=case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
    t.IdAgent in (Select IdAgent from #TempAgents) and
	IdStatus=22

	Select distinct 
	idAgent,
    case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,--IdCountry,
    case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency, --t.IdCountryCurrency,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as CogsCancel1,
	COUNT(1) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/  as NumCancel1,
	SUM(AmountInDollars-case when IdAgentPaymentSchema=1 then 0 else AgentCommissionExtra end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AmountCancel1,
	SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxResultCancel1,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/  as AgentcommissionMonthlyCan1,
	SUM(case when IdAgentPaymentSchema=2 Then 0 else 0 end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionRetainCan1,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeCan1,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeCanM1,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeCanR1,
	SUM(Fee) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as IncomeFeeCan1,
	SUM(case when TA.IdTransfer is null then 0 else Fee end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as IncomeFeeCancelLikeReject1,
	SUM(case when TA.IdTransfer is null then 0 else (case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionRetainCancelLikeReject1,
    sum(case when IdAgentBankDeposit in ( 43, 46, 42) then 0 else isnull(AmountInDollars*FactorNew,0) end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as BankCommission5,
    sum(isnull(CommissionNew,0)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as PayerCommission5
	into #temp5 
	from #temp5a T --  With (Nolock)
	left join dbo.TransferNotAllowedResend TA (nolock) on T.IdTransfer=TA.IdTransfer
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype and t.IdCountryCurrency = p.IdCountryCurrency--#4
	GROUP BY t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end, case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end --#5

	DROP TABLE #temp5a
    ------------------------------Tranfer Closed Cancel --------------------------------------------------

    select 
    t.idtransferclosed,
    t.IdAgent,
    IdCountry, --case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,
    t.IdCountryCurrency, --case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency,
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
	IdAgentBankDeposit
    into #temp6a
    from TransferClosed T   With (Nolock)
    join agent a (nolock) on t.idagent=a.idagent	
	left join TransferNotAllowedResend TN (nolock) on TN.IdTransfer =T.IdTransferClosed
	left join reasonforcancel rc (nolock) on t.idreasonforcancel=rc.idreasonforcancel
	where IdCountryCurrency=case when @IdCountryCurrency=0 Then IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
    t.IdAgent in (Select IdAgent from #TempAgents) and
	IdStatus=22

	Select distinct 
	T.idAgent,
    case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,--IdCountry,
    case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency, --t.IdCountryCurrency,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as CogsCancel2,
	COUNT(1) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/  as NumCancel2,
	SUM(AmountInDollars-case when IdAgentPaymentSchema=1 then 0 else AgentCommissionExtra end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AmountCancel2,
	SUM( Round( ((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate,2)) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxResultCancel2,
	SUM(case when IdAgentPaymentSchema=1 Then AgentCommission else 0 end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/  as AgentcommissionMonthlyCan2,
	SUM(case when IdAgentPaymentSchema=2 Then 0 else 0 end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionRetainCan2,
	SUM(ModifierCommissionSlider+ModifierExchangeRateSlider) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeCan2,
    SUM(case when IdAgentPaymentSchema=1 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeCanM2,
    SUM(case when IdAgentPaymentSchema=2 Then ModifierCommissionSlider+ModifierExchangeRateSlider else 0 end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as FxFeeCanR2,
	SUM(Fee) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as IncomeFeeCan2,
	SUM(case when TA.IdTransfer is null then 0 else Fee end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as IncomeFeeCancelLikeReject2,
	SUM(case when TA.IdTransfer is null then 0 else (case when Fee+AmountInDollars <>TotalAmountToCorporate Then AgentCommission else 0 end) end) /*over(Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as AgentcommissionRetainCancelLikeReject2,
    sum(case when IdAgentBankDeposit in ( 43, 46, 42) then 0 else isnull(AmountInDollars*FactorNew,0) end) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as BankCommission6,
    sum(isnull(CommissionNew,0)) /*over (Partition by t.IdAgent,t.idcountry,t.IdCountryCurrency)*/ as PayerCommission6
	into #temp6
	from #temp6a T --  With (Nolock)
	left join dbo.TransferNotAllowedResend TA (nolock) on T.IdTransferClosed=TA.IdTransfer
    left join #bankcommission b on b.DateOfBankCommission=DateOfCommission
    left join #payercommission p on p.DateOfpayerConfigCommission=DateOfCommission and p.idgateway=t.idgateway and p.idpayer=t.idpayer and p.idpaymenttype=t.idpaymenttype and t.IdCountryCurrency = p.IdCountryCurrency--#4
	GROUP BY t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end, case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end --#5
	DROP TABLE #temp6a
	
        ------------------------------Other Charges  --------------------------------------------------
    select  DISTINCT
        ab.IDAGENT ,Sum(case when ab.DebitOrCredit='Credit' then ab.Amount else ab.Amount*(-1) end) over(Partition by ab.IdAgent) OtherCharges1,
        --Sum(case when ab.DebitOrCredit='Credit' then ab.Amount else 0 end) over(Partition by ab.IdAgent) OtherChargesC1,
        --Sum(case when ab.DebitOrCredit!='Credit' then ab.Amount else 0 end) over(Partition by ab.IdAgent) OtherChargesD1
        Sum(case when oc.IdOtherChargesMemo in (6,9,13,19) then case when ab.DebitOrCredit='Credit' then ab.Amount else ab.Amount*(-1) end else 0 end) over(Partition by ab.IdAgent) OtherChargesC1,
        Sum(case when oc.IdOtherChargesMemo in (4,5,11,12,16,17,18,24,25) then case when ab.DebitOrCredit!='Credit' then ab.Amount else ab.Amount*(-1) end else 0 end) over(Partition by ab.IdAgent) OtherChargesD1
        into #temp7
    from 
        --agentbalance  ab With (Nolock, index(ix2_agentbalance))--#1
		agentbalance  ab With (Nolock)--#1
    join AgentOtherCharge oc (nolock) on ab.idagentbalance=oc.idagentbalance and oc.IdOtherChargesMemo in (6,9,13,19,4,5,11,12,16,17,18,24,25)
    where 
        ab.DateOfMovement>=@StartDate and
        ab.DateOfMovement<@EndDate and
        (ab.typeofmovement='CGO' OR ab.typeofmovement='DEBT')


    Select  distinct
	ac.idAgent,
	Sum(o.AmountToPay) 	over(Partition by ac.IdAgent) as OtherCharges2,
    Sum(case when o.AmountToPay>0 then o.AmountToPay else 0 end) over(Partition by ac.IdAgent) OtherChargesC2,
    Sum(case when o.AmountToPay<0 then o.AmountToPay*(-1) else 0 end) over(Partition by ac.IdAgent) OtherChargesD2
    into #temp10
	from 
        AgentCollectionDetail o  With (Nolock)    
    inner join 
	    AgentCollection AC (nolock) on AC.IdAgentCollection = o.IdAgentCollection 
	where @ReportCorpType=1 and
    o.DateofLastChange>=@StartDate and
    o.DateofLastChange<@EndDate

    ------------------------------Tranfer Unclaimed --------------------------------------------------
    
	Select distinct 
	idAgent,
    case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,
    case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end ,case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end) as UnclaimedCOGS1,
	COUNT(1) over(Partition by t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end,case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end) as UnclaimedNumTrans1,
	SUM(AmountInDollars) over(Partition by t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end,case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end) as UnclaimedAmount1
	into #temp8
	--from Transfer t  With (Nolock,INDEX(ix10_Transfer))
	from Transfer t  With (Nolock)
    join CountryCurrency cc (nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
	where t.IdCountryCurrency=case when @IdCountryCurrency=0 Then t.IdCountryCurrency Else @IdCountryCurrency End  and
    DateStatusChange>@StartDate and
    DateStatusChange<@EndDate and
	IdStatus=27 
    

	------------------------------Tranfer Closed Unclaimed --------------------------------------------------	
	
	Select distinct 
	idAgent,
    case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end IdCountry,
    case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end IdCountryCurrency,
	SUM((AmountInDollars*ExRate)/ReferenceExRate) over(Partition by t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end,case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end) as UnclaimedCOGSClosed,
	COUNT(1) over(Partition by t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end,case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end) as UnclaimedNumTransClosed,
	SUM(AmountInDollars) over(Partition by t.IdAgent,case when @type= 1 then 0 when @type=2 then IdCountry  when @type=3 then 0 end,case when @type= 1 then 0 when @type=2 then 0  when @type=3 then t.IdCountryCurrency end) as UnclaimedAmountClosed
	into #temp9
	--from TransferClosed  t With (Nolock,INDEX(ix10_TransferClosed))
	from TransferClosed  t With (Nolock)
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
    H.OtherChargesC1,
    H.OtherChargesD1,
    k.OtherCharges2,
    K.OtherChargesC2,
    K.OtherChargesD2,
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
    g.PayerCommission6,
    b.CogsTrans1,
    c.CogsTrans2,
    d.CogsRej1,
    e.CogsRej2
	into #Result
	from #temp A
	Left Join #temp1 B on (A.IdAgent=B.IdAgent) and (a.IdCountry=b.IdCountry) and a.IdCountryCurrency=b.IdCountryCurrency
	Left Join #temp2 C on (A.IdAgent=C.IdAgent) and (a.IdCountry=c.IdCountry) and a.IdCountryCurrency=c.IdCountryCurrency
	Left Join #temp3 D on (A.IdAgent=D.IdAgent) and (a.IdCountry=d.IdCountry) and a.IdCountryCurrency=d.IdCountryCurrency
	Left Join #temp4 E on (A.IdAgent=E.IdAgent) and (a.IdCountry=e.IdCountry) and a.IdCountryCurrency=e.IdCountryCurrency
	Left Join #temp5 F on (A.IdAgent=F.IdAgent) and (a.IdCountry=f.IdCountry) and a.IdCountryCurrency=f.IdCountryCurrency
	Left Join #temp6 G on (A.IdAgent=G.IdAgent) and (a.IdCountry=g.IdCountry) and a.IdCountryCurrency=g.IdCountryCurrency
	Left Join #temp7 H on (A.IdAgent=H.IdAgent)--other charges
	Left Join #temp8 I on (A.IdAgent=I.IdAgent) and (a.IdCountry=i.IdCountry) and a.IdCountryCurrency=i.IdCountryCurrency
	Left Join #temp9 J on (A.IdAgent=J.IdAgent) and (a.IdCountry=j.IdCountry) and a.IdCountryCurrency=j.IdCountryCurrency
    Left Join #temp10 k on (A.IdAgent=k.IdAgent)--other charges	
		
		
	DROP TABLE #temp1
	DROP TABLE #temp2
	DROP TABLE #temp3
	DROP TABLE #temp4
	DROP TABLE #temp5
	DROP TABLE #temp6
	DROP TABLE #temp7
	DROP TABLE #temp8	
	DROP TABLE #temp9	
	DROP TABLE #temp10
	
	
	Update #Result set
    NumTrans=IsNull(NumTrans1,0)+IsNull(NumTrans2,0),
	NumCancel=IsNull(NumCancel1,0)+IsNull(NumCancel2,0)+IsNull(NumTransRej1,0)+IsNull(NumTrans2Rej,0),
	AmountTrans=IsNull(AmountTrans1,0)+IsNull(AmountTrans2,0),
    AmountCancel=IsNull(AmountCancel1,0)+IsNull(AmountCancel2,0)+IsNull(AmountTransRej1,0)+IsNull(AmountTrans2Rej,0),	
    
    OtherCharges=IsNull(OtherCharges1,0)+IsNull(OtherCharges2,0),
    OtherChargesD=IsNull(OtherChargesD1,0)+IsNull(OtherChargesD2,0),
    OtherChargesC=IsNull(OtherChargesC1,0)+IsNull(OtherChargesC2,0),	
    
    CogsCancel=IsNull(CogsCancel1,0)+IsNull(CogsCancel2,0)+IsNull(CogsRej1,0)+IsNull(CogsRej2,0),	
	
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
	

    if @Type=1
    begin
        Update #Result set AgentcommissionMonthly=AgentcommissionMonthly-FxFeeM where AgentcommissionMonthly >0
	    Update #Result set AgentcommissionRetain=AgentcommissionRetain-FxFeeR where AgentcommissionRetain >0
    end
    else
    begin
        Update #Result set AgentcommissionMonthly=AgentcommissionMonthly-FxFeeM 
	    Update #Result set AgentcommissionRetain=AgentcommissionRetain-FxFeeR 
    end
	
    Update #Result set NumNet=NumTrans-NumCancel,
                       AmountNet=AmountTrans-AmountCancel,
                       Result=FxResult+IncomeFee-AgentcommissionMonthly-AgentcommissionRetain-FxFee-PayerCommission+UnclaimedAmount-UnclaimedCOGS---BankCommission
	Update #Result set CogsNet=AmountNet-FxResult                       
	Update #Result set OtherCharges=0 where OtherCharges is null
    Update #Result set OtherChargesD=0 where OtherChargesD is null
    Update #Result set OtherChargesC=0 where OtherChargesC is null
	Update #Result set NetResult = Result+OtherCharges,
                       CogsTrans = CogsCancel+CogsNet


---------------------------------------------- Calculo de Other Products
CREATE TABLE #tOtherProd (
[idAgent]  int,
[AgentName]  varchar(100),	
[AgentCode]  varchar(50),	
[Total]  int,	
[CancelsTotal]  int,		
[TotalNet] int,		
[Amount] money,	
[CGS] money,	
[Fee] money,	
[FeeM] money,	
[FeeR] money,	
[ProviderComm] money,
[CorpCommission] money,
[AgentCommMonthly] money,	
[AgentCommRetain] money,	
[FX] money,

[CheckFees] money, /*2015-Ago-15*/

[ReturnedFee] money, 
[TransactionFee] money, /*2015-Sep-21*/
[CustomerFee] money, /*2015-Sep-21*/
[ProccessingFee] money, /*2020-Jul*/
[ScannerFee] money	/*2015-Sep-21*/
)

DECLARE @EndDateOP DATETIME = @EndDate-1
 INSERT  INTO #tOtherProd
  EXEC [Corp].[st_GetOtherProductProfitV2] @StartDate, @EndDateOP, null, null, @State
---------------------------------------------- Calculo de Other Products

---------------------------------------------- Calculo DepositAgent
   
  SELECT IdAgent, SUM (DepositAgent) DepositAgent
    INTO #tDepositAgent
    FROM (
   SELECT ab.IdAgent,  
    ISNULL ( ( 
						SUM( CASE WHEN DebitOrCredit='Credit' THEN Amount ELSE 0 END )
					-
						SUM( CASE WHEN DebitOrCredit='Debit' THEN Amount ELSE 0 END ) 
				) * FactorNew, 0 ) DepositAgent
	 --INTO #tDepositAgent
     FROM #TempAgents
	INNER JOIN AgentBalance ab (nolock) ON ab.IdAgent = #TempAgents.IdAgent
	INNER JOIN Agent ag (nolock) ON  ab.IdAgent = ag.IdAgent and ag.IdAgentBankDeposit not in (42, 43, 46)
	 LEFT JOIN #bankcommission bc ON bc.DateOfBankCommission =[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfMovement)-1),DateOfMovement)) 
    WHERE ab.TypeofMovement='DEP' and DateOfMovement >= @StartDate
      AND DateOfMovement < @EndDate
    GROUP BY ab.IdAgent, bc.FactorNew
	) cteD	
 GROUP BY IdAgent
---------------------------------------------- Calculo DepositAgent


------------------------------Output --------------------------------------------------
select t.IdAgent, AgentCode, AgentName,
	   NumTrans,NumCancel,      --No mostrar
	   NumNet,
	   AmountTrans, AmountCancel, AmountNet, CogsTrans,CogsCancel,CogsNet, --No mostrar
	   FxResult, IncomeFee,
	   AgentcommissionMonthly,AgentcommissionRetain,FxFeeM,FxFeeR,isnull(SpecialCommission,0) SpecialCommission, --No mostrar
	   ----
	   PayerCommission,  --Cambio en el calculo
	   ----
	   UnclaimedAmount,UnclaimedCOGS,OtherCharges,OtherChargesC,OtherChargesD, --No mostrar
	   Result, 
	   ----
	   NetResult-isnull(SpecialCommission,0) NetResult,	   --Cambio en el calculo --Profit
	   case when NumNet!=0 then (netresult-isnull(SpecialCommission,0))/NumNet else 0 end Margin, --Cambio en el calculo
	   ----
	   isnull(UserName,'') Parent,SalesRep, --No mostrar
        case
        when @type= 2 then
		    case when isnull(c.CountryCode,'')='HTI' then 'HAI'
			     when isnull(c.CountryCode,'')='PRY' then 'PAR'
		    else isnull(c.CountryCode,'') 
            end 
        when @type= 3 then
            case when isnull(t.IdCountryCurrency,0)!=0    then
                case when isnull(c2.CountryCode,'')='HTI' then 'HAI' + '/'  + isnull(cu.CurrencyCode,'')
			        when isnull(c2.CountryCode,'')='PRY' then 'PAR' + '/'  + isnull(cu.CurrencyCode,'')
		        else isnull(c2.CountryCode,'') + '/'  + isnull(cu.CurrencyCode,'') end 
            else ''            
            end
        else ''
        end
        CountryCode
--------------------
     , c.CountryName
	   ,  (AgentcommissionMonthly + AgentcommissionRetain + FxFeeM + FxFeeR+isnull(SpecialCommission,0)) + OtherChargesC - OtherChargesD CommSeller,
	     DepositAgent BkFeesSeller,
		 [OtherProducts] OtherProductsSeller,
		(FxResult + IncomeFee) - ((AgentcommissionMonthly + AgentcommissionRetain + FxFeeM + FxFeeR+isnull(SpecialCommission,0)) + OtherChargesC - OtherChargesD ) - PayerCommission - DepositAgent + [OtherProducts]  ProfitSeller, ---W2+X2
		CASE WHEN isnull(NumNet,0) > 0 THEN 
				((FxResult + IncomeFee) - ((AgentcommissionMonthly + AgentcommissionRetain + FxFeeM + FxFeeR+isnull(SpecialCommission,0)) + OtherChargesC - OtherChargesD ) - PayerCommission - DepositAgent + [OtherProducts]  ) / NumNet
			ELSE 0	END
				MarginSeller
--------------------
from(
	Select 
	#Result.IdAgent,
    IdCountry,
    IdCountryCurrency,
    #Result.AgentCode,
    #Result.AgentName,	
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
    FxFeeM,    
    FxFeeR,    
    case when PayerCommission>0 then PayerCommission else 0 end PayerCommission,    
	UnclaimedAmount,
	UnclaimedCOGS,    
    OtherCharges,	
    OtherChargesC,
    OtherChargesD,
	Result,	
			FxResult + IncomeFee-AgentcommissionMonthly-AgentcommissionRetain-FxFeeM-FxFeeR - case 
																		when PayerCommission>0 then PayerCommission 
																		else 0 end - UnclaimedAmount + UnclaimedCOGS - OtherChargesC + OtherChargesD NetResult,

    (select IdUserSellerParent from Seller (nolock) where IdUserSeller=IdSalesRep) IdUserSellerParent,
    SalesRep
	--
	, BankCommission 
	, isnull(#tOtherProd.[CorpCommission],0.0) [OtherProducts]
	, isnull(#tDepositAgent.[DepositAgent],0.0) [DepositAgent]
	--
	from #Result
----------------------------------------------------
    LEFT JOIN #tOtherProd ON #Result.IdAgent = #tOtherProd.idAgent    
	LEFT JOIN #tDepositAgent ON  #Result.IdAgent = #tDepositAgent.idAgent    
----------------------------------------------------
) t
left join users u (nolock) on u.iduser=isnull(IdUserSellerParent,0)
left join #tempSC s on s.IdAgent=t.IdAgent
left join country c (nolock) on t.IdCountry=c.IdCountry
left join CountryCurrency cc (nolock) on t.IdCountryCurrency=cc.IdCountryCurrency
left join country c2 (nolock) on c2.IdCountry=cc.IdCountry
left join Currency cu (nolock) on cu.IdCurrency=cc.IdCurrency
Order by AgentCode,
       case when @type= 2 then
		    case when isnull(c.CountryCode,'')='HTI' then 'HAI'
			     when isnull(c.CountryCode,'')='PRY' then 'PAR'
		    else isnull(c.CountryCode,'') 
            end 
            when @type= 3 then
            case when isnull(t.IdCountryCurrency,0)!=0    then
                case when isnull(c2.CountryCode,'')='HTI' then 'HAI' + '/'  + isnull(cu.CurrencyCode,'')
			        when isnull(c2.CountryCode,'')='PRY' then 'PAR' + '/'  + isnull(cu.CurrencyCode,'')
		        else isnull(c2.CountryCode,'') + '/'  + isnull(cu.CurrencyCode,'') end 
            else ''            
            end
        else ''
        end
