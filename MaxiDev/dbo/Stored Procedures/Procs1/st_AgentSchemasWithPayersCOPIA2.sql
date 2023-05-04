CREATE Procedure st_AgentSchemasWithPayersCOPIA2          
(                    
@IdAgent int                    
)                    
AS                    
Set nocount on                    
Select         
IdAgentSchema,        
SchemaName,        
IdCurrency,        
CurrencyCode,        
CurrencyName,        
IdPaymentType,        
PaymentName,        
IdPayer,        
PayerCode,        
PayerName,        
AgentSpreadValue,        
PayerSpreadValue,        
SchemaSpreadValue,        
RefExRate,        
IdPayerConfig,        
IdCountry        
from ExchangeRateFastRead        
Where IdAgent=@IdAgent        
    
