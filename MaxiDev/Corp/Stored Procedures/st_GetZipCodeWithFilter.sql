CREATE PROCEDURE [Corp].[st_GetZipCodeWithFilter]
(
	@Filter nvarchar(25),
    @IdState int = null,
    @AllStatus bit = null
)
as
IF (@Filter IS NULL)
	BEGIN
		SELECT REPLACE(STR(zipcode, 5), SPACE(1), '0') zipcode, idstate, z.statename, cityname, z.idgenericstatus, GenericStatus Status 
			FROM zipcode z WITH (NOLOCK)
				JOIN genericstatus g WITH (NOLOCK) ON g.idgenericstatus=z.idgenericstatus
				JOIN state s WITH (NOLOCK) ON z.statecode=s.statecode AND s.idcountry=18
			WHERE z.statecode in (SELECT DISTINCT statecode 
								  FROM state WITH (NOLOCK)
								  WHERE idstate=ISNULL(@IdState,idstate) AND idcountry=18) 
				AND z.idgenericstatus = CASE WHEN ISNULL(@AllStatus,0)=1 THEN z.idgenericstatus ELSE 1 END 
			ORDER BY statename,zipcode DESC,cityname
	END
ELSE
BEGIN
		SELECT REPLACE(STR(zipcode, 5), SPACE(1), '0') zipcode, idstate, z.statename, cityname, z.idgenericstatus, GenericStatus Status 
			FROM zipcode z WITH (NOLOCK)
				JOIN genericstatus g WITH (NOLOCK) ON g.idgenericstatus=z.idgenericstatus
				JOIN state s WITH (NOLOCK) ON z.statecode=s.statecode AND s.idcountry=18
			WHERE z.statecode in (SELECT DISTINCT statecode 
								  FROM state WITH (NOLOCK)
								  WHERE idstate=ISNULL(@IdState,idstate) AND idcountry=18) 
				AND z.idgenericstatus = CASE WHEN ISNULL(@AllStatus,0)=1 THEN z.idgenericstatus ELSE 1 END AND
				(zipcode LIKE '%'+@Filter+'%' OR z.statename LIKE '%'+@Filter+'%' OR cityname LIKE '%'+@Filter+'%')
			ORDER BY statename,zipcode DESC,cityname
	END
