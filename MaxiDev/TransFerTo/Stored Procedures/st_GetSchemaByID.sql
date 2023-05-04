CREATE procedure [TransFerTo].st_GetSchemaByID
(
    @IdSchema int
)
as

select 
IdSchema,SchemaName,s.IdCountry,Countryname,s.IdCarrier, CarrierName,s.IdProduct,Product,BeginValue,EndValue,Commission,[TransFerTo].fn_GetMargin(s.IdCountry,s.IdCarrier,s.IdProduct,BeginValue,EndValue)  margen,IsDefault,
case 
    when s.idcountry is null and s.idcarrier is null and s.IdProduct is null then 0
    when s.idcountry is not null and s.idcarrier is null and s.IdProduct is null then 1
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is null then 2
    when s.idcountry is not null and s.idcarrier is not null and s.IdProduct is not null then 3
end
CommissionType
from [TransFerTo].[Schema] s
left join TransFerTo.Country c on s.idcountry=c.idcountry
left join TransFerTo.Carrier ca on s.idcarrier=ca.idcarrier
left join TransFerTo.Product p on s.IdProduct=p.IdProduct
where 
    IdSchema=@IdSchema
order by IsDefault,IdCountry,IdCarrier,IdProduct

