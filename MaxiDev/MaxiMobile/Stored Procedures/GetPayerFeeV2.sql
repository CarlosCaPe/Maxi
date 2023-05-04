CREATE procedure [MaxiMobile].[GetPayerFeeV2]
	@IdAgentSchema int,
	@IdPaymentType int = null
as

if (@IdPaymentType=4) set @IdPaymentType=1

declare @groupname nvarchar(max)

select @groupname=SchemaName from AgentSchema where IdAgentSchema=@IdAgentSchema

create table #salida
(
	id int identity(1,1),
	idfee int,
	groupname nvarchar(max),
	tot int
)

insert into #salida
Select   
e.IdFee, @groupname groupname,
count(1) tot
from AgentSchema B
Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
where b.IdAgentSchema=@IdAgentSchema and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1 and   case              
  when F.IdPaymentType=4 then 1              
  else F.IdPaymentType              
 end = isnull(@IdPaymentType, F.IdPaymentType )
group by e.IdFee
having count(1)>1
order by tot desc

insert into #salida
Select   
e.IdFee, g.PayerName groupname,
count(1) tot
from AgentSchema B
Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
where b.IdAgentSchema=@IdAgentSchema and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1 and   case              
  when F.IdPaymentType=4 then 1              
  else F.IdPaymentType              
 end = isnull(@IdPaymentType, F.IdPaymentType )
 and e.IdFee not in (select IdFee from #salida)
group by e.IdFee, g.PayerName
having count(1)=1
order by g.PayerName

select IdFee, Tot,upper(case when tot=1 then groupname else groupname+' '+convert(varchar,id) end) GroupName,
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
from #salida e order by tot desc,groupname

 drop table #salida
