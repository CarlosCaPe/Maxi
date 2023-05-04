CREATE procedure [lunex].[st_GetAgentSchemaForService]
(    
    @IdAgent int,
    @Sku int
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

declare @IdCountry int
declare @IdCarrier int
declare @IdOtherProduct int = 9

    select @IdCountry=IdCountry,@IdCarrier=IdCarrier from lunex.product with(nolock) where sku=@Sku    

    select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault,
    case 
        when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
        when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
    end
    CommissionType 
    from [TransFerTo].[Schema] s with(nolock)
    left join operation.country c with(nolock) on s.IdCountry=c.idcountry
    left join operation.carrier ca with(nolock) on s.idcarrier=ca.idcarrier    
    where     
        s.idcountry=@IdCountry and s.idcarrier is null and isdefault=0 and s.IdGenericStatus=1 and IdSchema in (select a.IdSchema from  [TransFerTo].[AgentSchema] a with(nolock) join [TransFerTo].[schema] s with(nolock) on a.idschema=s.idschema and s.IdOtherProduct=@IdOtherProduct where idagent=@IdAgent)
        and s.IdOtherProduct=@IdOtherProduct
    
    union all
    
    select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
    case 
        when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
        when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
    end
    CommissionType
    from [TransFerTo].[Schema] s with(nolock)
    left join operation.country c with(nolock) on s.IdCountry=c.idcountry
    left join operation.carrier ca with(nolock) on s.idcarrier=ca.idcarrier
    where s.idcountry=@IdCountry and s.idcarrier is null and isdefault=1 and s.IdGenericStatus=1 
    and s.IdOtherProduct=@IdOtherProduct
    
    union all
    
    select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
    case 
        when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
        when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
    end
    CommissionType
    from [TransFerTo].[Schema] s with(nolock)
    left join operation.country c with(nolock) on s.IdCountry=c.idcountry
    left join operation.carrier ca with(nolock) on s.idcarrier=ca.idcarrier
    where s.idcountry is null and s.idcarrier is null and s.idproduct is null and @idcountry is not null
    and s.IdOtherProduct=@IdOtherProduct

    union all

    select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault,
    case 
        when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
        when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
    end
    CommissionType 
    from [TransFerTo].[Schema] s with(nolock)
    left join operation.country c with(nolock) on s.IdCountry=c.idcountry
    left join operation.carrier ca with(nolock) on s.idcarrier=ca.idcarrier    
    where     
        s.idcountry=@IdCountry and s.idcarrier=@IdCarrier and isdefault=0 and s.IdGenericStatus=1 and IdSchema in (select a.IdSchema from  [TransFerTo].[AgentSchema] a with(nolock) join [TransFerTo].[schema] s with(nolock) on a.idschema=s.idschema and s.IdOtherProduct=@IdOtherProduct where idagent=@IdAgent)
        and s.IdOtherProduct=@IdOtherProduct
    
    union all
    
    select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,null Product,null RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
    case 
        when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
        when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
        when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
    end
    CommissionType
    from [TransFerTo].[Schema] s with(nolock)
    left join operation.country c with(nolock) on s.IdCountry=c.idcountry
    left join operation.carrier ca with(nolock) on s.idcarrier=ca.idcarrier
    where s.idcountry=@IdCountry and s.idcarrier=@IdCarrier and isdefault=1 and s.IdGenericStatus=1 
    and s.IdOtherProduct=@IdOtherProduct

    order by IsDefault asc ,CommissionType desc