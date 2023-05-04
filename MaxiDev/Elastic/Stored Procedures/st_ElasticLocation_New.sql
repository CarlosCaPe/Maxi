

CREATE PROCEDURE [Elastic].[st_ElasticLocation_New]
AS
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez">Creacion</log>
<log Date="15/03/2017" Author="jmmolina">Se agrega validación en extracción de ubicaciones</log>
<log Date="29/11/2019" Author="azavala">KIMAIID: M00022 :: reference: azavala_29112019</log>
</ChangeLog>

*********************************************************************/
BEGIN TRY

	IF OBJECT_ID('tempdb..#ElasticLocation') IS NOT NULL DROP TABLE #ElasticLocation
	CREATE TABLE #ElasticLocation (idLocation int)

	INSERT INTO #ElasticLocation
	SELECT TOP 10000 *
	FROM (
		SELECT DISTINCT idLocation
		  FROM Elastic.AgentLocationSearch
		 WHERE 
			--LastUpdate IS NULL
			Synchronized = 0
			AND idLocationIndex IS NULL
			AND idGenericStatus =1 
			AND PaymentTypes !=''
	) AS t

	--UPDATE c
	--   SET LastUpdate = GETDATE()
	--  FROM Elastic.AgentLocationSearch AS c
	-- WHERE 1 = 1
	--   AND EXISTS(SELECT 1 
	--                FROM #ElasticLocation AS el WITH(NOLOCK)
	--               WHERE 1 = 1 
	--			     AND el.idLocation = c.idLocation)

	SELECT idLocation, idAgent,PaymentTypes, idAgentSchema, idCountry, countryName/*azavala_29112019*/, idState, stateName/*azavala_29112019*/, idCity, cityName/*azavala_29112019*/, LocationName, CityStateName/*azavala_29112019*/, idLocationIndex
	  FROM Elastic.AgentLocationSearch AS nix WITH(Nolock) --WHERE LastUpdate IS NULL AND idGenericStatus =1 AND PaymentTypes !='' order by idAgent desc
	WHERE 1 = 1
	   AND EXISTS(SELECT 1 
		            FROM #ElasticLocation AS el WITH(NOLOCK)
		           WHERE 1 = 1 AND el.idLocation = nix.idLocation)

	IF OBJECT_ID('tempdb..#ElasticLocation') IS NOT NULL DROP TABLE #ElasticLocation
END TRY
BEGIN CATCH
	DECLARE @MessageError varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_ElasticLocation_New', GETDATE(), @MessageError)
	
	SELECT NULL
	IF OBJECT_ID('tempdb..#ElasticLocation') IS NOT NULL DROP TABLE #ElasticLocation
END CATCH