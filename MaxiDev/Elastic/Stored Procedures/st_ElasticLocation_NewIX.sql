


CREATE PROCEDURE [Elastic].[st_ElasticLocation_NewIX]
AS
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez">Creacion</log>

</ChangeLog>

*********************************************************************/
BEGIN TRY

	IF OBJECT_ID('tempdb..#ElasticLocation_IX') IS NOT NULL DROP TABLE #ElasticLocation_IX
	CREATE TABLE #ElasticLocation_IX (idLocation int)

	INSERT INTO #ElasticLocation_IX
	SELECT TOP 10000 *
	FROM (
		SELECT DISTINCT idLocation
		  FROM Elastic.AgentLocationSearch_NewIX WITH(NOLOCK)
		  --FROM Elastic.AgentLocationSearch WITH(NOLOCK)
		 WHERE LastUpdate IS NULL 
		   AND idLocationIndex IS NULL
		   AND idGenericStatus =1 
		   AND PaymentTypes !=''
	) AS t

	UPDATE c
	   SET LastUpdate = GETDATE()
	  FROM Elastic.AgentLocationSearch_NewIX AS c
	  --FROM Elastic.AgentLocationSearch AS c
	 WHERE 1 = 1
	   AND EXISTS(SELECT 1 
	                FROM #ElasticLocation_IX AS el WITH(NOLOCK)
	               WHERE 1 = 1 
				     AND el.idLocation = c.idLocation)

--SELECT top 5000 idLocation, idAgent,PaymentTypes, idAgentSchema, idCountry, idState, idCity, LocationName,idLocationIndex
--FROM Elastic.AgentLocationSearch_NewIX (Nolock) WHERE LastUpdate IS NULL AND idLocationIndex IS NULL AND idGenericStatus =1 AND PaymentTypes !='' order by idAgent desc
	SELECT idLocation, idAgent,PaymentTypes, idAgentSchema, idCountry, idState, idCity, LocationName,idLocationIndex
	FROM Elastic.AgentLocationSearch_NewIX AS nix with(Nolock) 
	--FROM Elastic.AgentLocationSearch AS nix with(Nolock) 
	WHERE 1 = 1
	AND EXISTS(SELECT 1 
		         FROM #ElasticLocation_IX AS el WITH(NOLOCK)
		        WHERE 1 = 1 AND el.idLocation = nix.idLocation)

	IF OBJECT_ID('tempdb..#ElasticLocation_IX') IS NOT NULL DROP TABLE #ElasticLocation_IX
END TRY
BEGIN CATCH
	SELECT NULL
	IF OBJECT_ID('tempdb..#ElasticLocation_IX') IS NOT NULL DROP TABLE #ElasticLocation_IX
END CATCH
