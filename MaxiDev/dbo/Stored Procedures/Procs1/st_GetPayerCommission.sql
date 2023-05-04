create procedure st_GetPayerCommission
(
    @Idpayer int,
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

--select @MounthActual '@MounthActual',
--       @MounthNext '@MounthNext',
--       @MounthPast1 '@MounthPast1',
--       @MounthPast2 '@MounthPast2'


select distinct idpaymenttype into #paymenttype from payerconfig where idpayer=@Idpayer and idgenericstatus=1

--1	CASH
IF exists (select top 1 1 from #paymenttype where idpaymenttype=1)
begin
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=1 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthPast2)
    begin
        exec st_SavePayerCommission @Idpayer,1,@MounthPast2,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=1 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthPast1)
    begin
        exec st_SavePayerCommission @Idpayer,1,@MounthPast1,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=1 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthActual)
    begin
        exec st_SavePayerCommission @Idpayer,1,@MounthActual,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=1 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthNext)
    begin
        exec st_SavePayerCommission @Idpayer,1,@MounthNext,@IdUser,0,0
    end
end

--2	DEPOSIT
IF exists (select top 1 1 from #paymenttype where idpaymenttype=2)
begin
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=2 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthPast2)
    begin
        exec st_SavePayerCommission @Idpayer,2,@MounthPast2,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=2 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthPast1)
    begin
        exec st_SavePayerCommission @Idpayer,2,@MounthPast1,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=2 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthActual)
    begin
        exec st_SavePayerCommission @Idpayer,2,@MounthActual,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=2 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthNext)
    begin
        exec st_SavePayerCommission @Idpayer,2,@MounthNext,@IdUser,0,0
    end
end

--3	HOME DELIVERY
IF exists (select top 1 1 from #paymenttype where idpaymenttype=3)
begin
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=3 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthPast2)
    begin
        exec st_SavePayerCommission @Idpayer,3,@MounthPast2,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=3 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthPast1)
    begin
        exec st_SavePayerCommission @Idpayer,3,@MounthPast1,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=3 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthActual)
    begin
        exec st_SavePayerCommission @Idpayer,3,@MounthActual,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=3 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthNext)
    begin
        exec st_SavePayerCommission @Idpayer,3,@MounthNext,@IdUser,0,0
    end
end

--4	DIRECTED CASH
IF exists (select top 1 1 from #paymenttype where idpaymenttype=4)
begin
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=4 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthPast2)
    begin
        exec st_SavePayerCommission @Idpayer,4,@MounthPast2,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=4 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthPast1)
    begin
        exec st_SavePayerCommission @Idpayer,4,@MounthPast1,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=4 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthActual)
    begin
        exec st_SavePayerCommission @Idpayer,4,@MounthActual,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerCommission where idpaymenttype=4 and idpayer=@Idpayer and [DateOfPayerCommission]=@MounthNext)
    begin
        exec st_SavePayerCommission @Idpayer,4,@MounthNext,@IdUser,0,0
    end
end

-- salida para configuracion activa
select 
    c.IdPayer,PayerName,c.IdPaymentType,Paymentname,DateOfPayerCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,CommissionOld,CommissionNew, case when c.EnterByIdUser=@IdUser then 1 else 0 end BySystem
from 
    PayerCommission c
join 
    payer p on p.idpayer=c.idpayer
join 
    paymenttype t on c.idpaymenttype=t.idpaymenttype
join
    users u on c.enterbyiduser=u.iduser
where 
    c.idpayer=@Idpayer and c.idpaymenttype in (select idpaymenttype from #paymenttype) and [DateOfPayerCommission] in (@MounthPast2,@MounthPast1,@MounthActual,@MounthNext) and active=1 
order by idpaymenttype, DateOfPayerCommission


--salida para hostorial

select 
    /*c.IdPayer,PayerName,*/c.IdPaymentType,Paymentname,DateOfPayerCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,CommissionOld,CommissionNew--, case when c.EnterByIdUser=@IdUser then 1 else 0 end BySystem
from 
    PayerCommission c
join 
    payer p on p.idpayer=c.idpayer
join 
    paymenttype t on c.idpaymenttype=t.idpaymenttype
join
    users u on c.enterbyiduser=u.iduser
where 
    c.idpayer=@Idpayer and c.idpaymenttype in (select idpaymenttype from #paymenttype) /*and active=0*/ 
order by idpaymenttype, DateOfPayerCommission, c.DateOfLastChange