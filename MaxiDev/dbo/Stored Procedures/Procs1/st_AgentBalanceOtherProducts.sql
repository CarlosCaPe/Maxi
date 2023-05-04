/********************************************************************
<Author> UNKNOW </Author>
<app> SQL Reports, Corporative, Agent </app>
<Description></Description>

<ChangeLog>
<log Date="05/02/2019" Author="azavala">se agrega para profitHelper el que no tome en cuenta el product 19(FiServ) ya que comparte TypeOfMovement con FidelityExpress - REF: 05022019_azavala</log>
</ChangeLog>
*********************************************************************/
create procedure [dbo].[st_AgentBalanceOtherProducts]              
(              
@IdAgent int,              
@DateFrom datetime,               
@DateTo datetime              
)              
as             
Set nocount on 

set @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
set @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)  

create table #AgentBalanceOtherProducts
(
    Amount Money,
    Commission money,
    Quantity int,
    IdOtherProduct int,
    Description nvarchar(max)
)

declare @CHNFS money = 0
select @CHNFS=sum(Amount*(-1)) from agentbalance where DateOfMovement>=@DateFrom and DateOfMovement<=@DateTo and TypeOfMovement='CHNFS' and idagent=@IdAgent

insert into #AgentBalanceOtherProducts
select
	L.Amount,
	L.Commission,
	L.Quantity,
	L.IdOtherProduct,
	OP.[Description]
from 
	(
		select 
			IsNull(Sum(case when AllowCount=1 then Amount else Amount*-1 end),0)+case when ph.idOtherProduct=15 then isnull(@CHNFS,0) else 0 end Amount,
			IsNull(Sum(case when AllowCount=1 then 1 else -1 end),0) Quantity,
			IsNull(Sum(ab.Commission),0) Commission,
			PH.IdOtherProduct
		from AgentBalance AB  with (nolock)
			inner join ProfitHelper PH on AB.TypeOfMovement = PH.TypeOfMovement and PH.idOtherProduct!=19 -- 05022019_azavala
			where AB.idAgent = @idAgent
				and AB.DAteOfMovement >=  @DateFrom
				and AB.DAteOfMovement < @DateTo
		group by PH.IdOtherProduct
	)L 
	inner join dbo.OtherProducts OP on OP.IdOtherProducts= L.IdOtherProduct

select isnull(r.IdAgentBalanceService,0) IdAgentBalanceService, isnull(s.Description,'Others') Description,sum(Amount) Amount, sum(Commission) Commission,Sum(Quantity) Quantity, case when isnull(r.IdAgentBalanceService,0)=7 then 0 else 1 end ShowInHeader
from #AgentBalanceOtherProducts b
left join [RelationAgentBalanceServiceOtherProduct] r
left join [AgentBalanceService] s on r.IdAgentBalanceService=s.IdAgentBalanceService
on b.IdOtherProduct=r.IdOtherProduct
group by isnull(r.IdAgentBalanceService,0),isnull(s.Description,'Others')
order by isnull(s.Description,'Others')
