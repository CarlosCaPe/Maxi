CREATE procedure [TransFerTo].[st_GetTransferToProduct]
(
    @IdCountry int = Null,
    @IdCarrier int = Null    
)
as

select IdProduct,Product,RetailPrice, IdGenericStatus from [TransFerTo].Product where idcountry=isnull(@IdCountry,0) and idcarrier=isnull(@IdCarrier,0) and IdGenericStatus=1 order by Product