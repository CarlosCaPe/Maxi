
CREATE   procedure [DTOne].[st_GetProductsByCarrier]
(
    @IdCarrier int
)
as
select 
    IdProduct,	    
    Product,
    RetailPrice,
    wholesalePrice,
    Margin,   
    IdCountryDTO,
    IdCarrierDTO,
    --IdOriginCurrency,
    c1.Currencyname,
    --IdDestinationCurrency,
    c2.Currencyname,
    IdCountry,	
    IdCarrier
from 
    [DTOne].[Product] p
join
    [DTOne].[Currency] c1 on p.IdOriginCurrency=c1.idcurrency
join
    [DTOne].[Currency] c2 on p.IdDestinationCurrency=c2.idcurrency
where p.idgenericstatus=1
      and 
      p.IdCarrierDTO=@IdCarrier
order by retailprice