
CREATE PROCEDURE [Soporte].[sp_SendCentralInfoReport]
AS
BEGIN

	DECLARE @Subject VARCHAR(200),
			@AttachmentFilename VARCHAR(200),
			@Body VARCHAR(250),
			@Query NVARCHAR(1000),
			@DateString VARCHAR(100),
			@Separator VARCHAR(10),
			@ColumnMain VARCHAR(255)

	SET @Separator = ','

	SET @DateString = FORMAT(GETDATE(), 'MMMM-yyyy');
	SET @Subject = 'Central Info - ' + @DateString;
	SET @AttachmentFilename = REPLACE(@Subject, '/', '-') + '.csv';
	SET @Body = 'Attached will find the Report for '+ @DateString;
	SET @ColumnMain = 'sep=' + @Separator + CHAR(13) + CHAR(10)+'Month'

	SET @Query = 'SET NOCOUNT ON
	SELECT 
		''' + @ColumnMain + ''', 
		''AgentState'', 
		''CountryName'', 
		''GatewayName'', 
		''IdPayer'', 
		''PayerName'',
		''PaymentName'',
		''#_Trans'',
		''Amount_USD''
	EXEC Soporte.sp_GetCentralInfo
	';

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Stage',
		@subject = @Subject,
		@body = @Body,
		@body_format = 'TEXT',
		@recipients = 'saguilar@maxillc.com;mmendoza@maxillc.com;jcgonzalez@maxillc.com',
		@execute_query_database = 'MAXI',
		@query = @Query,
		@query_result_header = 0,
		@query_attachment_filename = @AttachmentFilename,
		@query_result_separator = @Separator, 
		@attach_query_result_as_file = 1,
		@exclude_query_output = 1, 
		@query_result_no_padding = 1,
		@query_result_width = 1000
END
