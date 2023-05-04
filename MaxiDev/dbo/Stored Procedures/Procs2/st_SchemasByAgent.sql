CREATE Procedure [dbo].[st_SchemasByAgent]        
(        
@IdAgent INT,  
@idPaymentType INT = NULL       
)        
AS  
/********************************************************************
<Author> Francisco Lara </Author>
<app>Agente</app>
<Description>Obtiene esquemas por agente </Description>

<ChangeLog>
<log Date="05/07/2017" Author="Fgonzalez"> Se agreca opcionalmente el IdPayment Type</log>

</ChangeLog>

*********************************************************************/      
Set nocount on        
     
IF @idPaymentType IS NULL BEGIN 

Select       
 B.IdAgentSchema      
 ,B.SchemaName      
 ,B.IdCountryCurrency      
 ,B.SchemaDefault      
 ,D.IdCurrency      
 ,D.CurrencyCode       
 ,D.CurrencyName      
 ,C.IdCountry
FROM AgentSchema B WITH(NOLOCK)
  INNER JOIN CountryCurrency C WITH(NOLOCK) on (C.IdCountryCurrency=B.IdCountryCurrency)      
  INNER JOIN Currency D WITH(NOLOCK) on (D.IdCurrency=C.IdCurrency)       
Where b.IdAgent=@IdAgent and B.IdGenericStatus=1     
order by   B.SchemaName

END ELSE BEGIN 

SELECT DISTINCT          
 B.IdAgentSchema      
 ,B.SchemaName      
 ,B.IdCountryCurrency      
 ,B.SchemaDefault      
 ,D.IdCurrency      
 ,D.CurrencyCode       
 ,D.CurrencyName      
 ,C.IdCountry
FROM AgentSchema B WITH(NOLOCK)
INNER JOIN AgentSchemaDetail det WITH(NOLOCK)
ON det.IdAgentSchema  = b.IdAgentSchema
INNER JOIN PayerConfig pc WITH(NOLOCK) 
ON pc.IdPayerConfig = det.IdPayerConfig
  INNER JOIN CountryCurrency C WITH(NOLOCK) on (C.IdCountryCurrency=B.IdCountryCurrency)      
  INNER JOIN Currency D WITH(NOLOCK) on (D.IdCurrency=C.IdCurrency)       
Where b.IdAgent=@IdAgent and B.IdGenericStatus=1     
AND IdPaymentType = @idPaymentType
order by   B.SchemaName



END 

