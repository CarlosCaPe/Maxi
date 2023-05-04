CREATE procedure [MaxiMobile].[GetPayerSchema]
	@IdAgentSchema int,
	@IdPaymentType int
as

if (@IdPaymentType=4) set @IdPaymentType=1

Select DISTINCT 
D.CurrencyCode,  
G.IdPayer,  
G.PayerName,  
case          
 when E.EndDateTempSpread>GETDATE() then E.TempSpread           
 else 0          
 end SchemaTempSpreadValue,   
F.SpreadValue as PayerSpreadValue,  
E.SpreadValue as SchemaSpreadValue,  
E.IdSpread,  
ISNULL(R1.RefExRate,ISNULL(R2.RefExRate,ISNULL(R3.RefExRate,0))) RefExRate,   
isnull((	SELECT 
	 SD.IdSpreadDetail
	,SD.FromAmount
	,SD.ToAmount
	,SD.SpreadValue	
	, 0 Exrate
	FROM SpreadDetail SD (NOLOCK)
	WHERE SD.IdSpread =E.IdSpread
	ORDER BY FromAmount 
	FOR XML PATH('Row') , ROOT('Root') 
),'') spreedDetail
INTO #refexrate  
from AgentSchema B
Join CountryCurrency C with (nolock) on (C.IdCountryCurrency=B.IdCountryCurrency)   
Join Currency D with (nolock) on (D.IdCurrency=C.IdCurrency)  
Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
--Join PaymentType H with (nolock) on (H.IdPaymentType=F.IdPaymentType)
LEFT JOIN RefExRate R1 ON R1.IdCountryCurrency=B.IdCountryCurrency and R1.Active=1 and R1.RefExRate<>0 and F.IdGateway=R1.IdGateway and F.IdPayer=R1.IdPayer  
LEFT JOIN RefExRate R2 ON R2.IdCountryCurrency=B.IdCountryCurrency and R2.Active=1 and R2.RefExRate<>0 and F.IdGateway=R2.IdGateway and R2.IdPayer is NULL AND R1.RefExRate IS NULL
LEFT JOIN RefExRate R3 ON R3.IdCountryCurrency=B.IdCountryCurrency and R3.Active=1 and R3.IdGateway is NULL and R3.IdPayer is NULL AND R1.RefExRate IS NULL AND R2.RefExRate IS NULL
where b.IdAgentSchema=@IdAgentSchema and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1 and   case              
  when F.IdPaymentType=4 then 1              
  else F.IdPaymentType              
 end = @IdPaymentType

SELECT 
    IdPayer,PayerName,CurrencyCode,IdSpread,isnull(SchemaTempSpreadValue,0)+isnull(PayerSpreadValue,0)+isnull(SchemaSpreadValue,0)+isnull(RefExRate,0) exrate, convert(xml,spreedDetail) spreedDetail
FROM #refexrate
Order by 
    isnull(SchemaTempSpreadValue,0)+isnull(PayerSpreadValue,0)+isnull(SchemaSpreadValue,0)+isnull(RefExRate,0) DESC, PayerName asc

drop table #refexrate
