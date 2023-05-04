CREATE PROCEDURE [Corp].[st_GetZipCodeWithFilterV2]
(
	@Filter nvarchar(25),
    @IdState int = null,
    @AllStatus bit = null
)
AS

DECLARE @IdCountry INT = NULL
SELECT @IdCountry = IdCountry FROM Country (NOLOCK) WHERE CountryCode = 'USA'

IF (@Filter IS NULL)
	BEGIN
		SELECT REPLACE(STR(zipcode, 5), SPACE(1), '0') zipcode, idstate, z.statename, cityname, z.idgenericstatus, GenericStatus as Status
			FROM zipcode z (NOLOCK)
				JOIN genericstatus g (NOLOCK) ON g.idgenericstatus=z.idgenericstatus
				JOIN state s (NOLOCK) ON z.statecode=s.statecode AND s.idcountry=@IdCountry
			WHERE z.statecode in (SELECT DISTINCT statecode 
								  FROM state (NOLOCK)
								  WHERE idstate=ISNULL(@IdState,idstate) AND idcountry=@IdCountry) 
				AND z.idgenericstatus = CASE WHEN ISNULL(@AllStatus,2)=1 THEN z.idgenericstatus ELSE 1 END 
			ORDER BY statename,zipcode DESC,cityname
	END
ELSE
BEGIN
	SELECT zipcode, IdState, StateName, cityname, idgenericstatus, Status  FROM
		(SELECT REPLACE(STR(zipcode, 5), SPACE(1), '0') zipcode, idstate, z.statename, cityname, z.idgenericstatus, GenericStatus as Status
			FROM zipcode z (NOLOCK)
				JOIN genericstatus g (NOLOCK) ON g.idgenericstatus=z.idgenericstatus
				JOIN state s (NOLOCK) ON z.statecode=s.statecode AND s.idcountry=@IdCountry
			WHERE z.statecode in (SELECT DISTINCT statecode 
								  FROM state (NOLOCK)
								  WHERE idstate=ISNULL(@IdState,idstate) AND idcountry=@IdCountry) 
				AND z.idgenericstatus = CASE WHEN ISNULL(@AllStatus,2)=1 THEN z.idgenericstatus ELSE 1 END
			) tmpZC
	WHERE (zipcode LIKE '%'+@Filter+'%' OR statename LIKE '%'+@Filter+'%' OR cityname LIKE '%'+@Filter+'%')
	ORDER BY statename,zipcode DESC,cityname

END
