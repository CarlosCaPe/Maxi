create procedure [TransFerTo].st_GetAgentSchemaInfo
(
    @IdAgent int = null
)
as

select 
idagent,agentcode,agentname,IdSchema,SchemaName,CountryName,CarrierName,Product,BeginValue,EndValue,Commission,IsDefault,
case 
    when t.idcountry is null and t.idcarrier is null and t.IdProduct is null then 0
    when t.idcountry is not null and t.idcarrier is null and t.IdProduct is null then 1
    when t.idcountry is not null and t.idcarrier is not null and t.IdProduct is null then 2
    when t.idcountry is not null and t.idcarrier is not null and t.IdProduct is not null then 3
end
CommissionType
from (
select 
    a.idagent,agentcode,agentname,IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault
from 
    agent a with (nolock)
outer apply    
    (select IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault from [TransFerTo].[Schema] where isdefault=1 and IdGenericStatus=1) t 
where 
    a.idagent in (select idagent from AgentProducts where idotherproducts=7 and idgenericstatus=1)
union all
select 
    a.idagent,agentcode,agentname,s.IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault 
from 
    agent a with (nolock)
join 
    [TransFerTo].[AgentSchema] sc on a.idagent=sc.idagent
join 
    [TransFerTo].[Schema] s on s.idschema=sc.idschema
where 
    a.idagent in (select idagent from AgentProducts where idotherproducts=7 and idgenericstatus=1)
) t
left join [TransFerTo].[Country] c on t.idcountry=c.idcountry
left join [TransFerTo].[Carrier] ca on t.idcarrier=ca.idcarrier
left join [TransFerTo].[Product] p on t.IdProduct=p.IdProduct
where t.idagent=isnull(@IdAgent,t.idagent)
order by agentcode,isdefault,schemaname