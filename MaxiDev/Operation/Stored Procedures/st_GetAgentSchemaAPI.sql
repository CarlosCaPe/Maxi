
CREATE procedure [Operation].[st_GetAgentSchemaAPI]
(
    @IdAgent int,
    @IdCountryTTo int
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

select @IdCountry=idcountry from [TransFerTo].country with(nolock) where IdCountryTTo=@IdCountryTTo

select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,p.Product,p.RetailPrice,BeginValue,EndValue,Commission,IsDefault,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType,
c.IdCountryTTo,
ca.IdCarrierTTo 
from [TransFerTo].[Schema] s with(nolock)
left join [TransFerTo].country c with(nolock) on s.IdCountry=c.idcountry
left join [TransFerTo].carrier ca with(nolock) on s.idcarrier=ca.idcarrier
left join [TransFerTo].product p with(nolock) on s.idproduct=p.idproduct
where s.idcountry=isnull(@IdCountry,s.idcountry) and isdefault=0 and s.IdGenericStatus=1 and IdSchema in (select a.IdSchema from  [TransFerTo].[AgentSchema] a with(nolock) join [TransFerTo].[schema] s with(nolock) on a.idschema=s.idschema and s.IdOtherProduct=7 where idagent=@IdAgent)
and IdOtherProduct=7
union all
select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,p.Product,p.RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType,
c.IdCountryTTo,
ca.IdCarrierTTo
from [TransFerTo].[Schema] s with(nolock)
left join [TransFerTo].country c with(nolock) on s.IdCountry=c.idcountry
left join [TransFerTo].carrier ca with(nolock) on s.idcarrier=ca.idcarrier
left join [TransFerTo].product p on s.idproduct=p.idproduct
where s.idcountry=isnull(@IdCountry,s.idcountry) and isdefault=1 and s.IdGenericStatus=1
and IdOtherProduct=7
union all
select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,p.Product,p.RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType,
c.IdCountryTTo,
ca.IdCarrierTTo
from [TransFerTo].[Schema] s with(nolock)
left join [TransFerTo].country c with(nolock) on s.IdCountry=c.idcountry
left join [TransFerTo].carrier ca with(nolock) on s.idcarrier=ca.idcarrier
left join [TransFerTo].product p with(nolock) on s.idproduct=p.idproduct
where s.idcountry is null and s.idcarrier is null and s.idproduct is null
and IdOtherProduct=7
order by IsDefault asc ,CommissionType desc
