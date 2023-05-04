
create procedure [dbo].[st_GetPayerconfigCommission]
(
    @IdPayer int,
    @BaseDate datetime/*,
    @Disable Bit*/
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

	Declare @rows int 
	Declare @Idpayerconfig int 

	create table #temp (Idpayerconfig int)
	insert into #temp 
    select IdPayerConfig from Payerconfig where Idpayerconfig in (select IdPayerConfig from PayerConfig where IdPayer = @IdPayer and idgenericstatus=1) group by IdPayerConfig
	set @rows = (select count (IdPayerConfig) from #temp)

	while  @rows > 0
		begin
			set @Idpayerconfig = (select top 1 Idpayerconfig from #temp)

			if not exists (select top 1 1 from PayerconfigCommission where Idpayerconfig = @Idpayerconfig and [DateOfPayerconfigCommission]=@MounthPast2)
			begin
				exec st_SavePayerconfigCommission @Idpayerconfig,@MounthPast2,@IdUser,0,0
			end
			if not exists (select top 1 1 from PayerconfigCommission where Idpayerconfig=@Idpayerconfig and [DateOfPayerconfigCommission]=@MounthPast1)
			begin
				exec st_SavePayerconfigCommission @Idpayerconfig,@MounthPast1,@IdUser,0,0
			end
			if not exists (select top 1 1 from PayerconfigCommission where Idpayerconfig=@Idpayerconfig and [DateOfPayerconfigCommission]=@MounthActual)
			begin
				exec st_SavePayerconfigCommission @Idpayerconfig,@MounthActual,@IdUser,0,0
			end
			if not exists (select top 1 1 from PayerconfigCommission where Idpayerconfig=@Idpayerconfig and [DateOfPayerconfigCommission]=@MounthNext)
			begin
				exec st_SavePayerconfigCommission @Idpayerconfig,@MounthNext,@IdUser,0,0
			end

			delete from #temp where Idpayerconfig = @Idpayerconfig
			set @rows = (select count (IdPayerConfig) from #temp)
		end 

-- salida para configuracion activa
select 
    c.Idpayerconfig,x.idgateway,gatewayname,x.idpayer,PayerName,x.IdPaymentType,Paymentname,DateOfPayerconfigCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,CommissionOld,CommissionNew, case when c.EnterByIdUser=@IdUser then 1 else 0 end BySystem
from 
    PayerconfigCommission c
inner join 
    payerconfig x on c.Idpayerconfig=x.Idpayerconfig
join 
    payer p on p.Idpayer=x.Idpayer
join 
    paymenttype t on x.idpaymenttype=t.idpaymenttype
join
    users u on c.enterbyiduser=u.iduser
join 
    gateway g on x.idgateway=g.idgateway
where 
	x.IdPayer = @IdPayer and [DateOfPayerconfigCommission] in (@MounthPast2,@MounthPast1,@MounthActual,@MounthNext) and c.active = 1 and x.IdGenericStatus = 1 /*case when @Disable=0 then 1 else x.IdGenericStatus end and p.IdGenericStatus = case when @Disable=0 then 1 else p.IdGenericStatus end*/ order by DateOfPayerconfigCommission


--salida para historial

select 
    x.IdPaymentType,Paymentname,DateOfPayerconfigCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,CommissionOld,CommissionNew, x.IdGateway, g.GatewayName
from 
    PayerconfigCommission c
inner join 
    payerconfig x on c.Idpayerconfig=x.Idpayerconfig
join 
    payer p on p.Idpayer=x.Idpayer
join 
    paymenttype t on x.idpaymenttype=t.idpaymenttype
join
    users u on c.enterbyiduser=u.iduser
join 
	Gateway g on g.IdGateway = x.IdGateway
where 
	x.IdPayer = @IdPayer order by DateOfPayerconfigCommission, c.DateOfLastChange