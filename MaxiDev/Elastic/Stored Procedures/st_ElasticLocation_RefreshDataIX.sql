




CREATE PROCEDURE [Elastic].[st_ElasticLocation_RefreshDataIX]
AS 
/********************************************************************
<Author> Fabian Gonzalez </Author>
<app> Elastic Search </app>
<Description> Sincronizar Busquedas Elasticas </Description>

<ChangeLog>
<log Date="17/08/2017" Author="Fgonzalez">Creacion</log>
<log Date="16/03/2018" Author="jmmolina">Se agrega regla para quitar 90 minutos a la fecha extraida de globalattributes y se agrega regla para activar ubicaciones que no tengan idlocationindex</log>
<log Date="23/04/2018" Author="jmolina">MA_008: Se corrigio la clasificación para tipo de pago ATM #1</log>
</ChangeLog>

*********************************************************************/
BEGIN 

CREATE TABLE #updatedSchemas_IX (idAgentSchema INT)

DECLARE @LastUpdate DATETIME
SELECT  @LastUpdate = Convert(DATETIME,'1900-01-01')
INSERT INTO #updatedSchemas_IX (idAgentSchema)
SELECT idAgentSchema 
FROM AgentSchema WITH(NOLOCK) WHERE 1=1
	and DateOfLastChange > @LastUpdate 
	--and idAgent in (select idAgent from dbo.Agent with (nolock) where AgentCode in ('0020-ca','0380-ga'))
UNION 
SELECT idAgentSchema FROM PayerConfig p WITH(NOLOCK)
JOIN AgentSchemaDetail asd WITH(NOLOCK)
ON asd.IdPayerConfig =p.IdPayerConfig
WHERE  1=1
and (p.DateOfLastChange   > @LastUpdate OR asd.DateOfLastChange > @LastUpdate)
	--and IdAgentSchema in (select IdAgentSchema from dbo.AgentSchema with (nolock) where idagent in(select idAgent from dbo.Agent with (nolock) where AgentCode in ('0020-ca','0380-ga')))
UNION
SELECT DISTINCT ags.IdAgentSchema
 FROM AgentSchema AS ags WITH(NOLOCK)
 INNER JOIN dbo.CountryCurrency AS cc WITH(NOLOCK) On ags.IdCountryCurrency = cc.IdCountryCurrency
 INNER JOIN dbo.Country as c WITH(NOLOCK) on cc.IdCountry = c.IdCountry
 INNER JOIN dbo.[State] as s WITH(NOLOCK) On c.IdCountry = s.IdCountry
 INNER JOIN dbo.City AS ct WITH(NOLOCK) On s.IdState = ct.IdState
 WHERE 1 = 1
 AND (ct.DateOfLastChange > @LastUpdate
     OR s.DateOfLastChange > @LastUpdate
     OR c.DateOfLastChange > @LastUpdate)

SELECT id=IDENTITY(INT,1,1), a.idAgent,idAgentSchema
INTO #tmpSchemas_IX
FROM AgentSchema agts WITH(NOLOCK)
INNER JOIN Agent a WITH(NOLOCK)
ON a.IdAgent = agts.IdAgent
WHERE agts.IdAgentSchema IN (SELECT idAgentSchema FROM #updatedSchemas_IX)
--AND a.IdAgent in (1242, 1244, 1277, 1279, 1665, 2294)

--DELETE FROM #tmpSchemas_IX WHERE IdAgentSchema not in (
--select distinct ash.IdAgentSchema
--from dbo.AgentSchemaDetail as asd with(nolock)
--inner join dbo.PayerConfig AS pc with(nolock) on pc.IdPayerConfig = asd.IdPayerConfig
--inner join dbo.AgentSchema as ash with(nolock) on ash.IdAgentSchema = asd.IdAgentSchema
--where 1 = 1
--and pc.IdPaymentType = 6
--and ash.IdGenericStatus = 1
--and pc.IdGenericStatus = 1
--)
 
CREATE UNIQUE CLUSTERED  INDEX pktmpSchemas ON #tmpSchemas_IX (id)

--MA_008
SELECT distinct asd.IdAgentSchema, ass.IdAgent, ct.idcity INTO #Payment6_IX
FROM dbo.PayerConfig As pc WITH(NOLOCK)
INNER JOIN dbo.Payer AS p WITH(NOLOCK) ON p.IdPayer = pc.IdPayer
INNER JOIN dbo.Branch As b WITH(NOLOCK) ON b.IdPayer = p.IdPayer
INNER JOIN City ct WITH(NOLOCK) ON ct.IdCity = b.IdCity
INNER JOIN dbo.AgentSchemaDetail As asd WITH(NOLOCK) ON asd.IdPayerConfig = pc.IdPayerConfig
inner join dbo.AgentSchema As ass WITH(NOLOCK) ON ass.IdAgentSchema = asd.IdAgentSchema

