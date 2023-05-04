
CREATE procedure [Balance].[st_GetAgentBalanceOtherProducts]
(
    @IdAgent int,
    @DateFrom datetime,
    @DateTo datetime

)
as
/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Gets Agent Commission of AgentBalance Report(OtherProduct DataSet)</Description>

<ChangeLog>
<log Date="18/10/2017" Author="snevarez">Fix 0000836: Reporte por concepto(ShowInHeader convert to int)</log>
<log Date="12/03/2018" Author="jmmolina">DROP TABLE #AgentBalanceOP</log>
</ChangeLog>
*********************************************************************/
begin try
Set nocount on 
declare @CHNFS money = 0
set @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
set @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)  

create table #AgentBalanceOP
(
    Amount Money,
    Commission money,
    Quantity int,
    IdOtherProduct int,
    Description nvarchar(max)
)

select @CHNFS=sum(Amount*(-1)) from agentbalance WITH(NOLOCK) where DateOfMovement>=@DateFrom and DateOfMovement<=@DateTo and TypeOfMovement='CHNFS' and idagent=@IdAgent
--select @CHNFS=sum(Amount) from agentbalance WITH(NOLOCK) where DateOfMovement>=@DateFrom and DateOfMovement<=@DateTo and TypeOfMovement='CHNFS' and idagent=@IdAgent

/*Paso 1: S12 - REQ._MC.02_Rediseño_de_Agent_Balance_Report*/
/*AgentBalanceService -> (8) Returned Checks >> CH,CHRTN */
declare @CHRTNIdOtherProduct int = 15;
declare @CHRTNIdAgentBalanceService int = 8;
declare @CHRTNDescription nvarchar(max) = 'Returned Checks';

declare @CHRTN money = 0;
declare @CHRTNCommission money = 0;
declare @CHRTNQuantity int = 0;
select 
	@CHRTN = SUM(ISNull(Amount,0))
	,@CHRTNCommission =  SUM(ISNull(Commission,0))
	,@CHRTNQuantity=count(1)
from AgentBalance WITH(NOLOCK) 
	where DateOfMovement>=@DateFrom 
		and DateOfMovement<@DateTo 
		and TypeOfMovement ='CHRTN' 
		and idagent=@IdAgent;
/*-------------------------------------------*/

/*AgentBalanceService -> (9) Check Pending Release*/
declare @CHPendingIdAgentBalanceService int = 9;
declare @CHPendingDescription nvarchar(max) = 'Check Pending Release';

declare @CHPending money = 0;
declare @CHPendingCommission money = 0;
declare @CHPendingQuantity int = 0;
select 			
	@CHPending = SUM(ISNull(Amount,0))
	,@CHPendingCommission = SUM(ISNull(Comission, 0))
	,@CHPendingQuantity=count(1)
from Checks WITH(NOLOCK)
where IdStatus = 41
	and IdAgent=@IdAgent
	and [DateStatusChange]>=@DateFrom
	and [DateStatusChange]<@DateTo;
/*-------------------------------------------*/

insert into #AgentBalanceOP
select
	L.Amount,
    L.Commission,
	L.Quantity,
	L.IdOtherProduct,
	OP.Description
from 
	(
		select 
			IsNull(Sum(case when AllowCount=1 then Amount else Amount*-1 end),0)+case when ph.idOtherProduct=15 then isnull(@CHNFS,0) else 0 end  Amount,
            IsNull(Sum(ab.Commission),0) Commission,
			IsNull(Sum(case when AllowCount=1 then 1 else -1 end),0) Quantity,
			PH.IdOtherProduct
		from AgentBalance AB WITH(NOLOCK)
			inner join ProfitHelper PH WITH(NOLOCK) on AB.TypeOfMovement = PH.TypeOfMovement and PH.idOtherProduct!=19
			where AB.idAgent = @idAgent
				and AB.DAteOfMovement >=  @DateFrom
				and AB.DAteOfMovement < @DateTo
				--and AB.Reference NOT IN (select Reference from AgentBalance WITH(NOLOCK) where DateOfMovement>=@DateFrom and DateOfMovement<@DateTo and TypeOfMovement ='CHRTN' and idagent=@IdAgent) /*Paso 2: S12 - REQ._MC.02_Rediseño_de_Agent_Balance_Report*/
		group by PH.IdOtherProduct
	)L 
	inner join dbo.OtherProducts OP on OP.IdOtherProducts= L.IdOtherProduct


/*Paso 3: S12 - REQ._MC.02_Rediseño_de_Agent_Balance_Report*/
DECLARE @AgentBalanceOP TABLE
(
	IdAgentBalanceService int,
	[Description] nvarchar(max),
    Amount Money,
    Commission money,
    Quantity int,
    ShowInHeader INT /*Fix 0000836*/
);

INSERT INTO @AgentBalanceOP
select 
	isnull(r.IdAgentBalanceService,0) IdAgentBalanceService
	, isnull(s.Description,'Others') Description
	,sum(Amount) Amount
	, sum(Commission) Commission
	,Sum(Quantity) Quantity
	, case when isnull(r.IdAgentBalanceService,0)=7 then 0 else 1 end ShowInHeader
from #AgentBalanceOP b
	left join [RelationAgentBalanceServiceOtherProduct] r WITH(NOLOCK)
		on b.IdOtherProduct=r.IdOtherProduct
	left join [AgentBalanceService] s  WITH(NOLOCK)
		on r.IdAgentBalanceService=s.IdAgentBalanceService
group by isnull(r.IdAgentBalanceService,0),isnull(s.Description,'Others')
order by isnull(s.Description,'Others');

/*Paso 4: S12 - REQ._MC.02_Rediseño_de_Agent_Balance_Report*/
/*AgentBalanceService -> (8) Returned Checks*/
UPDATE @AgentBalanceOP
SET 
	Amount = isnull(@CHRTN,0),
	Commission = isnull(@CHRTNCommission,0),
	Quantity = isnull(@CHRTNQuantity,0),
	ShowInHeader = 0
WHERE 
	IdAgentBalanceService = @CHRTNIdAgentBalanceService;

/*AgentBalanceService -> (9) Check Pending Release*/
UPDATE @AgentBalanceOP
SET 
	Amount = isnull(@CHPending,0),
	Commission = isnull(@CHPendingCommission,0),
	Quantity = isnull(@CHPendingQuantity,0),
	ShowInHeader = 0
WHERE 
	IdAgentBalanceService = @CHPendingIdAgentBalanceService;


select 
	IdAgentBalanceService
	,[Description]
	,Amount
	,Commission
	,Quantity

	,ShowInHeader
	--,CONVERT(INT, ShowInHeader) AS ShowInHeader /*Fix 0000836*/

from @AgentBalanceOP;

DROP TABLE #AgentBalanceOP

End Try
begin catch
    Declare @ErrorMessage nvarchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Balance.st_GetAgentBalanceOtherProducts',Getdate(),@ErrorMessage);
End Catch