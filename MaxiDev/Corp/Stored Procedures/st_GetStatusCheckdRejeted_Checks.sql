CREATE PROCEDURE [Corp].[st_GetStatusCheckdRejeted_Checks]
	   @DocXml XML
	AS
/********************************************************************
<Author>Amoreno</Author>
<app>MaxiAgente</app>
<Description>Optener razon de rechazo de Cheques en realcion de bancos con Maxi</Description>

<ChangeLog>

<log Date="30/05/2018" Author="amoreno">Creation</log>
<log Date="23/10/2020" Author="lchavez">Change parameters to XML and it allow to search N informtation checks </log>
<lgo Date="26/02/2021" Author="cagarcia">Ajuste en join</log>
</ChangeLog>
*********************************************************************/
	
	BEGIN
	SET NOCOUNT ON;
	
	--SET @DocXml= '<XmlDetails><Details><IdBank>2</IdBank><CheckNumber>2343222</CheckNumber><RountingNumber>065400153</RountingNumber><Account>0011112222</Account><Amount>3000.95</Amount></Details>  <Details><IdBank>2</IdBank><CheckNumber>234357</CheckNumber><RountingNumber>065400153</RountingNumber><Account>0011112222</Account><Amount>685.30</Amount></Details></XmlDetails>'

	DECLARE @DocHandle INT
	

	CREATE TABLE #CurrentXmlDetails (
		IdBank 			INT, 
		CheckNumber 	VARCHAR(50), 
		RoutingNumber	NVARCHAR(50), 
		Account 		NVARCHAR(500),
		Amount 			MONEY,
		Id 				INT,
		ReturnDate		DATETIME,
		ReturnReason	VARCHAR(500),
		Note			VARCHAR(1000),
		IsUnique		BIT,
		ISecuence		INT
		         
	)

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @DocXml
	

	INSERT #CurrentXmlDetails	
	SELECT
	IdBank,CheckNumber, rountingNumber, Account, Amount, Id, ReturnDate, ReturnReason, Note, IsUnique, ISecuence 
	FROM OPENXML (@DocHandle, '/XmlDetails/Details', 2)
	WITH (
		IdBank 			INT,
		CheckNumber 	NVARCHAR(50),
		RountingNumber	NVARCHAR(MAX),
		Account 		NVARCHAR(100),
		Amount 			MONEY,
		Id 				INT,
		ReturnDate		DATETIME,
		ReturnReason	VARCHAR(500),
		Note			VARCHAR(1000),
		IsUnique		BIT,
		ISecuence		INT
	)
	
	--SELECT * FROM #CurrentXmlDetails
	
	
	SELECT row_number() OVER (PARTITION BY CX.CheckNumber, CX.RoutingNumber, CX.Account, CX.Amount ORDER BY CX.Id) AS 'RN', * 
	INTO #tmpChecksXml
	FROM #CurrentXmlDetails CX
	
	
	SELECT C.IdCheck, 
		C.IdStatus,
		C.IdAgent,
		A.agentcode + ' '+ A.AgentName NameAgent,
		CX.Id,
		CX.ReturnDate,
		CX.ReturnReason,
		CX.Note, 
		CX.IsUnique,
		CX.CheckNumber,
		CX.RoutingNumber,
		CX.Account,
		CX.Amount,
		CX.ISecuence 
	FROM #tmpChecksXml CX
	LEFT JOIN  dbo.Checks C WITH(NOLOCK) ON CX.idBank = C.IdCheckProcessorBank 
    	AND try_convert(BIGINT,C.CheckNumber) = try_convert(BIGINT, CX.CheckNumber) 
	   	AND try_convert(BIGINT,C.RoutingNumber) = try_convert(BIGINT,CX.RoutingNumber )
	   	AND try_convert(BIGINT,C.Account) = try_convert(BIGINT,CX.Account)
	   	AND try_convert(MONEY,C.Amount) = try_convert(MONEY,CX.Amount)  
	LEFT JOIN Agent A ON A.IdAgent=C.IdAgent
	WHERE RN = 1 AND isnull(C.IsIRD, 0) = 0
	UNION
	SELECT C.IdCheck, 
		C.IdStatus,
		C.IdAgent,
		A.agentcode + ' '+ A.AgentName NameAgent,
		CX.Id,
		CX.ReturnDate,
		CX.ReturnReason,
		CX.Note, 
		CX.IsUnique,
		CX.CheckNumber,
		CX.RoutingNumber,
		CX.Account,
		CX.Amount,
		CX.ISecuence 
	FROM #tmpChecksXml CX
	LEFT JOIN  dbo.Checks C WITH(NOLOCK) ON CX.idBank = C.IdCheckProcessorBank 
    	AND try_convert(BIGINT,C.CheckNumber) = try_convert(BIGINT, CX.CheckNumber) 
	   	AND try_convert(BIGINT,C.RoutingNumber) = try_convert(BIGINT,CX.RoutingNumber )
	   	AND try_convert(BIGINT,C.Account) = try_convert(BIGINT,CX.Account)
	   	AND try_convert(MONEY,C.Amount) = try_convert(MONEY,CX.Amount)  
	LEFT JOIN Agent A ON A.IdAgent=C.IdAgent
	WHERE RN = 2 AND isnull(C.IsIRD, 0) = 1 
	ORDER BY CX.Id	

--	SELECT 
--		row_number() OVER (PARTITION BY CX.Id, CX.CheckNumber, CX.RoutingNumber, CX.Account, CX.Amount ORDER BY CX.Id, C.IdCheck) AS 'RN',
--		C.IdCheck, 
--		C.IdStatus,
--		C.IdAgent,
--		A.agentcode + ' '+ A.AgentName NameAgent,
--		CX.Id,
--		CX.ReturnDate,
--		CX.ReturnReason,
--		CX.Note, 
--		CX.IsUnique,
--		CX.CheckNumber,
--		CX.RoutingNumber,
--		CX.Account,
--		CX.Amount,
--		CX.ISecuence 
--	--INTO #tmpChecksFinal				 
--    FROM #CurrentXmlDetails CX
--    LEFT JOIN  dbo.Checks C WITH(NOLOCK) ON CX.idBank = C.IdCheckProcessorBank 
--    	AND try_convert(BIGINT,C.CheckNumber) = try_convert(BIGINT, CX.CheckNumber) 
--	   	AND try_convert(BIGINT,C.RoutingNumber) = try_convert(BIGINT,CX.RoutingNumber )
--	   	AND try_convert(BIGINT,C.Account) = try_convert(BIGINT,CX.Account)
--	   	AND try_convert(MONEY,C.Amount) = try_convert(MONEY,CX.Amount)  
--	LEFT JOIN Agent A ON A.IdAgent=C.IdAgent
	
--	
--	SELECT *
--	FROM #tmpChecksFinal
--	WHERE RN = 1
	
	DROP TABLE #CurrentXmlDetails
 
	END

