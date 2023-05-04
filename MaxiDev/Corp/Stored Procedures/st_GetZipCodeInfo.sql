CREATE PROCEDURE [Corp].[st_GetZipCodeInfo]
(
    @Zipcode INT
)
AS

	SELECT RIGHT('00000' + CONVERT(VARCHAR(5), ZipCode), 5) AS 'ZipCode' ,StateCode,StateName,CityName,z.IdCounty,CountyName 
	FROM zipcode z LEFT JOIN 
	 	county c ON z.idcounty=c.idcounty 
	WHERE zipcode = @Zipcode and z.idgenericstatus = 1
	
	SELECT r.idcountyclass,countyclassname 
	FROM [RelationCountyCountyClass] r LEFT JOIN 
		countyclass c ON r.idcountyclass=c.idcountyclass 
	WHERE idcounty IN (select idcounty from zipcode where zipcode = @Zipcode and idgenericstatus = 1) 
	ORDER BY countyclassname

