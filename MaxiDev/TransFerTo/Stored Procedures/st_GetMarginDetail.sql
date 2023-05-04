
CREATE procedure [TransFerTo].[st_GetMarginDetail]
(
    @idcountry int =null,
    @idcarrier int =null,
    @idproduct int =null,
    @retail1 money =null,
    @retail2 money =null
)
as

select p.idcountry,countryname,p.idcarrier,carriername,p.idproduct,product,retailprice,margin
from TransFerTo.product p
join TransFerTo.country c on p.IdCountry=c.IdCountry
join carrier ca on ca.IdCarrier=p.IdCarrier
where
p.idcountry=isnull(@idcountry,p.idcountry) and
p.idcarrier =isnull(@idcarrier,p.idcarrier ) and
idproduct =isnull(@idproduct,idproduct) and
p.RetailPrice>=isnull(@retail1,p.RetailPrice) and p.RetailPrice<=isnull(@retail2,p.RetailPrice)
and p.IdGenericStatus=1