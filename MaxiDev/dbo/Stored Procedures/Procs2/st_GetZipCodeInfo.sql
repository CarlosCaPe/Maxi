
CREATE PROCEDURE [dbo].[st_GetZipCodeInfo]
(
    @Zipcode int
)
as

select ZipCode,StateCode,StateName,CityName,z.IdCounty,CountyName from zipcode z left join county c on z.idcounty=c.idcounty where zipcode=@Zipcode and z.idgenericstatus=1

select r.idcountyclass,countyclassname from [RelationCountyCountyClass] r left join countyclass c on r.idcountyclass=c.idcountyclass where idcounty in (select idcounty from zipcode where zipcode=@Zipcode and idgenericstatus=1) order by countyclassname
