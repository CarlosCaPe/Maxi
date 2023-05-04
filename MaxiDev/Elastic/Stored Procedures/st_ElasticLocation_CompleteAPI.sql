


CREATE PROCEDURE [Elastic].[st_ElasticLocation_CompleteAPI] (
@data xml,
@result varchar(max) output,
@Error bit output
)
AS 
/********************************************************************
<Author> Alexis Zavala </Author>
<app>Elastic Search</app>
<Description> Sincronizar locaciones desde WebApi </Description>

<ChangeLog>
<log Date="18/01/2018" Author="azavala">Creacion</log>
</ChangeLog>

*********************************************************************/
BEGIN try
DECLARE @XMLTable TABLE ( idLocation int, idLocationindex VARCHAR(200))
		
DECLARE @DocHandle INT 
EXEC sp_xml_preparedocument @DocHandle OUTPUT, @data;

INSERT INTO @XMLTable (idLocation,idLocationindex)
SELECT 
idBase,idIndex
FROM OPENXML (@DocHandle, 'ArrayOfLocationMapper/LocationMapper',2)    
WITH ( 
idBase int,   
idIndex VARCHAR(200)
)


UPDATE als 
SET idLocationIndex = x.idLocationIndex,
LastUpdate = getdate()
FROM 
Elastic.AgentLocationSearch_NewIX als WITH (NOLOCK)
JOIN @XMLTable x
ON x.idLocation = als.idLocation

DECLARE @dateFinished DATETIME = dateadd(second,1,getDate())

--UPDATE GlobalAttributes 
--SET Value =Convert(VARCHAR,@dateFinished,111)+' '+Convert(VARCHAR,@dateFinished,108)
--WHERE Name ='AgentLocationElasticSearchFinish'

	SELECT @result = 'Base de Datos OK', @Error = 0
END try
BEGIN CATCH
	SELECT @result = 'Ocurrio un problema al actualizar los datos ' + ERROR_MESSAGE(), @Error = 1
END CATCH
