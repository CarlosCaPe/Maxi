CREATE PROCEDURE [dbo].[st_GetPayerConfigs]
@IdCountryCurrency int
as

Select PC.IdPayerConfig, PC.IdCountryCurrency, GS.IdGenericStatus, GS.GenericStatus, PC.SpreadValue, PT.IdPaymentType, PT.PaymentName, P.IdPayer, P.PayerCode, P.PayerName, PC.IdGateway,
	dbo.FunRefExRate(PC.IdCountryCurrency,PC.IdGateway,P.IdPayer) ExRate 
from PayerConfig PC (nolock)
	inner join GenericStatus GS (nolock) on GS.IdGenericStatus=PC.IdGenericStatus
	inner join PaymentType PT (nolock) on PT.IdPaymentType =PC.IdPaymentType
	inner join Payer P (nolock) on P.IdPayer=PC.IdPayer 
where PC.IdCountryCurrency=@IdCountryCurrency
order by P.PayerName, PT.PaymentName
