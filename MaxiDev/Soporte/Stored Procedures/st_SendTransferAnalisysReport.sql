CREATE PROCEDURE Soporte.st_SendTransferAnalisysReport
(
	@IdStatus		INT,
	@DateFrom		DATE,
	@DateTo			DATE,
	@Recipients		VARCHAR(500)
)
AS
BEGIN
	DECLARE @Subject VARCHAR(200),
			@AttachmentFilename VARCHAR(200),
			@Body VARCHAR(250),
			@Query NVARCHAR(1000),
			@QueryColumns NVARCHAR(1000),
			@QueryReport NVARCHAR(1000),
			@Separator VARCHAR(10),
			@ColumnMain VARCHAR(255),
			@ReportName	VARCHAR(200)

	SET @Separator = ','
	SET @ColumnMain = 'sep=' + @Separator + CHAR(13) + CHAR(10) + 'Date Of Transfer'


	SET @QueryColumns = 'SET NOCOUNT ON
	SELECT
		''' + @ColumnMain + ''', 
		''Folio'',
		''Agent #'',
		''AgentName'',
		''Amount'',
		''Amount in MN'',
		''Payment Type'',
		''Sender'',
		''Beneficiary'',
		''Status'',
		''Date of Last Status Change'',
		''Payer'',
		''Gateway'',
		''Country'',
		''Currency''
	';

	SELECT TOP 1
		@ReportName = CONCAT('Report ', s.StatusName, ' (', FORMAT(@DateFrom, 'MMddyyyy'), '-', FORMAT(@DateTo, 'MMddyyyy'), ')')
	FROM Status s WITH(NOLOCK)
	WHERE s.IdStatus = @IdStatus

	SET @AttachmentFilename = REPLACE(@ReportName, '/', '-') + '.csv';

	SET @QueryReport = CONCAT('EXEC Soporte.st_GetTransferAnalisysReport ', @IdStatus, ', ''', @DateFrom, '''', ', ''',  @DateTo, '''')
	SET @Query = CONCAT(@QueryColumns, CHAR(13) + CHAR(10), @QueryReport)
	SET @Body =  CONCAT(
		'Attached will find the Report for ', 
		CHAR(13) + CHAR(10), 
		@ReportName, 
		CHAR(13) + CHAR(10),
		'Date from: ', @DateFrom,
		CHAR(13) + CHAR(10),
		'Date to: ', @DateTo,
		CHAR(13) + CHAR(10)
	);

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Stage',
		@subject = @ReportName,
		@body = @Body,
		@body_format = 'TEXT',
		@recipients = @Recipients,
		@execute_query_database = 'MAXI',
		@query = @Query,
		@query_result_header = 0,
		@query_attachment_filename = @AttachmentFilename,
		@query_result_separator = @Separator, 
		@attach_query_result_as_file = 1,
		@exclude_query_output = 1, 
		@query_result_no_padding = 1,
		@query_result_width = 32767
END