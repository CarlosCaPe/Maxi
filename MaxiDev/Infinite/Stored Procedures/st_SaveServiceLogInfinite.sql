-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-12-03
-- Description:	Save logs for infinite service request
-- =============================================
/********************************************************************
<Author>Not Known</Author>
<app>-</app>
<Description></Description>

<ChangeLog>
<log Date="27/06/2018" Author="azavala">Add columns insert EmailCellularLog</log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [Infinite].[st_SaveServiceLogInfinite]
	-- Add the parameters for the stored procedure here
	@TransactionID BIGINT,
    @IsSuccess BIT,
    @Response NVARCHAR(MAX) = NULL,
    @Request NVARCHAR(MAX) = NULL,
    @HasError BIT OUTPUT
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @Subject NVARCHAR(MAX)
	DECLARE @Body NVARCHAR(MAX)
	DECLARE @Salto NVARCHAR(MAX) = CHAR(13)+CHAR(10)

    INSERT INTO [Infinite].[ServiceLogInfinite]
           ([Request]
           ,[Response]
           ,[IsSuccess]
           ,[TransactionID]
           ,[DateLastChange])
     VALUES
           (@Request
           ,@Response
           ,@IsSuccess
           ,@TransactionID
           ,GETDATE())

	SET @HasError = 0

	IF @IsSuccess = 1
		RETURN

	SET @Subject = 'Infinite error in TransactionID: ' + CONVERT(NVARCHAR(MAX), @TransactionID)
    SET @Body = @Subject
				+ @Salto + @Salto + 'Infinite Request:' + @Salto + @Salto + @Request
				+ @Salto + @Salto + 'Maxi Response:' + @Salto + @Salto + @Response
        
    DECLARE @recipients NVARCHAR(MAX)
    DECLARE @EmailProfile NVARCHAR(MAX)

    SELECT @recipients = [Value] FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'ListEmailErrorsInfinite'
    SELECT @EmailProfile = [Value] FROM [dbo].[GlobalAttributes] WITH (NOLOCK) WHERE [Name] = 'EmailProfiler'
    
           
    EXEC msdb.dbo.sp_send_dbmail                          
        @profile_name=@EmailProfile,                                                     
        @recipients = @recipients,                                                          
        @body = @Body,                                                           
        @subject = @Subject

	INSERT INTO [dbo].[EmailCellularLog] (Number,Body,[Subject],[DateOfMessage]) VALUES (@recipients,@Body,@Subject,GETDATE())

END TRY
BEGIN CATCH
	SET @HasError=1                                                                                     
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @ErrorLine NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	SELECT @ErrorLine = CONVERT(VARCHAR(20), ERROR_LINE())
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('Infinite.st_SaveServiceLogInfinite', GETDATE(), 'Line: ' + @ErrorLine + ', ' + @ErrorMessage)
END CATCH