--INNER JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = ass.IdCountryCurrency 
--INNER JOIN Country c WITH(NOLOCK) ON c.IdCountry = cc.IdCountry
--INNER JOIN [State] s WITH(NOLOCK) ON s.IdCountry = c.IdCountry
--INNER JOIN City ct WITH(NOLOCK) ON ct.IdState  = s.IdState

WHERE 1 = 1
AND pc.IdPaymentType = 6
AND ass.IdGenericStatus = 1
--AND pc.IdGenericStatus=1
AND p.IdGenericStatus = 1
AND b.IdGenericStatus = 1
--AND EXISTS(SELECT 1 FROM dbo.Branch AS b WITH(NOLOCK) WHERE b.IdCity = ct.IdCity)
AND EXISTS(SELECT 1 FROM #tmpSchemas_IX as us WHERE us.idAgentSchema = ass.IdAgentSchema)
--MA_008
CREATE UNIQUE CLUSTERED  INDEX IDX_Payment6_IdAgentSchema_IdAgent_idcity ON #Payment6_IX (IdAgentSchema, IdAgent, idcity)


CREATE TABLE #TmpAgtLocSer_IX (	
idAgent         INT NULL,
idAgentSchema   INT NULL,
idCountry       INT NULL,
idState         INT NULL,
idCity          INT NULL,
LocationName    VARCHAR (2000)  COLLATE SQL_Latin1_General_CP1_CI_AS NULL,
PaymentTypes    VARCHAR(200) COLLATE SQL_Latin1_General_CP1_CI_AS
)

CREATE CLUSTERED INDEX PK_TMPAGTLOCSER1 ON #TmpAgtLocSer_IX (idAgentSchema,idCity)

DECLARE @ini INT,@fin INT , @schema INT , @Agent INT  
SELECT @ini=1,@fin=count(*) FROM #tmpSchemas_IX
WHILE @ini <=@fin BEGIN 
SELECT @schema = idAgentSchema, @Agent =idAgent FROM #tmpSchemas_IX WHERE id =@ini


INSERT INTO #TmpAgtLocSer_IX (idAgent,idAgentSchema,idCountry,idState,idCity,LocationName,PaymentTypes)
SELECT a.idAgent,idAgentSchema, c.idCountry, s.IdState,ct.IdCity, upper(ct.CityName)+', '+ upper(s.StateName)+', '+upper(agts.SchemaName),
PaymentTypes=
CASE WHEN EXISTS (SELECT 1 FROM AgentSchemaDetail asd WITH(NOLOCK) INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig  WHERE asd.IdAgentSchema = agts.idAgentSchema AND pc.IdGenericStatus=1 AND pc.IdPaymentType IN(1,4)) THEN '1' ELSE '' END +
CASE WHEN EXISTS (SELECT 1 FROM AgentSchemaDetail asd WITH(NOLOCK) INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig  WHERE asd.IdAgentSchema = agts.idAgentSchema AND pc.IdGenericStatus=1 AND pc.IdPaymentType =2) THEN '2' ELSE '' END +
CASE WHEN EXISTS (SELECT 1 FROM AgentSchemaDetail asd WITH(NOLOCK) INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig  WHERE asd.IdAgentSchema = agts.idAgentSchema AND pc.IdGenericStatus=1 AND pc.IdPaymentType =3) THEN '3' ELSE '' END +
CASE WHEN EXISTS (SELECT 1 FROM AgentSchemaDetail asd WITH(NOLOCK) INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig  WHERE asd.IdAgentSchema = agts.idAgentSchema AND pc.IdGenericStatus=1 AND pc.IdPaymentType =5) THEN '5' ELSE '' END +
CASE WHEN EXISTS (SELECT 1 FROM #Payment6_IX AS p6 WHERE p6.IdAgent = a.IdAgent AND p6.IdAgentSchema = agts.IdAgentSchema AND p6.IdCity = ct.IdCity
				  /*SELECT 1 
                    FROM AgentSchemaDetail asd WITH(NOLOCK) 
					INNER JOIN PayerConfig pc WITH(NOLOCK) ON pc.IdPayerConfig = asd.IdPayerConfig
					INNER JOIN dbo.Payer As p WITH(NOLOCK) ON pc.IdPayer = p.IdPayer
					INNER JOIN dbo.Branch AS b WITH(NOLOCK) ON p.IdPayer = b.IdPayer
					INNER JOIN dbo.City AS c WITH(NOLOCK) ON c2.IdCity = c.IdCity
					WHERE asd.IdAgentSchema = agts.idAgentSchema 
					AND pc.IdGenericStatus=1 AND pc.IdPaymentType =6*/ ) 
					THEN '6' ELSE '' END 
