CREATE PROCEDURE [Corp].[st_GetAgent_AuditDocuments]
	@IdUser				INT,
	@IdState			INT,
	@IdAgentStatusXml	XML,
	@IdDocTypesXml		XML
AS
BEGIN

	DECLARE @DocHandleAgentStatus	INT,
			@DocHandleDocTypes		INT,
			@StateCode				VARCHAR(5)

	CREATE TABLE #XmlIdDocTypes (
		IdDocumentType	INT
	)
	
	CREATE TABLE #XmlIdAgentStatus (
		IdAgentStatus	INT
	)
	
	SELECT @StateCode = StateCode FROM State WHERE IdState = @IdState
	
	
	EXEC sp_xml_preparedocument @DocHandleDocTypes output, @IdDocTypesXml
		
	INSERT INTO #XmlIdDocTypes
	SELECT IdDocumentType
	FROM OPENXML (@DocHandleDocTypes, '/Main/DocumentTypes', 2)
	WITH (
		IdDocumentType INT
	)
	
	
	EXEC sp_xml_preparedocument @DocHandleAgentStatus output, @IdAgentStatusXml
		
	INSERT INTO #XmlIdAgentStatus
	SELECT IdAgentStatus
	FROM OPENXML (@DocHandleAgentStatus, '/Main/AgentStatus', 2)
	WITH (
		IdAgentStatus INT
	)  

	
	SELECT A.AgentCode + ' ' + ltrim(rtrim(A.AgentName)) + ', Agent Status: ' + AST.AgentStatus AS 'Agent', 
		A.IdAgent, 
		A.AgentCode, 
		A.AgentName, 
		F.IdDocumentType, 
		Dt.Name AS 'DocumentType', 
		(DT.Name + F.Extension) AS 'FileName', 
		F.FileGuid,
		F.Extension
	FROM Agent A WITH(NOLOCK) INNER JOIN
		UploadFiles F WITH(NOLOCK) ON F.IdReference = A.IdAgent JOIN
		DocumentTypes DT WITH(NOLOCK) ON DT.IdDocumentType = F.IdDocumentType JOIN
		AgentStatus AST WITH(NOLOCK) ON AST.IdAgentStatus = A.IdAgentStatus JOIN
		#XmlIdDocTypes DT2 ON DT2.IdDocumentType = DT.IdDocumentType JOIN 
		#XmlIdAgentStatus S ON S.IdAgentStatus = A.IdAgentStatus
	WHERE A.AgentState = @StateCode
		AND DT.IdType = 2
	ORDER BY A.AgentCode
	
	IF OBJECT_ID('tempdb..#XmlIdDocTypes') IS NOT NULL
		DROP TABLE #XmlIdDocTypes

	IF OBJECT_ID('tempdb..#XmlIdAgentStatus') IS NOT NULL
		DROP TABLE #XmlIdAgentStatus

END
