CREATE   procedure [DTOne].[st_GetAgentSchemaAPI]
(
    @IdAgent int,
    @IdCountryTTo int
)
as

declare @IdCountry int

select @IdCountry=idcountry from [DTOne].country where IdCountry=@IdCountryTTo

select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,s.IdProduct,p.Product,
p.RetailPrice,BeginValue,EndValue,Commission,IsDefault,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType,
c.IdCountry,
ca.IdCarrierDTO 
from [TransFerTo].[Schema] s
left join [DTOne].country c on s.IdCountry=c.idcountry
left join [DTOne].carrier ca on s.idcarrier=ca.idcarrier
left join [DTOne].product p on s.idproduct=p.idproduct
where s.idcountry=isnull(@IdCountry,s.idcountry) and isdefault=0 and s.IdGenericStatus=1 and 
IdSchema in (select IdSchema from  [TransFerTo].[AgentSchema] where idagent=@IdAgent)
union all
select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,
s.IdProduct,p.Product,p.RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType,
c.IdCountry,
ca.IdCarrierDTO 
from [TransFerTo].[Schema] s
left join [DTOne].country c on s.IdCountry=c.idcountry
left join [DTOne].carrier ca on s.idcarrier=ca.idcarrier
left join [DTOne].product p on s.idproduct=p.idproduct
where s.idcountry=isnull(@IdCountry,s.idcountry) and isdefault=1 and s.IdGenericStatus=1
union all
select @IdAgent IdAgent,IdSchema,SchemaName,s.IdCountry,countryname,s.IdCarrier,carriername,
s.IdProduct,p.Product,p.RetailPrice,BeginValue,EndValue,Commission,IsDefault ,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType,
c.IdCountry,
ca.IdCarrierTTo
from [TransFerTo].[Schema] s
left join [TransFerTo].country c on s.IdCountry=c.idcountry
left join [TransFerTo].carrier ca on s.idcarrier=ca.idcarrier
left join [TransFerTo].product p on s.idproduct=p.idproduct
where s.idcountry is null and s.idcarrier is null and s.idproduct is null
order by IsDefault asc ,CommissionType desc
