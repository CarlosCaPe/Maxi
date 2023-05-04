CREATE procedure [TransFerTo].[st_GetProductForService]
as
select 
    p.IdProduct,p.IdCountry,CountryName,p.IdCarrier,CarrierName,p.IdDestinationCurrency,cu1.CurrencyName as DestinationCurrency,p.IdOriginCurrency,p.Product,p.IdGenericStatus,p.RetailPrice,p.SuggestedPrice,p.WholeSalePrice,p.IdCountryTTo,P.IdCarrierTTo
from 
    [TransFerTo].[Product] p
join [TransFerTo].Country c on p.IdCountry=c.IdCountry
join [TransFerTo].Carrier ca on p.IdCarrier=ca.IdCarrier
join [TransFerTo].Currency cu1 on p.IdDestinationCurrency=cu1.IdCurrency