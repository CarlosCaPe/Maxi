CREATE procedure [Balance].[st_GetAgentBalanceOtherProductsNew]
(
    @IdAgent int,
    @DateFrom datetime,
    @DateTo datetime

)
as
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
	,@CHRTNQuantity=SUM(CASE WHEN TypeOfMovement = 'CHRTN' THEN 1 ELSE 0 END )
from AgentBalance WITH(NOLOCK) 
	where DateOfMovement>=@DateFrom 
		and DateOfMovement<@DateTo 
   		and TypeOfMovement IN ('CHRTN','CHNFS') --se agrega a peticion de mmendoza 
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
			IsNull(Sum(case when AllowCount=1 then Amount else  
		   Amount*-1 
		   	end),0)
		   	+case when ph.idOtherProduct=15 then isnull(@CHNFS,0) else 0 end  
			Amount,
            IsNull(Sum(ab.Commission),0) Commission,
			IsNull(Sum(case when AllowCount=1 then 1 else -1 end),0) Quantity,
			PH.IdOtherProduct
		from AgentBalance AB WITH(NOLOCK)
			inner join ProfitHelper PH WITH(NOLOCK) on AB.TypeOfMovement = PH.TypeOfMovement
			where AB.idAgent = @idAgent
				and AB.DAteOfMovement >=  @DateFrom
				and AB.DAteOfMovement < @DateTo
			   --	and AB.Reference NOT IN (select Reference from AgentBalance WITH(NOLOCK) where DateOfMovement>=@DateFrom and DateOfMovement<@DateTo and TypeOfMovement ='CHRTN' and idagent=@IdAgent) /*Paso 2: S12 - REQ._MC.02_Rediseño_de_Agent_Balance_Report*/
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
    ShowInHeader INT 
);

DECLARE @AgentBalanceService TABLE
(
	IdAgentBalanceService INT NOT NULL,
	Description           NVARCHAR (2000) NULL,
	IdGenericStatus       INT NULL
);

INSERT INTO  @AgentBalanceService
SELECT * FROM AgentBalanceService
UNION SELECT 8, ' Returned Checks',1
UNION SELECT 9, 'Check Pending Release',1


DECLARE @RelationAgentBalanceServiceOtherProduct TABLE
(
	IdAgentBalanceService INT NOT NULL,
	IdOtherProduct        INT NULL
);

INSERT INTO @RelationAgentBalanceServiceOtherProduct
SELECT * FROM RelationAgentBalanceServiceOtherProduct	
UNION SELECT 8 ,15	
UNION SELECT 9 ,15
	
	

INSERT INTO @AgentBalanceOP
select 
	isnull(r.IdAgentBalanceService,0) IdAgentBalanceService
	, isnull(s.Description,'Others') Description
	,sum(Amount) Amount
	, sum(Commission) Commission
	,Sum(Quantity) Quantity
	, case when isnull(r.IdAgentBalanceService,0)=7 then 0 else 1 end ShowInHeader
from #AgentBalanceOP b
	left join @RelationAgentBalanceServiceOtherProduct r
		on b.IdOtherProduct=r.IdOtherProduct
	left join @AgentBalanceService s 
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
	ShowInHeader = 3
WHERE 
	IdAgentBalanceService = @CHRTNIdAgentBalanceService;

/*AgentBalanceService -> (9) Check Pending Release*/
UPDATE @AgentBalanceOP
SET 
	Amount = isnull(@CHPending,0),
	Commission = isnull(@CHPendingCommission,0),
	Quantity = isnull(@CHPendingQuantity,0),
	ShowInHeader = 4
WHERE 
	IdAgentBalanceService = @CHPendingIdAgentBalanceService;

/*7	 Checks*/

UPDATE @AgentBalanceOP
SET 
	Amount = (Amount+ isnull(@CHRTN,0)),
	Commission = (Commission+isnull(@CHRTNCommission,0)),
	Quantity = (Quantity+isnull(@CHRTNQuantity,0)),
	ShowInHeader = 2
WHERE 
	IdAgentBalanceService = 7;


select 
	IdAgentBalanceService
	,[Description]
	,Amount
	,Commission
	,Quantity
	,ShowInHeader
from @AgentBalanceOP;
