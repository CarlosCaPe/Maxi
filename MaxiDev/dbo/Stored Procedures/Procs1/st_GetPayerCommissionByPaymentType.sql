CREATE procedure st_GetPayerCommissionByPaymentType
(
    @PaymentType int =  null,
    @BaseDate datetime
)
as

--Declaracion de variables
declare @MounthPast1   datetime
declare @MounthPast2   datetime
declare @MounthActual  datetime
declare @MounthNext    datetime
declare @IdUser        int

--Fecha Base
set @BaseDate=[dbo].[RemoveTimeFromDatetime](@BaseDate)

SELECT @MounthActual = DATEADD(dd,-(DAY(@BaseDate)-1),@BaseDate)

select @MounthNext  = DATEADD(mm,1,@MounthActual),
       @MounthPast1 = DATEADD(mm,-1,@MounthActual),
       @MounthPast2 = DATEADD(mm,-2,@MounthActual)

select @IdUser = convert(int, [dbo].[GetGlobalAttributeByName]('SystemUserID'))

declare @Id int
declare @IdPayerAux int
declare @IdPaymentTypeAux int

create table #paymenttype
(
    Id int identity (1,1),
    idpayer int,
    idpaymenttype int
)

insert into #paymenttype
select distinct idpayer,idpaymenttype  from payerconfig where idpaymenttype=isnull(@PaymentType,idpaymenttype) and idgenericstatus=1

--select * from #paymenttype

while exists (select top 1 1 from #paymenttype)
Begin
    select top 1 @Id=id,@IdPayerAux=idpayer,@IdPaymentTypeAux=idpaymenttype from #paymenttype

    if not exists (select top 1 1 from PayerCommission where idpaymenttype=@IdPaymentTypeAux and idpayer=@IdPayerAux and [DateOfPayerCommission]=@MounthPast2)
    begin
        exec st_SavePayerCommission @IdPayerAux,@IdPaymentTypeAux,@MounthPast2,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=@IdPaymentTypeAux and idpayer=@IdPayerAux and [DateOfPayerCommission]=@MounthPast1)
    begin
        exec st_SavePayerCommission @IdPayerAux,@IdPaymentTypeAux,@MounthPast1,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=@IdPaymentTypeAux and idpayer=@IdPayerAux and [DateOfPayerCommission]=@MounthActual)
    begin
        exec st_SavePayerCommission @IdPayerAux,@IdPaymentTypeAux,@MounthActual,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=@IdPaymentTypeAux and idpayer=@IdPayerAux and [DateOfPayerCommission]=@MounthNext)
    begin
        exec st_SavePayerCommission @IdPayerAux,@IdPaymentTypeAux,@MounthNext,@IdUser,0,0
    end

    delete from #paymenttype where id=@id
end

drop table #paymenttype


-- salida para configuracion activa
select 
    c.IdPayer,PayerName,c.IdPaymentType,Paymentname,DateOfPayerCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,CommissionOld,CommissionNew, case when c.EnterByIdUser=@IdUser then 1 else 0 end BySystem
from 
    PayerCommission c
join 
    payer p on p.idpayer=c.idpayer and p.idgenericstatus=1
join 
    paymenttype t on c.idpaymenttype=t.idpaymenttype
join
    users u on c.enterbyiduser=u.iduser
join
    payerconfig z on c.idpayer=z.idpayer and z.idgenericstatus=1 and z.idpaymenttype=c.IdPaymentType
where 
    c.idpaymenttype=isnull(@PaymentType,c.idpaymenttype) and [DateOfPayerCommission] in (@MounthPast2,@MounthPast1,@MounthActual,@MounthNext) and active=1 
order by PayerName,Paymentname, DateOfPayerCommission