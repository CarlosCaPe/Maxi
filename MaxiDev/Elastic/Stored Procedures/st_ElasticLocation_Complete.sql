


CREATE PROCEDURE [Elastic].[st_ElasticLocation_Complete] (
@data xml = null,
@result varchar(max) output, --azavala_29112019
@Error bit output --azavala_29112019
)
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez">Creacion</log>
<log Date="08/01/2019" Author="jmolina">Se agrega validación de si envian null la variable @data, de ser así solo se actualiza la fecha en globalattributes</log>
<log Date="05/03/2019" Author="jmolina">Se cambia tabla de tipo variable por table temporal en tempdb => #XMLTable</log>
<log Date="29/11/2019" Author="azavala">KIMAIID: M00022 :: reference: azavala_29112019</log>
<log Date="13/05/2021" Author="jcsierra">Se optimiza el uso de LastUpdate</log>
</ChangeLog>

*********************************************************************/
BEGIN TRY
	
	DECLARE @CurrentDate DATETIME = GETDATE()


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
			SET idLocationIndex = x.idLocationIndex,
			LastUpdate = @CurrentDate,
			Synchronized = 1
		FROM Elastic.AgentLocationSearch als --WITH (NOLOCK)
			INNER JOIN #XMLTable x ON x.idLocation = als.idLocation where x.idLocationindex!='' and x.idLocationindex is not null
	END

	DECLARE @dateFinished DATETIME = DATEADD(SECOND, 1, @CurrentDate)

	--UPDATE GlobalAttributes SET 
	--	Value =Convert(VARCHAR,@dateFinished,111)+' '+Convert(VARCHAR,@dateFinished,108)
	--WHERE Name ='AgentLocationElasticSearchFinish'

	INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage) VALUES('st_ElasticLocation_Complete', GETDATE(), CONVERT(VARCHAR(20), @dateFinished, 120))
	SELECT @result = 'Base de Datos OK', @Error = 0--azavala_29112019
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_ElasticLocation_Complete', GETDATE(), @ErrorMessage)

	SELECT @result = 'Ocurrio un problema al actualizar los datos ' + ERROR_MESSAGE(), @Error = 1--azavala_29112019
END CATCH
