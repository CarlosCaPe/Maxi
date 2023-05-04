CREATE PROCEDURE [dbo].[st_GetAgentSchemas]
(    
    @IdAgent int
)
AS
/********************************************************************
<Author>No Registrado</Author>
<app>MaxiCorp</app>
<Description>Use to get list of Schemes by Agent</Description>

<ChangeLog>
<log Date="02/03/2017" Author="mdelgado">Req. Identificacion de tipo cambio actualizado</log>
</ChangeLog>
*********************************************************************/
	SELECT A.IdAgentSchema,A.SchemaName,A.Description,A.EndDateSpread,A.Spread,A.IdGenericStatus
		,G.GenericStatus StatusName
		,CO.CountryName 
		,CU.CurrencyName,
		CASE WHEN ISNULL(dts.EndDateTempSpread,GETDATE()) <= GETDATE() THEN NULL ELSE dts.EndDateTempSpread END AS EndDateTempSpread 
		FROM agentschema A (NOLOCK) 
			 INNER JOIN GenericStatus G (NOLOCK) on A.IdGenericStatus=G.IdGenericStatus
			 INNER JOIN CountryCurrency CC (NOLOCK) ON A.IdCountryCurrency = CC.IdCountryCurrency 
			 INNER JOIN Country CO (NOLOCK) ON CC.IdCountry = CO.IdCountry 
			 INNER JOIN Currency CU (NOLOCK) ON CC.IdCurrency = CU.IdCurrency
			LEFT JOIN  (  
				SELECT MAX(EndDateTempSpread) AS EndDateTempSpread, asd.IdAgentSchema
				FROM [dbo].[AgentSchemaDetail] asd (nolock)
				--added filter for permance
				where asd.IdAgentSchema in
				(select IdAgentSchema from AgentSchema (nolock) where IdAgent=@IdAgent and IdGenericStatus in (1,2))
				GROUP BY asd.IdAgentSchema
				) as dts  ON dts.IdAgentSchema = a.IdAgentSchema
		WHERE a.IdGenericStatus in (1,2) and A.IdAgent=isnull(@IdAgent,A.IdAgent) 
		--(schemaname like '%'+@Search+'%' or Description like '%'+@Search+'%')
		ORDER BY A.schemaname,A.Description

