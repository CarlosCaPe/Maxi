
create procedure [TransFerTo].st_GetProductsByCarrier
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
    IdCountryTTo,
    IdCarrierTTo,
    --IdOriginCurrency,
    c1.Currencyname,
    --IdDestinationCurrency,
    c2.Currencyname,
    IdCountry,	
    IdCarrier
from 
    [TransFerTo].[Product] p
join
    [TransFerTo].[Currency] c1 on p.IdOriginCurrency=c1.idcurrency
join
    [TransFerTo].[Currency] c2 on p.IdDestinationCurrency=c2.idcurrency
where p.idgenericstatus=1
      and 
      p.idcarriertto=@IdCarrier
order by retailprice