FROM AgentSchema agts WITH(NOLOCK)
INNER JOIN Agent a WITH(NOLOCK) ON a.IdAgent = agts.IdAgent
INNER JOIN CountryCurrency cc WITH(NOLOCK) ON cc.IdCountryCurrency = agts.IdCountryCurrency 
INNER JOIN Country c WITH(NOLOCK) ON c.IdCountry = cc.IdCountry
INNER JOIN [State] s WITH(NOLOCK) ON s.IdCountry = c.IdCountry
INNER JOIN City ct WITH(NOLOCK) ON ct.IdState  = s.IdState
WHERE 
a.IdAgentStatus NOT IN (2,6)
AND agts.IdGenericStatus =1
AND agts.IdAgentSchema = @schema
AND EXISTS(SELECT 1 FROM dbo.Branch AS b WITH(NOLOCK) WHERE 1 = 1 AND b.IdCity = ct.IdCity)

SET @ini =@ini+1
END 


--Actualizadas
UPDATE X SET 
LocationName = als.LocationName, 
PaymentTypes = als.PaymentTypes,
LastUpdate = getdate()
FROM Elastic.AgentLocationSearch_NewIX X --(NOLOCK)
LEFT JOIN #TmpAgtLocSer_IX als 
ON  als.idAgent = X.idAgent 
AND als.idAgentSchema = X.idAgentSchema 
AND als.idState = X.idState  
AND als.idCity = X.idCity 
WHERE 	
X.LocationName  !=  als.LocationName OR x.PaymentTypes != als.PaymentTypes

    
--Cambio estatus a habilitadas
UPDATE X SET IdGenericStatus = 1, LastUpdate = NULL 
FROM Elastic.AgentLocationSearch_NewIX X --(NOLOCK)
LEFT JOIN #TmpAgtLocSer_IX als
ON  als.idAgent = X.idAgent 
AND als.idAgentSchema = X.idAgentSchema 
AND als.idState = X.idState  
AND als.idCity = X.idCity 
WHERE 
X.idGenericStatus = 2
AND als.idAgentSchema IS NOT NULL 


--Desactivadas
UPDATE X SET IdGenericStatus = 2, LastUpdate = getdate()
FROM Elastic.AgentLocationSearch_NewIX X --(NOLOCK)
INNER JOIN #tmpSchemas_IX ts
ON ts.idAgent = x.idAgent
AND ts.idAgentSchema = x.idAgentSchema
LEFT JOIN #TmpAgtLocSer_IX als
ON  als.idAgent = X.idAgent 
AND als.idAgentSchema = X.idAgentSchema 
AND als.idState = X.idState  
AND als.idCity = X.idCity 
WHERE X.idGenericStatus = 1
AND als.idAgentSchema IS NULL 


--Nuevas
INSERT INTO Elastic.AgentLocationSearch_NewIX(idAgent,idAgentSchema,idCountry,idState,idCity,LocationName,idGenericStatus,PaymentTypes)
SELECT als.idAgent,als.idAgentSchema,als.idCountry,als.idState,als.idCity,als.LocationName,idGenericStatus =1, als.PaymentTypes
FROM  #TmpAgtLocSer_IX als
LEFT JOIN Elastic.AgentLocationSearch_NewIX X --(NOLOCK)
ON X.idAgent = als.idAgent 
AND X.idAgentSchema = als.idAgentSchema
AND X.idState = als.idState
AND X.idCity = als.idCity
WHERE x.LastUpdate IS NULL AND x.idGenericStatus IS NULL 

		/*Valida que no existan agencias rezagadas*/
		IF EXISTS(SELECT 1 FROM Elastic.AgentLocationSearch_NewIX AS als WITH(NOLOCK) WHERE 1 = 1 AND idLocationIndex IS NULL AND LastUpdate IS NOT NULL)
		BEGIN
			UPDATE alst
			   SET @LastUpdate = null
			  FROM Elastic.AgentLocationSearch_NewIX AS alst 
		     WHERE 1 = 1 
			   AND idLocationIndex IS NULL 
			   AND LastUpdate IS NOT NULL
		END

END 



