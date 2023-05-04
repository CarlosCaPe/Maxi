CREATE procedure [TransFerTo].[GetCarrierByCountry]
(
    @Idcountry int
)
as
select c.IdCarrier,CarrierName,c.IdCarrierTTo
from [TransFerTo].[Carrier] c
join [TransFerTo].[product]  p on c.idcarrier=p.idcarrier and p.IdGenericStatus=1
join [TransFerTo].country t on c.idcountry=t.idcountry
where t.IdCountryTTo=@Idcountry
group by c.idcarrier,CarrierName,c.IdCarrierTTo
having count(1)>1
order by CarrierName