
CREATE procedure [dbo].[st_getAgentFeeV2]
	@IdAgent int
as
/********************************************************************
<Author>jvelarde</Author>
<app>MaxiAgente</app>
<Description>Tarifas</Description>

<ChangeLog>
<log Date="31/10/2017" Author="jvelarde">tarifas</log>
<log Date="19/04/2018" Author="amoreno">se agrega los campos de IdCountry,CountryFlag, CountryName ,IdPaymentType</log>
</ChangeLog>
*********************************************************************/

create table #salida
(
	id int identity(1,1),
	IdCountry int,
  CountryFlag nvarchar(50),
  CountryName nvarchar(50),
	IdAgentSchema int,
	schemaname nvarchar(max),
  IdPaymentType int,
	idfee int,
	groupname nvarchar(max),
	tot int,
	idrow int,
	orders int
)

insert into #salida
	Select    
	 co.IdCountry
	  , co.CountryFlag
	  , co.CountryName
	  , b.IdAgentSchema
	  , b.SchemaName
	  , f.IdPaymentType
	  , e.IdFee
	  , groupname = b.SchemaName 
	  , tot =count(1) 
	  , idrow= ROW_NUMBER() over (PARTITION BY b.IdAgentSchema ORDER BY b.IdAgentSchema) 
	  , orderS =
	       case 
	        when CO.CountryCode= 'MEX'  then 1 
	        when CO.CountryCode= 'GTM'  then 2 
	        when CO.CountryCode= 'hnd'  then 3 
	        when CO.CountryCode= 'SLV'  then 4 
	        when CO.CountryCode= 'COL'  then 5 
	        when CO.CountryCode= 'DOM'  then 6 
	        else 7 
	      end 
	from 
	 AgentSchema B with (nolock) 
	Join 
	 AgentSchemaDetail E with (nolock) 
		on (B.IdAgentSchema=E.IdAgentSchema)  
	Join 
	 PayerConfig F with (nolock) 
	  on (F.IdPayerConfig=E.IdPayerConfig 
	  and F.IdCountryCurrency=B.IdCountryCurrency)  
	Join 
	 Payer G with (nolock) 
	 	on (G.IdPayer=F.IdPayer) 
	INNER JOIN 
	 CountryCurrency CC (NOLOCK) 
	 	ON b.IdCountryCurrency = CC.IdCountryCurrency 
	INNER JOIN 
	 Country CO (NOLOCK) 
	 	ON CC.IdCountry = CO.IdCountry  
	where 
	 b.IdAgent=@IdAgent 
	 and F.IdGenericStatus=1 
	 and B.IdGenericStatus=1 
	 and G.IdGenericStatus=1 	 
	group by  
	 CO.IdCountry
	 , co.CountryFlag
	 , co.CountryName
	 , b.IdAgentSchema
	 , b.SchemaName
	 , f.IdPaymentType
	 , e.IdFee,b.SchemaName
	 , CO.CountryCode
	 having count(1)>1
	order by orderS



insert into #salida
Select     CO.IdCountry, co.CountryFlag,co.CountryName,
b.IdAgentSchema,b.SchemaName,f.IdPaymentType,e.IdFee, g.PayerName groupname,
count(1) tot,
999 idrow,
orderS =
       case 
        when CO.CountryCode='MEX'   then 1 
        when CO.CountryCode='GTM'   then 2 
        when CO.CountryCode='hnd'   then 3 
        when CO.CountryCode= 'SLV'  then 4 
        when CO.CountryCode= 'COL'  then 5 
        when CO.CountryCode= 'DOM'  then 6 
        else 7 
      end 
from AgentSchema B WITH(NOLOCK)
Join AgentSchemaDetail E with (nolock) on (B.IdAgentSchema=E.IdAgentSchema)  
Join PayerConfig F with (nolock) on (F.IdPayerConfig=E.IdPayerConfig and F.IdCountryCurrency=B.IdCountryCurrency)  
Join Payer G with (nolock) on (G.IdPayer=F.IdPayer)  
INNER JOIN CountryCurrency CC WITH(NOLOCK) ON b.IdCountryCurrency = CC.IdCountryCurrency 
INNER JOIN Country CO WITH(NOLOCK) ON CC.IdCountry = CO.IdCountry  
where b.IdAgent=@IdAgent and  F.IdGenericStatus=1 and B.IdGenericStatus=1 and G.IdGenericStatus=1   
 and e.IdFee not in (select IdFee from #salida where IdCountry=CO.IdCountry and IdPaymentType=f.IdPaymentType )
group by   CO.IdCountry, co.CountryFlag, co.CountryName, b.IdAgentSchema,b.SchemaName,f.IdPaymentType,e.IdFee, g.PayerName, CO.CountryCode,case when CountryCode='MEX' then 1 else 2 end
having count(1)=1



	select 
	 * 	
	 into #salida2 
	from 
	 #salida sal1
	where 
	  IdPaymentType=4
	  and	  exists (	select 
	 								   id 	
										from 
										  #salida  sal2
										where 
										 sal2.idfee=sal1.idfee
										 and sal2.IdAgentSchema= sal1.IdAgentSchema
										 and sal2.IdCountry =sal1.IdCountry	 
										 and sal2.IdPaymentType=1							 
							)									 
	    
	select 
	 * 
	 	into #salida3
	from 
	 #salida sal1	 
	where

	 not exists (	select 
	 								   id 	
										from 
										  #salida2  sal2
										where 
										 sal2.id=sal1.id						 
							)
	order by orderS								
			

DECLARE @OperationFee		MONEY,
		@EnableOperationFee	MONEY

SET @OperationFee = CAST(dbo.GetGlobalAttributeByName('FeeCommitionDebitCard') AS MONEY)
SET @EnableOperationFee = (
	SELECT 1 FROM Agent a 
		LEFT JOIN AgentPosAccount apa ON apa.IdAgent = a.IdAgent
		LEFT JOIN AgentPosMerchant apm ON apm.IdAgentPosAccount = apa.IdAgentPosAccount
		LEFT JOIN AgentPosTerminal apt ON apt.IdAgentPosMerchant = apm.IdAgentPosMerchant
	WHERE a.IdAgent = @IdAgent
	AND apa.IdGenericStatus = 1 AND apm.IdGenericStatus = 1 AND apt.IdGenericStatus = 1
)
SET @EnableOperationFee = ISNULL(@EnableOperationFee, 0)
							 	
select idcountry,   CountryFlag, CountryName,IdAgentSchema,upper(SchemaName) SchemaName,IdPaymentType, IdFee, Tot,upper(case when tot=1 then groupname else groupname+' '+convert(varchar,idrow) end) GroupName,
isnull((	SELECT 
	 SD.IdFeeDetail
	,SD.FromAmount
	,SD.ToAmount
	,SD.Fee + IIF(@EnableOperationFee = 1, @OperationFee, 0) Fee	
	,Sd.IsFeePercentage
	FROM feedetail SD WITH(NOLOCK)
	WHERE SD.IdFee =E.IdFee
	ORDER BY FromAmount 
	FOR XML PATH('Row') , ROOT('Root') 
),'') FeeDetail ,
idrow,orders
from #salida3 e order by orders,CountryName, SchemaName,idrow,GroupName

							 	
 drop table #salida
 drop table #salida2
  drop table #salida3

