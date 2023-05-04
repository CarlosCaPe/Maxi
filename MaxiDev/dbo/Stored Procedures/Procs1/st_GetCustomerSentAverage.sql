
CREATE procedure [dbo].[st_GetCustomerSentAverage]
(
    @DateFrom datetime = null,
    @DateTo datetime = null
)
as
/*declaracion de variables*/
declare @idcustomer int = 0
declare @average decimal(18,2) = 0
/*Verificar si vienen en nulo los parametros*/
declare @qDateFrom datetime = isnull(@DateFrom,DATEADD(YY, -1, getdate()))
declare @qDateTo datetime = isnull(@DateTo,getdate())
/*Quitar horas a la fecha*/
set @qDateFrom = CONVERT(datetime, DATEDIFF(d, 0, @qDateFrom))
set @qDateTo = CONVERT(datetime, DATEDIFF(d, 0, @qDateTo))

Create table #temp
(
 /*id int identity(1,1),*/
 idcustomer int,
 Average decimal(18,2)
) 
 
Insert into #temp (idcustomer,average)
select c.idcustomer idcustomer, isnull(a.Average,0) Average
from
    customer c with (nolock)
left join
(
select idcustomer,sum(totalA)/sum(totalT) Average
from
(
    select
        idcustomer,
        sum(1) totalT,
        --sum(amountindollars) totalA
		sum(amountindollars + isnull(Fee,0)) totalA /*S50*/
    from transfer t with (nolock)
    where 
        dateoftransfer>=@qDateFrom and dateoftransfer<=@qDateTo        
    group by 
        idcustomer
union all
    select
        idcustomer,
        sum(1) totalT,
        --sum(amountindollars) totalA 
		sum(amountindollars + isnull(Fee,0)) totalA /*S50*/
    from transferclosed with (nolock)
    where 
        dateoftransfer>=@qDateFrom and dateoftransfer<=@qDateTo        
    group by idcustomer
) tprom
group by idcustomer
) a on c.idcustomer=a.idcustomer
 
update 
    customer 
set 
    SentAverage=tca.Average
from 
    #temp tca 
where 
    customer.idcustomer=tca.idcustomer

Drop table #temp