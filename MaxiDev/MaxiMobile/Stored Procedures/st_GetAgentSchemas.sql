CREATE procedure [MaxiMobile].[st_GetAgentSchemas]
(    
    @IdAgent int,
	@ExcludeUSD bit = 0
)
AS
/********************************************************************
<Author>JVelarde</Author>
<app>MaxiMobile</app>
<Description>Use to get list of Schemes by Agent</Description>

<ChangeLog>
<log Date="20/10/2017" Author="jvelarde">Create Date</log>
</ChangeLog>
*********************************************************************/

set @ExcludeUSD = isnull(@ExcludeUSD,0)

declare @default nvarchar(max)

select @default = CountryFlag  from [MaxiMobile].[CountryFlag] (NOLOCK) where idcountry=0

		SELECT 
		 A.IdAgentSchema
		,CO.CountryName 
		,CU.CurrencyName
		,CO.IdCountry	
		,(
		SELECT ( select distinct convert(varchar,case when IdPaymentType = 4 then 1 else IdPaymentType end) IdPaymentType, A.IdAgentSchema, A.SchemaName from PayerConfig where IdPayerConfig in 
			( select idpayerconfig from AgentSchemaDetail where IdAgentSchema=a.IdAgentSchema) 
			and IdPaymentType != 2 order by IdPaymentType FOR XML PATH('paymentType'), TYPE 
			) FOR XML PATH(''), ROOT('paymentTypes')
		) PaymentType,
		isnull(f.CountryFlag, @default) Flag,
		case when CountryCode='MEX' then 1 else 2 end orderS
		into #salida
		FROM agentschema A (NOLOCK) 			 
			 INNER JOIN CountryCurrency CC (NOLOCK) ON A.IdCountryCurrency = CC.IdCountryCurrency 
			 INNER JOIN Country CO (NOLOCK) ON CC.IdCountry = CO.IdCountry 
			 INNER JOIN Currency CU (NOLOCK) ON CC.IdCurrency = CU.IdCurrency			
			 left join [MaxiMobile].[CountryFlag] f (NOLOCK)  on cc.IdCountry = f.IdCountry
		WHERE A.IdAgent=isnull(@IdAgent,A.IdAgent)
		
		if (@ExcludeUSD=1)
			delete from #salida where CurrencyName='US DOLLARS'

		select * from #salida ORDER BY orderS

		drop table #salida
