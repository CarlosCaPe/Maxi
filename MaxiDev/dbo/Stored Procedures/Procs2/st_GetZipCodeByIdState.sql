CREATE PROCEDURE [dbo].[st_GetZipCodeByIdState]
(
    @IdState int = null,
    @AllStatus bit = null
)
as
select REPLACE(STR(zipcode, 5), SPACE(1), '0')  zipcode,idstate, z.statename,cityname,z.idgenericstatus,GenericStatus Status from zipcode z
join genericstatus g on g.idgenericstatus=z.idgenericstatus
join state s on z.statecode=s.statecode and s.idcountry=18
where z.statecode in (select distinct statecode from state where idstate=isnull(@IdState,idstate) and idcountry=18) 
and z.idgenericstatus = case when isnull(@AllStatus,0)=1 then z.idgenericstatus else 1 end
order by statename,zipcode desc,cityname
