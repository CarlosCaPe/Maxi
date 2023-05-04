CREATE procedure [TransFerTo].[st_GetSchema]
(
    @IsDefault bit,
    @ShowDisable bit, 
    @CommissionType int  
)
as

if @CommissionType = 0
begin
select 
IdSchema,SchemaName,s.IdCountry,Countryname,s.IdCarrier, CarrierName,s.IdProduct,Product,RetailPrice,BeginValue,EndValue,Commission,[TransFerTo].fn_GetMargin(s.IdCountry,s.IdCarrier,s.IdProduct,BeginValue,EndValue)  margen,IsDefault,s.IdGenericStatus,
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
    isdefault=@IsDefault and 
    s.IdGenericStatus= case when @ShowDisable=1 then s.IdGenericStatus else 1 end 
    and (s.idcountry is not null or s.idcarrier is not null or s.IdProduct is not null)
order by SchemaName--IsDefault,IdCountry,IdCarrier,IdProduct
--return
end

if @CommissionType = 1
begin
select 
IdSchema,SchemaName,s.IdCountry,Countryname,s.IdCarrier, CarrierName,s.IdProduct,Product,RetailPrice,BeginValue,EndValue,Commission,[TransFerTo].fn_GetMargin(s.IdCountry,s.IdCarrier,s.IdProduct,BeginValue,EndValue)  margen,IsDefault,s.IdGenericStatus,
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
    isdefault=@IsDefault and 
    s.IdGenericStatus= case when @ShowDisable=1 then s.IdGenericStatus else 1 end  and  
    s.IdCountry is not null and s.IdCarrier is null and s.IdProduct is null
order by SchemaName--IsDefault,IdCountry,IdCarrier,IdProduct
--return
end


if @CommissionType = 2
begin
select 
IdSchema,SchemaName,s.IdCountry,Countryname,s.IdCarrier, CarrierName,s.IdProduct,Product,RetailPrice,BeginValue,EndValue,Commission,[TransFerTo].fn_GetMargin(s.IdCountry,s.IdCarrier,s.IdProduct,BeginValue,EndValue)  margen,IsDefault,s.IdGenericStatus,
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
    isdefault=@IsDefault and 
    s.IdGenericStatus= case when @ShowDisable=1 then s.IdGenericStatus else 1 end  and  
    s.IdCountry is not null and s.IdCarrier is not null and s.IdProduct is null
order by SchemaName--IsDefault,IdCountry,IdCarrier,IdProduct
--return
end


if @CommissionType = 3
begin
select 
IdSchema,SchemaName,s.IdCountry,Countryname,s.IdCarrier, CarrierName,s.IdProduct,Product,RetailPrice,BeginValue,EndValue,Commission,[TransFerTo].fn_GetMargin(s.IdCountry,s.IdCarrier,s.IdProduct,BeginValue,EndValue)  margen,IsDefault,s.IdGenericStatus,
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
    isdefault=@IsDefault and 
    s.IdGenericStatus= case when @ShowDisable=1 then s.IdGenericStatus else 1 end  and  
    s.IdCountry is not null and s.IdCarrier is not null and s.IdProduct is not null
order by SchemaName--IsDefault,IdCountry,IdCarrier,IdProduct
--return
end