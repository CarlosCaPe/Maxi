/***********************************************
<Author> Alexis Zavala </Author>
<app> Elastic Search </app>
<Description>Obtiene los Customers para insertarlos dentro de ElasticSearch (WebApi)</Description>

<ChangeLog>
	<log Date="18/01/2018" Author="azavala">Creacion</log>
	<log Date="06/03/2018" Author="jmmolina">Se agrega validación en la extracción de customer</log>
</ChangeLog>
************************************************/
CREATE PROCEDURE [Elastic].[st_ElasticCustomers_New]
AS
BEGIN try
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
    -- Insert statements for procedure here
	IF OBJECT_ID('tempdb..#ElasticCustomer') IS NOT NULL DROP TABLE #ElasticCustomer
	CREATE TABLE #ElasticCustomer (IdCustomer int)

	INSERT INTO #ElasticCustomer(IdCustomer)
	SELECT TOP(10000) IdCustomer
	FROM (
	      SELECT DISTINCT IdCustomer 
	        FROM Elastic.Customers WITH(NOLOCK) 
	       WHERE 1 = 1
	         AND idElasticCustomer IS NULL
	         AND lastUpdate IS NULL
	) AS t

	--CREATE INDEX IX_ElasticCustomer_idCustomer ON #ElasticCustomer(IdCustomer) 
	--WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, DROP_EXISTING = OFF, ONLINE = ON, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

	UPDATE c
	   SET lastUpdate = GETDATE()
	  FROM Elastic.Customers AS c
	 WHERE 1 = 1
	   AND EXISTS(SELECT 1 
	                FROM #ElasticCustomer AS ec WITH(NOLOCK)
	               WHERE 1 = 1 AND ec.IdCustomer = c.IdCustomer)
	
	SELECT IdCustomer, Name, FirstLastName, SecondLastName, City, [State], Country, [Address], IdAgent, CardNumber, CelullarNumber, CelullarToShow, PhoneNumber, PhoneToShow, SearchString, idElasticCustomer, [Status], lastUpdate
	  FROM Elastic.Customers  AS c WITH(NOLOCK) 
	 WHERE 1 = 1
	   AND EXISTS(SELECT 1 FROM #ElasticCustomer AS ec WITH(NOLOCK) WHERE 1 = 1 AND ec.IdCustomer = c.IdCustomer)

	IF OBJECT_ID('tempdb..#ElasticCustomer') IS NOT NULL DROP TABLE #ElasticCustomer
END try
BEGIN CATCH
	Select null
	IF OBJECT_ID('tempdb..#ElasticCustomer') IS NOT NULL DROP TABLE #ElasticCustomer
END CATCH
