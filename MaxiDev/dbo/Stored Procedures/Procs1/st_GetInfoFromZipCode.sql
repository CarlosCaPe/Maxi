
CREATE procedure [dbo].[st_GetInfoFromZipCode]
(
    @ZipCode int
)
as
select Statecode,Statename,CityName from zipcode where zipcode=@ZipCode and idgenericstatus=1
