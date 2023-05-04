CREATE PROCEDURE [Elastic].[st_ElasticLocation_Update]
AS
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez">Creacion</log>
<log Date="29/11/2019" Author="azavala">KIMAIID: M00022 :: reference: azavala_29112019</log>
<log Date="13/05/2021" Author="jcsierra">Se elimina la consideracion de 120 mins antes</log>
</ChangeLog>

*********************************************************************/
BEGIN
DECLARE @lastUpdate DATETIME 

	SELECT 
		@lastUpdate = Convert(DATETIME, value) 
	FROM GlobalAttributes WHERE Name ='AgentLocationElasticSearchFinish'
	--SELECT @lastUpdate = DATEADD(MINUTE, -120, Convert(DATETIME,Value)) FROM GlobalAttributes WHERE Name ='AgentLocationElasticSearchFinish'

	INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage) VALUES('st_ElasticLocation_Update', GETDATE(), CONVERT(Varchar(20), @LastUpdate, 120))

	SELECT 
		idLocation, 
		idAgent,
		PaymentTypes, 
		idAgentSchema, 
		idCountry, 
		countryName/*azavala_29112019*/,
		idState, 
		stateName/*azavala_29112019*/, 
		idCity, 
		cityName/*azavala_29112019*/, 
		LocationName, 
		CityStateName/*azavala_29112019*/, 
		idLocationIndex
	FROM Elastic.AgentLocationSearch (Nolock) 
	WHERE 
		--LastUpdate >= @lastUpdate 
		Synchronized = 0
		AND idLocationIndex IS NOT NULL
		AND idGenericStatus = 1 AND PaymentTypes !=''
END 
