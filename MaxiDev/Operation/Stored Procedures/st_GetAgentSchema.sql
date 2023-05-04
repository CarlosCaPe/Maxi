
CREATE procedure [Operation].[st_GetAgentSchema]
(
    @IdAgent int,
    @IdCountry int = null,
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
set @Idprovider = isnull(@Idprovider,2);
set @IdOtherProduct = case when @Idprovider=2 then 7 when @Idprovider=3 then 9 else 0 end ;

if @IdOtherProduct=7
begin
select s.IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct, product Productname,BeginValue,EndValue,Commission,IsDefault 
from [TransFerTo].[Schema] s with(nolock)
left join [TransFerTo].country c with(nolock) on s.idcountry=c.idcountry
left join [TransFerTo].carrier d with(nolock) on s.idcarrier=d.idcarrier
left join [TransFerTo].product p with(nolock) on s.idproduct=p.idproduct
where s.idcountry=isnull(@IdCountry,s.idcountry) and isdefault=1 and s.IdGenericStatus=1
and s.idotherproduct=@IdOtherProduct
union all
select s.IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct, product Productname,BeginValue,EndValue,Commission,IsDefault 
from [TransFerTo].[Schema] s with(nolock)
left join [TransFerTo].country c with(nolock) on s.idcountry=c.idcountry
left join [TransFerTo].carrier d with(nolock) on s.idcarrier=d.idcarrier
left join [TransFerTo].product p with(nolock) on s.idproduct=p.idproduct
where s.idcountry=isnull(@IdCountry,s.idcountry) and isdefault=0 and s.IdGenericStatus=1 and s.IdSchema in (select a.IdSchema from  [TransFerTo].[AgentSchema] a with(nolock) join [TransFerTo].[schema] s with(nolock) on a.idschema=s.idschema and s.IdOtherProduct=@IdOtherProduct where idagent=@IdAgent)
and s.idotherproduct=@IdOtherProduct
order by schemaname--IsDefault,IdCountry,IdCarrier,IdProduct
end

if @IdOtherProduct=9
begin
select s.IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct, null Productname,BeginValue,EndValue,Commission,IsDefault 
from [TransFerTo].[Schema] s with(nolock)
left join operation.country c with(nolock) on s.idcountry=c.idcountry
left join operation.carrier d with(nolock) on s.idcarrier=d.idcarrier
where s.idcountry=isnull(@IdCountry,s.idcountry) and isdefault=1 and s.IdGenericStatus=1
and s.idotherproduct=@IdOtherProduct
union all
select s.IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct, null Productname,BeginValue,EndValue,Commission,IsDefault 
from [TransFerTo].[Schema] s with(nolock)
left join operation.country c with(nolock) on s.idcountry=c.idcountry
left join operation.carrier d with(nolock) on s.idcarrier=d.idcarrier
where s.idcountry=isnull(@IdCountry,s.idcountry) and isdefault=0 and s.IdGenericStatus=1 and s.IdSchema in (select a.IdSchema from  [TransFerTo].[AgentSchema] a with(nolock) join [TransFerTo].[schema] s with(nolock) on a.idschema=s.idschema and s.IdOtherProduct=@IdOtherProduct where idagent=@IdAgent)
and s.idotherproduct=@IdOtherProduct
order by schemaname--IsDefault,IdCountry,IdCarrier,IdProduct
end