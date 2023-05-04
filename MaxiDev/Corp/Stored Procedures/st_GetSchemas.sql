CREATE PROCEDURE [Corp].[st_GetSchemas]
--(    
    --@Search nvarchar(max)
--)
as

select IdAgentSchema,SchemaName,Description,IdFee,IdCommission,IdCountryCurrency,SchemaDefault,Spread,EndDateSpread,a.IdGenericStatus, g.GenericStatus StatusName
from 
    agentschema a
join
    GenericStatus g on a.IdGenericStatus=g.IdGenericStatus
where 
    IdAgent is null and 
    --idgenericstatus = 1 and
    schemadefault = 1 --and
    --schemadefault = case when isnull(@IsDefault,0)=1 then 1 else 0 end and
    --(schemaname like '%'+@Search+'%' or Description like '%'+@Search+'%')
order by schemaname,Description
