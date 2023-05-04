CREATE PROCEDURE [Corp].[st_GetZipCodeInfoNoStatus]
(
    @Zipcode int
)
as

select ZipCode,StateCode,StateName,CityName,z.IdCounty,CountyName from zipcode z WITH (NOLOCK) left join county c WITH(NOLOCK) on z.idcounty=c.idcounty where zipcode=@Zipcode --and z.idgenericstatus=1

select r.idcountyclass,countyclassname from [RelationCountyCountyClass] r WITH (NOLOCK) left join countyclass c WITH(NOLOCK) on r.idcountyclass=c.idcountyclass  where idcounty in (select idcounty from zipcode WITH (NOLOCK) where zipcode=@Zipcode /*and idgenericstatus=1*/) order by countyclassname
