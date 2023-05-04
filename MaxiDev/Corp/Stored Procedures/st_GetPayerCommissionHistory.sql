CREATE PROCEDURE [Corp].[st_GetPayerCommissionHistory]
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
    PayerConfigCommission c WITH (NOLOCK)
join 
    payerconfig pc WITH (NOLOCK) on c.IdPayerConfig=pc.IdPayerConfig and pc.IdGenericStatus=1
join 
    payer p WITH (NOLOCK) on p.idpayer=@Idpayer
join 
    paymenttype t WITH (NOLOCK) on pc.IdPaymentType=t.idpaymenttype
join
    users u WITH (NOLOCK) on c.enterbyiduser=u.iduser
join 
	Gateway g WITH (NOLOCK) on g.IdGateway = pc.IdGateway
where 
    pc.idpayer=@Idpayer and pc.idpaymenttype=isnull(@PaymentType,pc.idpaymenttype) and pc.IdGateway = isnull(@IdGateway, pc.IdGateway) 
order by Paymentname, DateOfPayerCommission, c.DateOfLastChange
