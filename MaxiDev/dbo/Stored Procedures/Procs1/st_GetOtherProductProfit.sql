CREATE procedure [dbo].[st_GetOtherProductProfit]
@From datetime,
@hasta datetime, 
@IDProduct int, 
@State varchar(10)
as
/* 2012-02-15 HMG  CAmbio con nueva logica*/
set @hasta = dateadd(day,1,@hasta)


SET @State =RTRIM(LTRIM(@State)) 
IF (@State='')
	SET @State = null 


 
--select t0.idAgent, AgentName, AgentCode, sum(case when t1.TypeOfMovement = 'BP' then 1 else 0 end) as NoBills, 
--sum(case when t1.TypeOfMovement = 'BP' then t2.ReceiptAmount+t2.fee else (t2.ReceiptAmount+t2.fee)*-1 end)  as Amount,
-- sum(case when t1.TypeOfMovement = 'BP' then t2.ReceiptAmount else t2.ReceiptAmount*-1 end ) as CGS, 
-- sum(case when t1.TypeOfMovement = 'BP' then t2.Fee else t2.Fee*-1 end) as Fee,
--  sum(case when t1.TypeOfMovement = 'BP' then t2.BillPaymentProviderFee else t2.BillPaymentProviderFee *-1 end) as SoftgateComm,
--  sum(case when t1.TypeOfMovement = 'BP' then t2.CorpCommission else  t2.CorpCommission *-1 end) as NEtResult,
--sum (case when t1.IsMonthly = 1  then t1.Commission else 0 end  ) as AgentCommMonthly,
--sum (case when t1.IsMonthly = 0 then t1.Commission else 0 end  ) as AgentCommRetain
--from Agent t0
--join dbo.AgentBalance t1 on t0.idAgent = t1.idAgent and  t1.typeofMovement in  ('BP','CBP')
--join BillPAymentTransactions t2 on t1.Reference = t2.idBillpayment 
--where (t1.DateOfMovement >= @from and t1.DateOfMovement < @hasta) 
-----and (t2.Status = 1 or (t2.Status = 2 and t2.CancelDate >= '20120201'))
--group by t0.idAgent, AgentName, AgentCode

select t0.idAgent, AgentName, AgentCode, 
sum (case when t3.allowcount = 1 then 1 else 0 end) as Total,
sum (case when t3.allowcount = 0 then 1 else 0 end) as CancelsTotal,
sum (case when t3.allowcount = 1 then 1 else -1 end) as TotalNet,
sum(case 
		when t1.IsMonthly = 0 and t3.idOtherProduct=7 then t2.TotalAmount+t1.Commission
		when t3.idOtherProduct=14 then t2.TotalAmount-t2.Fee --Regalli
		else  t2.TotalAmount 
	end
	) as Amount,
sum(case 
		when t1.IsMonthly = 0 and t3.idOtherProduct=7 then t2.CGS+t1.Commission 
		else t2.CGS 
	end
	) as CGS,

sum (t2.Fee) as Fee,
/*Dos nuevas Columnas agregadas Jose*/
sum (case when t1.IsMonthly = 1  then t2.Fee else 0 end )  as FeeM,
sum (case when t1.IsMonthly = 0  then t2.Fee else 0 end )  as FeeR,
/***********************************/

sum (t2.ProviderFee) as ProviderComm, 
sum (case
		when t3.idOtherProduct=14 then (t2.TotalAmount-t2.fee-t2.CGS)+t2.Fee-t1.Commission-t2.ProviderFee
		else t2.CorpCommission
	end
	) as CorpCommission,
--sum (case when t3.IdOtherProduct=1 then t2.Fee-t1.Commission-t2.ProviderFee else t2.CorpCommission end) as CorpCommission2,
sum (case when t1.IsMonthly = 1  then t1.Commission else 0 end  ) as AgentCommMonthly,
sum (case when t1.IsMonthly = 0 then t1.Commission else 0 end  ) as AgentCommRetain,
sum (case
		when t3.idOtherProduct=14 then t2.TotalAmount-t2.fee-t2.CGS
		else 0
	end
	) FX
from Agent t0
join  AgentBalance t1 on t0.idAgent = t1.idAgent
join AgentBalanceDetail t2 on t1.IdAgentBalance = t2.IdAgentBalance
join profitHelper t3 on (t1.typeofMovement = t3.typeofmovement) and ((@IDProduct=0) or (t3.idOtherProduct = @IDProduct))
where (t1.DateOfMovement >= @from and t1.DateOfMovement < @hasta)  AND (@State is null or t0.AgentState=@State) AND T3.idOtherProduct!=15
group by t0.idAgent, AgentName, AgentCode