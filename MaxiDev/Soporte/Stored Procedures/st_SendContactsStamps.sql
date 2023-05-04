CREATE PROCEDURE Soporte.st_SendContactsStamps
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

	SET @DateString = FORMAT(GETDATE(), 'MMMM dd');

	SET @Subject = 'CONTACTOS STAMPS - ' + @DateString;
	SET @AttachmentFilename = REPLACE(@Subject, '/', '-') + '.csv';
	SET @Body = 'Attached will find the Report for '+ @DateString;
	SET @ColumnMain = 'sep=' + @Separator + CHAR(13) + CHAR(10) + 'Name'

	SET @Query = 'SET NOCOUNT ON
	SELECT 
		''' + @ColumnMain + ''', 
		''Last Name'', 
		''Company'', 
		''Address'', 
		''City'', 
		''State'', 
		''ZIP Code''
	EXEC Soporte.st_GetContactsStamps
	';

	EXEC msdb.dbo.sp_send_dbmail
		@profile_name = 'Stage',
		@subject = @Subject,
		@body = @Body,
		@body_format = 'TEXT',
		@recipients = 'jcsierra@maxi-ms.com',
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