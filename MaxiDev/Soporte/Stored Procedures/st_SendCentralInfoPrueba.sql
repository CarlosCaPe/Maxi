
CREATE PROCEDURE [Soporte].[st_SendCentralInfoPrueba]
AS
BEGIN

	DECLARE @Subject VARCHAR(200),
			@AttachmentFilename VARCHAR(200),
			@Body VARCHAR(250),
			@Query NVARCHAR(1000),
			@DateString VARCHAR(100),
			@Separator VARCHAR(10)
			

	SET @Separator = ','

	SET @DateString = FORMAT(GETDATE(), 'MMMM-yyyy');
	select @DateString
	SET @Subject = 'Central Info - ' + @DateString;
	SET @AttachmentFilename = REPLACE(@Subject, '/', '-') + '.csv';
	SET @Body = 'Attached will find the Report for '+ @DateString;
	

	SET @Query = 'SET NOCOUNT ON
	SELECT 
		''Month'', 
		''AgentState'', 
		''CountryName'', 
		''GatewayName'', 
		''IdPayer'', 
		''PayerName'',
		''#_Trans'',
		''Amount_USD''
	EXEC Soporte.st_GetCentralInfo
	';

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Stage',
		@subject = @Subject,
		@body = @Body,
		@body_format = 'TEXT',
		@recipients = 'saguilar@maxillc.com',
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
