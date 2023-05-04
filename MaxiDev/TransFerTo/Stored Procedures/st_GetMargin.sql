
CREATE procedure [TransFerTo].[st_GetMargin]
(
    @idcountry int =null,
    @idcarrier int =null,
    @idproduct int =null,
    @retail1 money =null,
    @retail2 money =null
)
as

select round(Sum(margin)/count(1),2) margin
from TransFerTo.product p
where
idcountry=isnull(@idcountry,idcountry) and
p.idcarrier =isnull(@idcarrier,p.idcarrier ) and
idproduct =isnull(@idproduct,idproduct) and
p.RetailPrice>=isnull(@retail1,p.RetailPrice) and p.RetailPrice<=isnull(@retail2,p.RetailPrice)
and p.IdGenericStatus=1
/*
select * from TransFerTo.product p where
idcountry=isnull(@idcountry,idcountry) and
p.idcarrier =isnull(@idcarrier,p.idcarrier ) and
idproduct =isnull(@idproduct,idproduct) and
p.RetailPrice>=isnull(@retail1,p.RetailPrice) and p.RetailPrice<=isnull(@retail2,p.RetailPrice)
*/