CREATE PROCEDURE [dbo].[st_GetPayersConfig]
@IdCountryCurrency int
AS

 SELECT PC.IdPayerConfig 
 ,PC.IdPayer 
 ,P.PayerName 
 ,P.PayerCode 
 ,PC.IdPaymentType 
 ,PT.PaymentName 
 FROM PayerConfig PC (NOLOCK)
  JOIN Payer P (NOLOCK) ON PC.IdPayer =P.IdPayer 
  JOIN PaymentType PT (NOLOCK) ON PC.IdPaymentType = PT.IdPaymentType 
 WHERE PC.IdCountryCurrency=@IdCountryCurrency
 AND PC.IdGenericStatus=1
 ORDER BY P.PayerName , PT.PaymentName

