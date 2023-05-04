CREATE procedure [TransFerTo].[st_GetTransferToCarrier]
(
    @IdCountry int = Null    
)
as


select distinct
    c.idcarrier,CarrierName, c.IdCarrierTTo, c.IdGenericStatus
from 
    [TransFerTo].Carrier c
where 
    c.idcountry=isnull(@IdCountry,0) and IdGenericStatus = 1
group by 
    c.idcarrier,CarrierName, c.IdCarrierTTo,c.idGenericStatus 
having
    count(1)>0
order by 
    CarrierName