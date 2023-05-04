CREATE procedure [MaxiMobile].[GetPayerFee]
	@IdAgentSchema int,
	@IdPaymentType int
as

if (@IdPaymentType=4) set @IdPaymentType=1

Select DISTINCT 
G.IdPayer,  
G.PayerName,  
e.IdFee,
isnull((	SELECT 
	 SD.IdFeeDetail
	,SD.FromAmount
	,SD.ToAmount
	,SD.Fee	
	,Sd.IsFeePercentage
	FROM feedetail SD (NOLOCK)
	WHERE SD.IdFee =E.IdFee
	ORDER BY FromAmount 
	FOR XML PATH('Row') , ROOT('Root') 
),'') FeeDetail
into #salida
from AgentSchema B
Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
where b.IdAgentSchema=@IdAgentSchema and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1 and   case              
  when F.IdPaymentType=4 then 1              
  else F.IdPaymentType              
 end = @IdPaymentType

 select IdPayer,PayerName,IdFee,convert(xml,FeeDetail) FeeDetail from #salida order by PayerName,IdFee

 drop table #salida
