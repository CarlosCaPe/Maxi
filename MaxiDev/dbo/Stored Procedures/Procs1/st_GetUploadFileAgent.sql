-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-11-09
-- Description:	Get Documents information from Agent system request
-- =============================================
-- Author:		Miguel Prado
-- Create date: 2022-Aug-02
-- Description:	Change Prevention of money laundering Docs to AML Diploma
-- =============================================
CREATE PROCEDURE [dbo].[st_GetUploadFileAgent]
	-- Add the parameters for the stored procedure here
	@AgentId INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Create Temp Table to save Docs
	DROP TABLE IF EXISTS  #EmpDetails;
	CREATE TABLE #EmpDetails(
		IdUploadFile	INT,
		Name			NVARCHAR(MAX),
		NameEs			NVARCHAR(MAX),
		WebUri			NVARCHAR(MAX),
		ImagePath		NVARCHAR(MAX),
		NameDocType		NVARCHAR(MAX));
    -- Insert statements for procedure here
	
	DECLARE @DownloadHandler NVARCHAR(MAX) = [dbo].[GetGlobalAttributeByName] ('DownloadHandler')
	DECLARE @FromFiscalYear INT

	--INSERT DOCS WITH NOT RANGE DATE RESTRICT
	INSERT INTO #EmpDetails
	SELECT
		[U].[IdUploadFile],
		[dbo].[GetMessageFromMultiLenguajeResorces](1,'DocType' + ISNULL(CONVERT(NVARCHAR(MAX),[DT].[IdDocumentType]),'')) Name,
		[dbo].[GetMessageFromMultiLenguajeResorces](2,'DocType' + ISNULL(CONVERT(NVARCHAR(MAX),[DT].[IdDocumentType]),'')) NameEs,
		@DownloadHandler + '?resourceType=5&fileName=' + [U].[FileGuid] + [U].[Extension] + '&Id=Agents/' + CONVERT(NVARCHAR(MAX),@AgentId) WebUri,
		'pack://application:,,,/MaxiFrontOffice.Infrastructure;component/Resources/Document.png' ImagePath,
		[DT].[Name]
	FROM [dbo].[UploadFiles] [U] WITH (NOLOCK)
	JOIN [dbo].[DocumentTypes] [DT] WITH (NOLOCK) ON [U].[IdDocumentType] = [DT].[IdDocumentType]
	WHERE
		[U].[IdReference] =  @AgentId
		AND [DT].[IdDocumentType] IN (11,20)
		AND [U].[IdStatus] = 1

	--INSERT DOCS WITH RESTRICT RANGE DATE
	INSERT INTO #EmpDetails
	SELECT
		[U].[IdUploadFile],
		[dbo].[GetMessageFromMultiLenguajeResorces](1,'DocType' + ISNULL(CONVERT(NVARCHAR(MAX),[DT].[IdDocumentType]),'')) Name,
		[dbo].[GetMessageFromMultiLenguajeResorces](2,'DocType' + ISNULL(CONVERT(NVARCHAR(MAX),[DT].[IdDocumentType]),'')) NameEs,
		@DownloadHandler + '?resourceType=5&fileName=' + [U].[FileGuid] + [U].[Extension] + '&Id=Agents/' + CONVERT(NVARCHAR(MAX),@AgentId) WebUri,
		'pack://application:,,,/MaxiFrontOffice.Infrastructure;component/Resources/Document.png' ImagePath,
		[DT].[Name]
	FROM [dbo].[UploadFiles] [U] WITH (NOLOCK)
	JOIN [dbo].[DocumentTypes] [DT] WITH (NOLOCK) ON [U].[IdDocumentType] = [DT].[IdDocumentType]
	WHERE
		[U].[IdReference] =  @AgentId
		AND [DT].[IdDocumentType] IN (143)
		AND [U].[IdStatus] = 1
		AND YEAR([U].[CreationDate]) >= YEAR(DATEADD(YEAR, -1, GETDATE()))

	SELECT IdUploadFile,
		Name,
		NameEs,
		WebUri,
		ImagePath
	FROM #EmpDetails
	ORDER BY  NameDocType ASC;

	DROP TABLE IF EXISTS  #EmpDetails;
END
