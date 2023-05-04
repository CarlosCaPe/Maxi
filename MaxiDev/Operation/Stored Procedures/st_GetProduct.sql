
create procedure operation.[st_GetProduct]
(
    @IdProvider int = null,
    @IdCountry int = Null,
    @IdCarrier int = Null    
)
as

declare @IdOtherProduct int
set @Idprovider = isnull(@Idprovider,2)
set @IdOtherProduct = case when @Idprovider=2 then 7 when @Idprovider=3 then 9 else 0 end 

if @IdOtherProduct=7
begin
    select IdProduct,Product,RetailPrice, IdGenericStatus from [TransFerTo].Product where idcountry=isnull(@IdCountry,0) and idcarrier=isnull(@IdCarrier,0) and IdGenericStatus=1 order by Product
end

if @IdOtherProduct=9
begin
    select null IdProduct,null Product,null RetailPrice, null IdGenericStatus where 1=0
end
