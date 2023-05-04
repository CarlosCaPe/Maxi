
CREATE function [TransFerTo].[fn_GetMargin]
(
    @idcountry int =null,
    @idcarrier int =null,
    @idproduct int =null,
    @retail1 money =null,
    @retail2 money =null
)
returns money
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as
begin
declare @Result money 


select @Result=round(Sum(margin)/count(1),2) 
from TransFerTo.product p with(nolock)
where
idcountry=isnull(@idcountry,idcountry) and
p.idcarrier =isnull(@idcarrier,p.idcarrier ) and
idproduct =isnull(@idproduct,idproduct) and
p.RetailPrice>=isnull(@retail1,p.RetailPrice) and p.RetailPrice<=isnull(@retail2,p.RetailPrice)
and p.IdGenericStatus=1

return isnull(@Result,0)
end