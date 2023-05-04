create procedure st_GetCountyByIdState
(
    @IdState int
)
as
select 
c.idcounty,countyname,z.CityName,r.IdCountyClass, isnull(cc.CountyClassName,'') CountyClassName, z.zipcode
from county c
left join ZipCode z on c.idcounty=z.IdCounty
left join RelationCountyCountyClass r on c.IdCounty=r.IdCounty
left join CountyClass cc on r.IdCountyClass=cc.IdCountyClass
where idstate=@IdState order by countyname,z.CityName, isnull(cc.CountyClassName,''), z.zipcode