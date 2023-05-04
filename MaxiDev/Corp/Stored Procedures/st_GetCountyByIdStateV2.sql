CREATE PROCEDURE [Corp].[st_GetCountyByIdStateV2]
(
    @IdState int
)
as
select 
c.idcounty,countyname,z.CityName,r.IdCountyClass, isnull(cc.CountyClassName,'') CountyClassName, REPLACE(STR(z.zipcode, 5), SPACE(1), '0') zipcode
from county c with(nolock)
left join ZipCode z with(nolock) on c.idcounty=z.IdCounty
left join RelationCountyCountyClass r with(nolock) on c.IdCounty=r.IdCounty
left join CountyClass cc with(nolock) on r.IdCountyClass=cc.IdCountyClass
where idstate=@IdState order by countyname,z.CityName, isnull(cc.CountyClassName,''), z.zipcode
