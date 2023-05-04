

CREATE PROCEDURE [Elastic].[st_ElasticLocation_Delete]
AS
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez">Creacion</log>
<log Date="11/01/2019" Author="jmolina">Add begin try and NoLock</log>
<log Date="29/11/2019" Author="azavala">KIMAIID: M00022 :: reference: azavala_29112019</log>
</ChangeLog>

*********************************************************************/
BEGIN TRY
	DECLARE @lastUpdate DATETIME 
	SELECT @lastUpdate = Convert(DATETIME,value) FROM GlobalAttributes WITH(NOLOCK) WHERE Name ='AgentLocationElasticSearchFinish'

	SELECT idLocation, idAgent,PaymentTypes, idAgentSchema, idCountry, countryName/*azavala_29112019*/, idState, stateName/*azavala_29112019*/, idCity, cityName/*azavala_29112019*/, LocationName, CityStateName/*azavala_29112019*/, idLocationIndex
	  FROM Elastic.AgentLocationSearch WITH(Nolock) 
	 WHERE 
		--LastUpdate >= @lastUpdate 
		Synchronized = 0
		AND idLocationIndex IS NOT NULL 
		AND idGenericStatus = 2 
		AND PaymentTypes !=''

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_ElasticLocation_Delete', GETDATE(), @ErrorMessage)
END CATCH