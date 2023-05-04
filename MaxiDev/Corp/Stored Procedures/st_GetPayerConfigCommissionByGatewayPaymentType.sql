CREATE PROCEDURE [Corp].[st_GetPayerConfigCommissionByGatewayPaymentType]
(
    @IdGateway int =  null,
    @PaymentType int =  null,
    @BaseDate datetime,
    @Disable Bit
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
declare @idpayerconfigAux int

create table #payerconfig
(
    Id int identity (1,1),
    idpayerconfig int
)

insert into #payerconfig
select idpayerconfig  from payerconfig x WITH (NOLOCK)
join 
    payer p WITH (NOLOCK) on x.idpayer=p.idpayer
where 
	idpaymenttype=isnull(@PaymentType,idpaymenttype) and 
	idgateway=isnull(@IdGateway,idgateway) and 
	x.idgenericstatus=case when @Disable=0 then 1 else x.IdGenericStatus end and
	p.IdGenericStatus = case when @Disable=0 then 1 else p.IdGenericStatus end

--select * from #paymenttype

while exists (select top 1 1 from #payerconfig)
Begin
    select top 1 @Id=id,@idpayerconfigAux=idpayerconfig from #payerconfig

    if not exists (select top 1 1 from PayerConfigCommission WITH (NOLOCK) where idpayerconfig=@idpayerconfigAux and [DateOfPayerConfigCommission]=@MounthPast2)
    begin
        exec [Corp].[st_SavePayerConfigCommission] @idpayerconfigAux,@MounthPast2,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerConfigCommission WITH (NOLOCK) where idpayerconfig=@idpayerconfigAux and [DateOfPayerConfigCommission]=@MounthPast1)
    begin
        exec [Corp].[st_SavePayerConfigCommission] @idpayerconfigAux,@MounthPast1,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerConfigCommission WITH (NOLOCK) where idpayerconfig=@idpayerconfigAux and [DateOfPayerConfigCommission]=@MounthActual)
    begin
        exec [Corp].[st_SavePayerConfigCommission] @idpayerconfigAux,@MounthActual,@IdUser,0,0
    end
    if not exists (select top 1 1 from PayerConfigCommission WITH (NOLOCK) where idpayerconfig=@idpayerconfigAux and [DateOfPayerConfigCommission]=@MounthNext)
    begin
        exec [Corp].[st_SavePayerConfigCommission] @idpayerconfigAux,@MounthNext,@IdUser,0,0
    end

    delete from #payerconfig where id=@id
end

drop table #payerconfig

-- salida para configuracion activa
select 
    c.idpayerconfig,x.idgateway,gatewayname,x.idpayer,PayerName,x.IdPaymentType,Paymentname,DateOfPayerConfigCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,CommissionOld,CommissionNew, 
	--inicio Aldo Moran
	case when c.EnterByIdUser=@IdUser then 1 else 0 end BySystem,
	cnt.CountryName
	--fin
from 
    PayerConfigCommission c WITH (NOLOCK)
join 
    payerconfig X WITH (NOLOCK) on c.idpayerconfig=x.idpayerconfig
join 
    payer p WITH (NOLOCK) on x.idpayer=p.idpayer
join 
    paymenttype t WITH (NOLOCK) on x.idpaymenttype=t.idpaymenttype
join
    users u WITH (NOLOCK) on c.enterbyiduser=u.iduser
join
    gateway g WITH (NOLOCK) on g.idgateway=x.idgateway
--inicio  Aldo Moran
join 
	CountryCurrency cc WITH (NOLOCK) on cc.IdCountryCurrency = x.IdCountryCurrency
join 
	Country cnt WITH (NOLOCK) on cc.IdCountry = cnt.IdCountry
--fin
where 
    x.idpaymenttype=isnull(@PaymentType,x.idpaymenttype) and x.idgateway=isnull(@IdGateway,x.IdGateway) and [DateOfPayerConfigCommission] in (@MounthPast2,@MounthPast1,@MounthActual,@MounthNext) and active=1 
    and x.IdGenericStatus = case when @Disable=0 then 1 else x.IdGenericStatus end and p.IdGenericStatus = case when @Disable=0 then 1 else p.IdGenericStatus end
order by gatewayname,PayerName,Paymentname, DateOfPayerConfigCommission
