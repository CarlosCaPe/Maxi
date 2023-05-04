create procedure [TransFerTo].[st_GetAgentSchema]
(
    @IdAgent int,
    @IdCountry int = null    
)
as
select IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault from [TransFerTo].[Schema] where idcountry=isnull(@IdCountry,idcountry) and isdefault=1 and IdGenericStatus=1
union all
select IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault from [TransFerTo].[Schema] where idcountry=isnull(@IdCountry,idcountry) and isdefault=0 and IdGenericStatus=1 and IdSchema in (select IdSchema from  [TransFerTo].[AgentSchema] where idagent=@IdAgent)
order by IsDefault,IdCountry,IdCarrier,IdProduct