CREATE PROCEDURE [dbo].[st_getReferenceExrateByCountryCurrency]
as
select 
    IdCountryCurrency,c.Countryname+'/'+cu.Currencyname CountryCurrencyName,dbo.FunRefExRate(idcountrycurrency,null,null) RefExrate
from 
    countrycurrency cc
join
    country c on cc.idcountry=c.idcountry
join
    currency cu on cc.idcurrency=cu.idcurrency
