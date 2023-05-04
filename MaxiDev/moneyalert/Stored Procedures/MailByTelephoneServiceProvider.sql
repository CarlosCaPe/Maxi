
-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-08-03
-- Description:	Send Money Alert Invitation by Telephone Service Provider
-- =============================================
/********************************************************************
<Author>Not Known</Author>
<app>-</app>
<Description></Description>

<ChangeLog>
<log Date="27/06/2018" Author="azavala">Add columns insert EmailCellularLog</log>
</ChangeLog>
********************************************************************/
CREATE PROCEDURE [moneyalert].[MailByTelephoneServiceProvider]
	-- Add the parameters for the stored procedure here
	@FullEmail NVARCHAR(MAX),
	@SubjectMessage NVARCHAR(MAX),
	@BodyMessage NVARCHAR(MAX)

AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @EmailProfile NVARCHAR(MAX)
	SELECT @EmailProfile=dbo.GetGlobalAttributeByName('EmailProfiler')

	EXEC msdb.dbo.sp_send_dbmail
	 @profile_name=@EmailProfile,
	 @recipients = @FullEmail,
	 @body = @BodyMessage,
	 @subject = @SubjectMessage

	INSERT INTO [dbo].[EmailCellularLog] (Number,Body,[Subject],[DateOfMessage]) VALUES (@FullEmail,@BodyMessage,@SubjectMessage,GETDATE())

END TRY
BEGIN CATCH
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH

