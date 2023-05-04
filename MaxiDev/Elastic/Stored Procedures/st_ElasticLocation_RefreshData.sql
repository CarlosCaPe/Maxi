

CREATE PROCEDURE [Elastic].[st_ElasticLocation_RefreshData]
@LastUpdate DATETIME = null -- azavala_29112019
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez">Creacion</log>
<log Date="16/03/2018" Author="jmmolina">Se agrega regla para quitar 90 minutos a la fecha extraida de globalattributes y se agrega regla para activar ubicaciones que no tengan idlocationindex</log>
<log Date="23/04/2018" Author="jmolina">MA_008: Se corrigio la clasificación para tipo de pago ATM #1</log>
<log Date="29/04/2019" Author="jmolina">Se agrega validacion de considerar solo los Gateway activos #2</log>
<log Date="29/11/2019" Author="azavala">KIMAIID: M00022 :: reference: azavala_29112019</log>
<log Date="18/01/2020" Author="jdarellano" Name="#3">Se agregan validaciones para considerar estatus enabled para las distintas tablas.</log>
<log Date="09/05/2022" Author="jcsierra"> Se omite los pagadores / schemas de envios domesticos </log>
</ChangeLog>

*********************************************************************/
BEGIN TRY

	SET NOCOUNT ON;
	--return;
	CREATE TABLE #updatedSchemas (idAgentSchema INT)

	IF(@LastUpdate is null) --azavala_29112019
	BEGIN
		--SELECT  @LastUpdate = DATEADD(MINUTE, -120, Convert(DATETIME,Value)) FROM  GlobalAttributes  WHERE Name ='AgentLocationElasticSearch'
		SELECT  @LastUpdate = DATEADD(MINUTE, -10, Convert(DATETIME,Value)) FROM  GlobalAttributes with(nolock)  WHERE Name ='AgentLocationElasticSearchFinish'
	END

	--INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage) VALUES('st_ElasticLocation_RefreshData', GETDATE(), CONVERT(Varchar(20), @LastUpdate, 120))
	DECLARE @IdCountryUSA INT
	SET @IdCountryUSA = dbo.GetGlobalAttributeByName('IdCountryUSA')

	INSERT INTO #updatedSchemas (idAgentSchema)	
	-- AgentSchemas
	SELECT idAgentSchema 
	FROM AgentSchema s WITH(NOLOCK) 
		JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = s.IdCountryCurrency
	WHERE 
		s.DateOfLastChange > @LastUpdate 
		AND IdGenericStatus=1--#3
		AND cc.IdCountry <> @IdCountryUSA
	UNION 
	-- PayerConfig and AgentSchema Detail
	SELECT idAgentSchema 
	FROM PayerConfig p WITH(NOLOCK)
		JOIN AgentSchemaDetail asd WITH(NOLOCK) ON asd.IdPayerConfig =p.IdPayerConfig
		JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = p.IdCountryCurrency
	WHERE 
		(p.DateOfLastChange > @LastUpdate OR asd.DateOfLastChange > @LastUpdate) 
		AND p.IdGenericStatus=1--#3
		AND cc.IdCountry <> @IdCountryUSA
	UNION
	-- Others
	SELECT DISTINCT ags.IdAgentSchema
	FROM AgentSchemaDetail AS ags WITH(NOLOCK)
		INNER JOIN dbo.PayerConfig as pc WITH(NOLOCK) ON ags.IdPayerConfig = pc.IdPayerConfig
		JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = pc.IdCountryCurrency
		INNER JOIN dbo.Payer As p WITH(NOLOCK) ON pc.IdPayer = p.IdPayer
		INNER JOIN dbo.Branch As b WITH(NOLOCK) ON b.IdPayer = p.IdPayer
		INNER JOIN dbo.Gateway As g WITH(NOLOCK) ON pc.IdGateway = g.IdGateway --#2
		INNER JOIN dbo.City AS ct WITH(NOLOCK) On b.IdCity = ct.IdCity
		INNER JOIN dbo.[State] as s WITH(NOLOCK) On ct.IdState = s.IdState
		INNER JOIN dbo.Country as c WITH(NOLOCK) on s.IdCountry = c.IdCountry
	WHERE 1 = 1
	and pc.IdGenericStatus=1--#3{
	and p.IdGenericStatus=1
	and b.IdGenericStatus=1
	and g.[Status]=1--}#3
	AND cc.IdCountry <> @IdCountryUSA
	AND (ct.DateOfLastChange > @LastUpdate
		OR s.DateOfLastChange > @LastUpdate
		OR c.DateOfLastChange > @LastUpdate
		OR b.DateOfLastChange > @LastUpdate
		OR p.DateOfLastChange > @LastUpdate
		OR g.DateOfLastChange > @LastUpdate);--#2

	SELECT 
		id=IDENTITY(INT,1,1), 
		a.idAgent,
		idAgentSchema
	INTO #tmpSchemas
	FROM AgentSchema agts WITH(NOLOCK)
		INNER JOIN Agent a WITH(NOLOCK) ON a.IdAgent = agts.IdAgent
	WHERE EXISTS (SELECT 1 FROM #updatedSchemas AS ups WHERE agts.IdAgentSchema = ups.idAgentSchema);

	--CREATE UNIQUE CLUSTERED  INDEX pktmpSchemas ON #tmpSchemas (id)
	CREATE UNIQUE INDEX IX_tmpSchemas_id_idAgent_idAgentSchema ON #tmpSchemas(id, idAgent, idAgentSchema);

	--MA_008
	SELECT distinct asd.IdAgentSchema, ass.IdAgent, ct.idcity INTO #Payment6_IX
	FROM dbo.PayerConfig As pc WITH(NOLOCK)
	INNER JOIN dbo.Payer AS p WITH(NOLOCK) ON p.IdPayer = pc.IdPayer
	INNER JOIN dbo.Branch As b WITH(NOLOCK) ON b.IdPayer = p.IdPayer
	INNER JOIN dbo.Gateway As g WITH(NOLOCK) ON pc.IdGateway = g.IdGateway
	INNER JOIN City ct WITH(NOLOCK) ON ct.IdCity = b.IdCity
	INNER JOIN dbo.AgentSchemaDetail As asd WITH(NOLOCK) ON asd.IdPayerConfig = pc.IdPayerConfig
	inner join dbo.AgentSchema As ass WITH(NOLOCK) ON ass.IdAgentSchema = asd.IdAgentSchema
	WHERE 1 = 1
	AND pc.IdPaymentType = 6
	AND ass.IdGenericStatus = 1
	AND pc.IdGenericStatus=1
	AND p.IdGenericStatus = 1
	AND b.IdGenericStatus = 1
	AND g.[Status] = 1
	AND EXISTS(SELECT 1 FROM #tmpSchemas as us WHERE us.idAgentSchema = ass.IdAgentSchema);

	--MA_008
	--CREATE UNIQUE CLUSTERED INDEX IDX_Payment6_IdAgentSchema_IdAgent_idcity ON #Payment6_IX (IdAgentSchema, IdAgent, idcity)
	CREATE UNIQUE INDEX IDX_Payment6_IdAgentSchema_IdAgent_idcity ON #Payment6_IX (IdAgentSchema, IdAgent, idcity);

	CREATE TABLE #TmpAgtLocSer (	
		idAgent         INT NULL,
		idAgentSchema   INT NULL,
		idCountry       INT NULL,
		countryName		VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,--azavala_29112019
		idState         INT NULL,
		stateName		VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,--azavala_29112019
		idCity          INT NULL,
		cityName		VARCHAR(100) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,--azavala_29112019
		LocationName    VARCHAR (2000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
		CityStateName   VARCHAR (1000) COLLATE SQL_Latin1_General_CP1_CI_AS NULL,--azavala_29112019
		PaymentTypes    VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS
	);

	--CREATE CLUSTERED INDEX PK_TMPAGTLOCSER1 ON #TmpAgtLocSer (idAgentSchema,idCity)
	CREATE INDEX IX_TmpAgtLocSer_idAgent_idAgentSchema_idState_idCity ON #TmpAgtLocSer (idAgent, idAgentSchema, idState, idCity) INCLUDE(LocationName, PaymentTypes);

	DECLARE @ini INT,@fin INT , @schema INT , @Agent INT  
	SELECT @ini=1,@fin=count(*) FROM #tmpSchemas

	WHILE @ini <=@fin 
	BEGIN 
		SELECT @schema = idAgentSchema, @Agent =idAgent FROM #tmpSchemas WHERE id =@ini

		INSERT INTO #TmpAgtLocSer (idAgent, idAgentSchema, idCountry, countryName/*azavala_29112019*/, idState, stateName/*azavala_29112019*/, idCity, cityName/*azavala_29112019*/, LocationName, CityStateName/*azavala_29112019*/, PaymentTypes)
		SELECT 
			a.idAgent,idAgentSchema, c.idCountry, upper(c.CountryName)/*azavala_29112019*/, s.IdState, upper(s.StateName)/*azavala_29112019*/,ct.IdCity, upper(ct.CityName)/*azavala_29112019*/, upper(ct.CityName)+', '+ upper(s.StateName)+', '+upper(agts.SchemaName), (upper(ct.CityName)+', '+ upper(s.StateName)) as CityStateName/*azavala_29112019*/,
			PaymentTypes=
			CASE WHEN EXISTS (SELECT 1 FROM AgentSchemaDetail asd WITH(NOLOCK) INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig INNER JOIN dbo.Gateway As g WITH(NOLOCK) ON pc.IdGateway = g.IdGateway WHERE asd.IdAgentSchema = agts.idAgentSchema AND pc.IdGenericStatus=1 AND pc.IdPaymentType IN(1,4) AND g.[status] = 1) THEN '1' ELSE '' END + --#2
			CASE WHEN EXISTS (SELECT 1 FROM AgentSchemaDetail asd WITH(NOLOCK) INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig INNER JOIN dbo.Gateway As g WITH(NOLOCK) ON pc.IdGateway = g.IdGateway WHERE asd.IdAgentSchema = agts.idAgentSchema AND pc.IdGenericStatus=1 AND pc.IdPaymentType =2 AND g.[status] = 1) THEN '2' ELSE '' END + --#2
			CASE WHEN EXISTS (SELECT 1 FROM AgentSchemaDetail asd WITH(NOLOCK) INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig INNER JOIN dbo.Gateway As g WITH(NOLOCK) ON pc.IdGateway = g.IdGateway WHERE asd.IdAgentSchema = agts.idAgentSchema AND pc.IdGenericStatus=1 AND pc.IdPaymentType =3 AND g.[status] = 1) THEN '3' ELSE '' END + --#2
			CASE WHEN EXISTS (SELECT 1 FROM AgentSchemaDetail asd WITH(NOLOCK) INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig INNER JOIN dbo.Gateway As g WITH(NOLOCK) ON pc.IdGateway = g.IdGateway WHERE asd.IdAgentSchema = agts.idAgentSchema AND pc.IdGenericStatus=1 AND pc.IdPaymentType =5 AND g.[status] = 1) THEN '5' ELSE '' END --#2
			+ CASE WHEN EXISTS (SELECT 1 FROM #Payment6_IX AS p6 WHERE p6.IdAgent = a.IdAgent AND p6.IdAgentSchema = agts.IdAgentSchema AND p6.IdCity = ct.IdCity) THEN '6' ELSE '' END 
		FROM AgentSchema agts WITH(NOLOCK)
			INNER JOIN Agent a WITH(NOLOCK)	ON a.IdAgent = agts.IdAgent
			INNER JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = agts.IdCountryCurrency 
			INNER JOIN Country c WITH(NOLOCK) ON c.IdCountry = cc.IdCountry
			INNER JOIN [State] s WITH(NOLOCK) ON s.IdCountry = c.IdCountry
			INNER JOIN City ct WITH(NOLOCK) ON ct.IdState  = s.IdState
		WHERE 
			a.IdAgentStatus NOT IN (2,6)
			AND agts.IdGenericStatus =1
			AND agts.IdAgentSchema = @schema
			AND cc.IdCountry <> @IdCountryUSA
			AND EXISTS(SELECT 1 FROM dbo.Branch AS b WITH(NOLOCK) WHERE 1 = 1 AND b.IdCity = ct.IdCity);

		SET @ini =@ini+1
	END 
	
	--Actualizadas azavala_29112019
	UPDATE X SET 
		LocationName = IIF(X.LocationName != als.LocationName, als.LocationName, X.LocationName), 
		PaymentTypes = IIF(X.PaymentTypes != als.PaymentTypes, als.PaymentTypes, X.PaymentTypes),
		LastUpdate = IIF(X.LocationName != als.LocationName OR X.PaymentTypes != als.PaymentTypes, getdate(), X.LastUpdate),
		Synchronized = 0
	FROM Elastic.AgentLocationSearch X --(NOLOCK)
	LEFT OUTER JOIN #TmpAgtLocSer als ON  als.idAgent = X.idAgent AND als.idAgentSchema = X.idAgentSchema AND als.idState = X.idState AND als.idCity = X.idCity 
	WHERE 1 = 1
	AND EXISTS(SELECT 1 FROM #TmpAgtLocSer wals WHERE X.idAgent = wals.idAgent AND X.idAgentSchema = wals.idAgentSchema)
	

	--Cambio estatus a habilitadas azavala_29112019
	UPDATE X SET 
		IdGenericStatus = 1, 
		LastUpdate = NULL, 
		Synchronized = 0
	FROM Elastic.AgentLocationSearch X --(NOLOCK)
	WHERE 1 = 1
	AND X.idGenericStatus = 2
	AND EXISTS(SELECT 1 FROM #TmpAgtLocSer als WHERE  als.idAgent = X.idAgent AND als.idAgentSchema = X.idAgentSchema AND als.idState = X.idState AND als.idCity = X.idCity);


	SELECT * FROM #tmpSchemas
	SELECT * FROM #TmpAgtLocSer


	--Desactivadas azavala_29112019
	UPDATE X SET 
		IdGenericStatus = 2, 
		LastUpdate = getdate(),
		Synchronized = 0
	FROM Elastic.AgentLocationSearch X
	WHERE X.idGenericStatus = 1
	AND EXISTS(SELECT 1 FROM #tmpSchemas ts WHERE ts.idAgent = x.idAgent AND ts.idAgentSchema = x.idAgentSchema)
	AND NOT EXISTS(SELECT 1 FROM #TmpAgtLocSer als WHERE als.idAgent = X.idAgent AND als.idAgentSchema = X.idAgentSchema AND als.idState = X.idState AND als.idCity = X.idCity );


	--Nuevas
	INSERT INTO Elastic.AgentLocationSearch (idAgent,idAgentSchema,idCountry, countryName/*azavala_29112019*/,idState, stateName/*azavala_29112019*/,idCity, cItyName/*azavala_29112019*/,LocationName, CityStateName/*azavala_29112019*/,idGenericStatus,PaymentTypes, Synchronized)
	SELECT als.idAgent,als.idAgentSchema,als.idCountry, als.countryName /*azavala_29112019*/,als.idState,als.stateName /*azavala_29112019*/,als.idCity, als.cityName /*azavala_29112019*/,als.LocationName, als.CityStateName /*azavala_29112019*/,idGenericStatus =1, als.PaymentTypes, 0
	FROM  #TmpAgtLocSer als
	WHERE 1 = 1
	AND NOT EXISTS(SELECT 1 FROM Elastic.AgentLocationSearch X WITH(NOLOCK) WHERE X.idAgent = als.idAgent AND X.idAgentSchema = als.idAgentSchema AND X.idState = als.idState AND X.idCity = als.idCity)

		/*Valida que no existan agencias rezagadas*/
		IF EXISTS(SELECT 1 FROM Elastic.AgentLocationSearch AS als WITH(NOLOCK) WHERE 1 = 1 AND idLocationIndex IS NULL AND LastUpdate IS NOT NULL)
		BEGIN
			UPDATE alst SET 
				LastUpdate = null,
				Synchronized = 0
			  FROM Elastic.AgentLocationSearch AS alst 
		     WHERE 1 = 1 
			   AND idLocationIndex IS NULL 
			   AND LastUpdate IS NOT NULL
		END

	DECLARE @dateFinished DATETIME = DATEADD(SECOND, 1, GETDATE())

	UPDATE GlobalAttributes SET 
		Value =Convert(VARCHAR,@dateFinished,111)+' '+Convert(VARCHAR,@dateFinished,108)
	WHERE Name ='AgentLocationElasticSearchFinish'


END TRY
BEGIN CATCH
	DECLARE @Message varchar(max) = ERROR_MESSAGE()
	INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('st_ElasticLocation_RefreshData', GETDATE(), @Message)
END CATCH


