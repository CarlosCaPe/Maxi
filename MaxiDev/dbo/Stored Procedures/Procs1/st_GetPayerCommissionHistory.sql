
CREATE PROCEDURE [dbo].[st_GetPayerCommissionHistory]
(
    @Idpayer int,
    @PaymentType int = null,
	@IdGateway int = null
)
as
--salida para hostorial

select 
    distinct
    pc.IdPaymentType,Paymentname,c.DateOfPayerConfigCommission as DateOfPayerCommission,c.DateOfLastChange,c.EnterByIdUser,UserName,c.CommissionOld,c.CommissionNew,
	pc.IdGateway, g.GatewayName
from 
    PayerConfigCommission c
join 
    payerconfig pc on c.IdPayerConfig=pc.IdPayerConfig and pc.IdGenericStatus=1
join 
    payer p on p.idpayer=@Idpayer
join 
    paymenttype t on pc.IdPaymentType=t.idpaymenttype
join
    users u on c.enterbyiduser=u.iduser
join 
	Gateway g on g.IdGateway = pc.IdGateway
where 
    pc.idpayer=@Idpayer and pc.idpaymenttype=isnull(@PaymentType,pc.idpaymenttype) and pc.IdGateway = isnull(@IdGateway, pc.IdGateway) 
order by Paymentname, DateOfPayerCommission, c.DateOfLastChange
