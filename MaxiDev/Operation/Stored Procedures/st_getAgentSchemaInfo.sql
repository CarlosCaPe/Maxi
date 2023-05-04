CREATE procedure [Operation].[st_getAgentSchemaInfo]
(
    @IdAgent int = null,
    @Idprovider int = null
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

declare @IdOtherProduct int
set @Idprovider = isnull(@Idprovider,2)
set @IdOtherProduct = case when @Idprovider=2 then 7 when @Idprovider=3 then 9 else 0 end 

if @IdOtherProduct=7
begin
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
        (select IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault from [TransFerTo].[Schema] with (nolock) where isdefault=1 and IdGenericStatus=1 and IdOtherProduct=@IdOtherProduct) t 
    where 
        a.idagent in (select idagent from AgentProducts with (nolock) where idotherproducts=@IdOtherProduct and idgenericstatus=1)
    union all
    select 
        a.idagent,agentcode,agentname,s.IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault 
    from 
        agent a with (nolock)
    join 
        [TransFerTo].[AgentSchema] sc with (nolock) on a.idagent=sc.idagent
    join 
        [TransFerTo].[Schema] s with (nolock) on s.idschema=sc.idschema and s.IdOtherProduct=@IdOtherProduct
    where 
        a.idagent in (select idagent from AgentProducts with (nolock) where idotherproducts=@IdOtherProduct and idgenericstatus=1)
    ) t
    left join [TransFerTo].[Country] c with (nolock) on t.idcountry=c.idcountry
    left join [TransFerTo].[Carrier] ca with (nolock) on t.idcarrier=ca.idcarrier
    left join [TransFerTo].[Product] p with (nolock) on t.IdProduct=p.IdProduct
    where t.idagent=isnull(@IdAgent,t.idagent)
    order by agentcode,isdefault,schemaname
end


if @IdOtherProduct=9
begin
    select 
    idagent,agentcode,agentname,IdSchema,SchemaName,CountryName,CarrierName,null Product,BeginValue,EndValue,Commission,IsDefault,
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
        (select IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault from [TransFerTo].[Schema] with (nolock) where isdefault=1 and IdGenericStatus=1 and IdOtherProduct=@IdOtherProduct) t 
    where 
        a.idagent in (select idagent from AgentProducts with (nolock) where idotherproducts=@IdOtherProduct and idgenericstatus=1)
    union all
    select 
        a.idagent,agentcode,agentname,s.IdSchema,SchemaName,IdCountry,IdCarrier,IdProduct,BeginValue,EndValue,Commission,IsDefault 
    from 
        agent a with (nolock)
    join 
        [TransFerTo].[AgentSchema] sc with (nolock) on a.idagent=sc.idagent
    join 
        [TransFerTo].[Schema] s with (nolock) on s.idschema=sc.idschema and s.IdOtherProduct=@IdOtherProduct
    where 
        a.idagent in (select idagent from AgentProducts with (nolock) where idotherproducts=@IdOtherProduct and idgenericstatus=1)
    ) t
    left join operation.[Country] c with (nolock) on t.idcountry=c.idcountry
    left join operation.[Carrier] ca with (nolock) on t.idcarrier=ca.idcarrier    
    where t.idagent=isnull(@IdAgent,t.idagent)
    order by agentcode,isdefault,schemaname
end