CREATE procedure st_GetDataMoneyRemittance
(
    @BeginDate datetime,
    @EndDate datetime
)
as

select  idcountry,sum(amountindollars) amount,sum(trans) trans  from (
select 
    cc.idcountry,amountindollars, 1 trans
from 
    transfer t
join countrycurrency cc on t.idcountrycurrency=cc.idcountrycurrency
where dateoftransfer>=@BeginDate and dateoftransfer<@EndDate
union all
select 
    cc.idcountry,amountindollars, 1 trans
from 
    transferclosed t
join countrycurrency cc on t.idcountrycurrency=cc.idcountrycurrency
where dateoftransfer>=@BeginDate and dateoftransfer<@EndDate

union all

select 
    cc.idcountry,amountindollars*-1 amountindollars, 1*-1 trans
from 
    transfer t
join countrycurrency cc on t.idcountrycurrency=cc.idcountrycurrency
where t.DateStatusChange>=@BeginDate and t.DateStatusChange<@EndDate and idstatus in (31)
union all
select 
    cc.idcountry,amountindollars*-1 amountindollars, 1*-1 trans
from 
    transferclosed t
join countrycurrency cc on t.idcountrycurrency=cc.idcountrycurrency
where t.DateStatusChange>=@BeginDate and t.DateStatusChange<@EndDate and idstatus in (31)

union all


select 
    cc.idcountry,(AmountInDollars-case when IdAgentPaymentSchema=1 then 0 else CASE 
                WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  0  
                --ELSE T.AmountInDollars
                when TN.IdTransfer is not null then 0
                else            
                case (rc.returnallcomission) 
                        when 1 then  0
                        else AgentCommissionExtra       
                    end
            END end)*-1 amountindollars, 1*-1 trans
from 
    transfer t
join countrycurrency cc on t.idcountrycurrency=cc.idcountrycurrency
left join TransferNotAllowedResend TN on TN.IdTransfer =T.IdTransfer
	left join reasonforcancel rc on t.idreasonforcancel=rc.idreasonforcancel
where t.DateStatusChange>=@BeginDate and t.DateStatusChange<@EndDate and idstatus in (22)
union all
select 
    cc.idcountry,(AmountInDollars-case when IdAgentPaymentSchema=1 then 0 else CASE 
                WHEN DATEDIFF(minute, t.DateOfTransfer, t.DateStatusChange)<=30 then  0  
                --ELSE T.AmountInDollars
                when TN.IdTransfer is not null then 0
                else            
                case (rc.returnallcomission) 
                        when 1 then  0
                        else AgentCommissionExtra       
                    end
            END end)*-1 amountindollars, 1*-1 trans
from 
    transferclosed t
join countrycurrency cc on t.idcountrycurrency=cc.idcountrycurrency
left join TransferNotAllowedResend TN on TN.IdTransfer =T.IdTransferClosed
	left join reasonforcancel rc on t.idreasonforcancel=rc.idreasonforcancel
where t.DateStatusChange>=@BeginDate and t.DateStatusChange<@EndDate and idstatus in (22)


) t
group by idcountry