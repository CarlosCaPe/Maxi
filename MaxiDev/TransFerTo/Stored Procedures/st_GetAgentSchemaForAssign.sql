
CREATE procedure [TransFerTo].[st_GetAgentSchemaForAssign]
(
    @IdAgent int = null
)
as

select IdSchema,SchemaName, Countryname, CarrierName, s.IdProduct,Product,RetailPrice,BeginValue, EndValue,Commission AgentCommission,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType, s.IdGenericStatus, [TransFerTo].fn_GetMargin(s.idcountry,s.idcarrier,s.IdProduct,BeginValue,EndValue) Margin
from 
    [TransFerTo].[Schema] s 
left join TransFerTo.Country c on s.idcountry=c.idcountry
left join TransFerTo.Carrier ca on s.idcarrier=ca.idcarrier
left join TransFerTo.Product p on s.IdProduct=p.IdProduct
where isdefault=0 /*and IdGenericStatus=1*/ and IdSchema in (select IdSchema from  [TransFerTo].[AgentSchema] where idagent=@IdAgent)
order by IsDefault,s.IdCountry,s.IdCarrier,IdProduct

select IdSchema,SchemaName, Countryname, CarrierName, s.IdProduct,Product,RetailPrice,BeginValue, EndValue,Commission AgentCommission,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType, s.IdGenericStatus, [TransFerTo].fn_GetMargin(s.idcountry,s.idcarrier,s.IdProduct,BeginValue,EndValue) Margin 
from 
    [TransFerTo].[Schema] s 
left join TransFerTo.Country c on s.idcountry=c.idcountry
left join TransFerTo.Carrier ca on s.idcarrier=ca.idcarrier
left join TransFerTo.Product p on s.IdProduct=p.IdProduct
where isdefault=0 and s.IdGenericStatus=1 and IdSchema not in (select IdSchema from  [TransFerTo].[AgentSchema] where idagent=@IdAgent)
order by IsDefault,s.IdCountry,s.IdCarrier,IdProduct