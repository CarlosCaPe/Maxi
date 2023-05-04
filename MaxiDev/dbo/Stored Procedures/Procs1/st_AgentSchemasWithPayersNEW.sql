
CREATE procedure st_AgentSchemasWithPayersNEW
(
@IdAgent int 
)
AS
Set nocount on              
            
Declare @IdPaymentTypeDirectCash int            
set @IdPaymentTypeDirectCash =4            
            
Declare @IdPaymentTypeCash int            
set @IdPaymentTypeCash =1            
            
Declare @PaymentTypeCash  varchar(max)            
set @PaymentTypeCash= (select top 1 PaymentName from PaymentType where IdPaymentType= @IdPaymentTypeCash)            

Select
A.IdAgentSchema,
B.SchemaName,
D.IdCurrency,
D.CurrencyCode,
D.CurrencyName,
case            
  when F.IdPaymentType=@IdPaymentTypeDirectCash then @IdPaymentTypeCash            
  else F.IdPaymentType            
 end IdPaymentType,
case            
  when F.IdPaymentType=@IdPaymentTypeDirectCash then @PaymentTypeCash            
  else H.PaymentName            
 end PaymentName,
G.IdPayer,
G.PayerCode,
G.PayerName,
case        
 when A.EndDateSpread>GETDATE() then A.Spread         
 else 0        
 end AgentSpreadValue, 
A.Spread as AgentSpreadValue,
F.SpreadValue as PayerSpreadValue,
E.SpreadValue as SchemaSpreadValue,
dbo.FunRefExRate(B.IdCountryCurrency,F.IdGateway,F.IdPayer) as RefExRate, 
F.IdPayerConfig,
C.IdCountry
from RelationAgentSchema A
Join AgentSchema B on (A.IdAgentSchema=B.IdAgentSchema)
Join CountryCurrency C on (C.IdCountryCurrency=B.IdCountryCurrency) 
Join Currency D on (D.IdCurrency=C.IdCurrency)
Join AgentSchemaDetail E on (B.IdAgentSchema=E.IdAgentSchema)
Join PayerConfig F on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)
Join Payer G on (G.IdPayer=F.IdPayer)
Join PaymentType H on (H.IdPaymentType=F.IdPaymentType)
where IdAgent=@IdAgent and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1 
Order by B.SchemaName asc , PaymentName asc, (F.SpreadValue+ E.SpreadValue +dbo.FunRefExRate(B.IdCountryCurrency,F.IdGateway,F.IdPayer)) desc      

