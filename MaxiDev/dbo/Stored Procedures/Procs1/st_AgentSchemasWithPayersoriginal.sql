
CREATE Procedure [dbo].[st_AgentSchemasWithPayersoriginal]  
(  
    @IdAgent int,
    @IdLenguage int = null   
)  
AS  
--Set nocount on   

if @IdLenguage is null 
    set @IdLenguage=1

--DECLARE @IniDate DATETIME
--SET @IniDate=GETDATE()             
              
Declare @IdPaymentTypeDirectCash int              
set @IdPaymentTypeDirectCash = 4              
              
Declare @IdPaymentTypeCash int              
set @IdPaymentTypeCash =1              
              
--Declare @PaymentTypeCash  varchar(max)              
--set @PaymentTypeCash= (select top 1 PaymentName from PaymentType where IdPaymentType= @IdPaymentTypeCash)              


Select DISTINCT 
B.IdAgentSchema,  
B.SchemaName,  
D.IdCurrency,  
D.CurrencyCode,  
[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,D.CurrencyCode) CurrencyName,  
case              
  when F.IdPaymentType=@IdPaymentTypeDirectCash then @IdPaymentTypeCash              
  else F.IdPaymentType              
 end IdPaymentType,  
[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PAYMENTTYPE'+convert(varchar,F.IdPaymentType))
 PaymentName,  
G.IdPayer,  
G.PayerCode,  
G.PayerName,  
case          
 when E.EndDateTempSpread>GETDATE() then E.TempSpread           
 else 0          
 end SchemaTempSpreadValue,   
F.SpreadValue as PayerSpreadValue,  
E.SpreadValue as SchemaSpreadValue,  
E.IdSpread as SchemaIdSpread,  
ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) RefExRate,   
F.IdPayerConfig,  
C.IdCountry,
E.IdFee
INTO #refexrate  
--from RelationAgentSchema A with (nolock) 
--Join AgentSchema B with (nolock) on (A.IdAgentSchema=B.IdAgentSchema)  
from AgentSchema B  with (nolock)
Join CountryCurrency C with (nolock) on (C.IdCountryCurrency=B.IdCountryCurrency)   
Join Currency D with (nolock) on (D.IdCurrency=C.IdCurrency)  
Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
Join PaymentType H with (nolock) on (H.IdPaymentType=F.IdPaymentType)
LEFT JOIN RefExRate R1 (nolock) ON R1.IdCountryCurrency=B.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and F.IdGateway=R1.IdGateway and F.IdPayer=R1.IdPayer  
LEFT JOIN RefExRate R2 (nolock) ON R2.IdCountryCurrency=B.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and F.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
LEFT JOIN RefExRate R3 (nolock) ON R3.IdCountryCurrency=B.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
where IdAgent=@IdAgent and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1   
--Order by B.SchemaName asc , PaymentName asc, (F.SpreadValue+ E.SpreadValue + ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) ) DESC

delete from #refexrate where CurrencyCode='USD' and RefExRate=1

SELECT 
    IdAgentSchema,SchemaName,IdCurrency,CurrencyCode,CurrencyName,IdPaymentType,PaymentName,IdPayer,PayerCode,PayerName,SchemaTempSpreadValue,PayerSpreadValue,SchemaSpreadValue,SchemaIdSpread,RefExRate,IdPayerConfig,IdCountry, IdFee
FROM #refexrate
Order by 
    SchemaName asc , PaymentName ASC, PayerSpreadValue+SchemaSpreadValue+RefExRate DESC, PayerName asc



-- PARA MAPEO
/*
SELECT
7973 IdAgentSchema,
'DD' SchemaName,
1 IdCurrency,
'DF' CurrencyCode,
'SDF' CurrencyName,
2 IdPaymentType,
'SDF' PaymentName,
57 IdPayer,
'SDF' PayerCode,
'SDF' PayerName,
0.00 SchemaTempSpreadValue,
0.00 PayerSpreadValue,
0.00 SchemaSpreadValue,
1 SchemaIdSpread,
1939.00 RefExRate,
281 IdPayerConfig,
2 IdCountry,
26 IdFee
*/

