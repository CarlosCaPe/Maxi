


CREATE PROCEDURE [Elastic].[st_ElasticLocation_NoComplete] (
@data xml = null,
@result varchar(max) output, --azavala_29112019
@Error bit output --azavala_29112019
)
AS 
/********************************************************************
<Author> Alexis Zavala </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="29/11/2019" Author="azavala">Creacion</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY

	IF @data IS NOT NULL
	BEGIN
		--DECLARE @XMLTable TABLE ( idLocation int, idLocationindex VARCHAR(200))
		CREATE TABLE #XMLTable ( idLocation int, idLocationindex VARCHAR(200))
		CREATE INDEX IX_XMLTable_IdLocation ON #XMLTable(idLocation, idLocationindex) --INCLUDE (idLocationindex)

		DECLARE @DocHandle INT 
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @data;

		--INSERT INTO @XMLTable (idLocation,idLocationindex)
		INSERT INTO #XMLTable (idLocation,idLocationindex)
		SELECT 
		idBase,idIndex
		FROM OPENXML (@DocHandle, 'ArrayOfLocationMapper/LocationMapper',2)    
		WITH ( 
		idBase int,   
		idIndex VARCHAR(200)
		)


		UPDATE als 
		SET idLocationIndex = null,
		LastUpdate =null
		FROM 
		Elastic.AgentLocationSearch als --WITH (NOLOCK)
		--JOIN @XMLTable x
		INNER JOIN #XMLTable x
		ON x.idLocation = als.idLocation
	END

	DECLARE @dateFinished DATETIME = dateadd(second,1,getDate())

	--UPDATE GlobalAttributes 
	--SET Value =Convert(VARCHAR,@dateFinished,111)+' '+Convert(VARCHAR,@dateFinished,108)
	--WHERE Name ='AgentLocationElasticSearchFinish'
	----INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage) VALUES('st_ElasticLocation_Complete', GETDATE(), CONVERT(VARCHAR(20), @dateFinished, 120))

	SELECT @result = 'Base de Datos OK', @Error = 0--azavala_29112019
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_ElasticLocation_NoComplete', GETDATE(), @ErrorMessage)

	SELECT @result = 'Ocurrio un problema al actualizar los datos ' + ERROR_MESSAGE(), @Error = 1--azavala_29112019
END CATCH
