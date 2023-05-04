CREATE PROCEDURE  [Corp].[st_GetPendingAgentScannerProcessFile] 
	@from datetime,
	@to DATETIME,
	@Page		INT = 1,
	@PageSize	INT,
	@TotalRows	INT OUTPUT
	as
BEGIN

	SET NOCOUNT ON;
	
	DECLARE @fromRow INT
	SET @fromRow = @PageSize * (@Page - 1)
	
	SELECT
	   SPF.[IdScannerProcessFiles]
	  ,A.[AgentCode]
	  ,A.[AgentName]
	  ,SPF.[Amount]
	  ,SPF.[BankName]
	  ,SPF.[DepositDate]
	  ,CONCAT( UF.[FileGuid],UF.[Extension]) AS FullName
	  ,UF.[CreationDate] AS LastWriteTime
	  ,SPF.[IdAgent]
	  ,AC.[Name] as AgentClass
	FROM [dbo].[ScannerProcessFile] SPF WITH (nolock), [dbo].[UploadFiles] UF WITH (nolock), [dbo].[Agent] A WITH (nolock), [dbo].[AgentClass]  AC WITH (nolock)
	WHERE [IsProcessed]= 0
	AND SPF.[CreationDate] BETWEEN @from AND @to 
	AND UF.[IdUploadFile]=SPF.[IdUploadFile]
	AND SPF.[IdAgent]=A.[IdAgent]
	AND A.[IdAgentClass]=AC.[IdAgentClass]
	ORDER BY SPF.[DepositDate] DESC
	OFFSET (@fromRow) ROWS
	FETCH NEXT @PageSize ROWS ONLY
	
	SELECT @TotalRows = count(1)
	FROM [dbo].[ScannerProcessFile] SPF WITH (nolock), [dbo].[UploadFiles] UF WITH (nolock), [dbo].[Agent] A WITH (nolock), [dbo].[AgentClass]  AC WITH (nolock)
	WHERE [IsProcessed]= 0
	AND SPF.[CreationDate] BETWEEN @from AND @to 
	AND UF.[IdUploadFile]=SPF.[IdUploadFile]
	AND SPF.[IdAgent]=A.[IdAgent]
	AND A.[IdAgentClass]=AC.[IdAgentClass]

END
--'2018/12/12'--'2018/02/02'

