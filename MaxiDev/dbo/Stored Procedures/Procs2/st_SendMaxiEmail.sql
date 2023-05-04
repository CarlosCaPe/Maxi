CREATE PROCEDURE [dbo].[st_SendMaxiEmail]
(
		@Recipients				NVARCHAR(1000),
		@CopyRecipients			NVARCHAR(1000),
		@BlindCopyRecipients	NVARCHAR(1000),
		@Subject				NVARCHAR(200),
		@Title					NVARCHAR(100),
		@Description			NVARCHAR(500), 
		@FilePath				NVARCHAR(MAX),
		@HasError				BIT OUTPUT, 
		@ErrorMessage			NVARCHAR(1000) OUTPUT
)
AS
BEGIN
	SET NOCOUNT ON  

	SET @HasError=0

	DECLARE @Body NVARCHAR(MAX), 
			@Footer NVARCHAR(MAX),
			@MaxiLogoPath NVARCHAR(MAX)

	--SET @MaxiLogoPath = 'J:\Compliance\Notif\logoMaxi.png'

	SET @Body='<html>  
	<body> <H3> ' + ISNULL(@Title, '') +'  </H3>
	<p> '+ ISNULL(@Description, '') + '</p> '
 
	SET @Footer= '
	<br/>
	<br/> 
	<table>
	<tr><td valign="top" align="left"> <img src="cid:logoMaxi.png"  </td> </tr>
	</table>
	<p><span style="color:#808080"> Please do not respond to this message. This is an automated message.</span></p>
	<p><span style="color:#152e67; font-size:12px;"> CONFIDENTIALITY NOTICE: This e-mail message including the attachments, if any, is intended only for the person or entity to which it is addressed and may contain confidential and/or privileged material. Any review, use, disclosure or distribution of such confidential information without the written authorization of Maxitransfers Corp. is prohibited. If you are not the intended recipient, please contact the sender by replying this e-mail and destroy all copies of the original message. By receiving this e-mail you acknowledge that any breach by you and/or your representatives of the above provisions may entitle Maxitransfers Corp. to seek for damages. </span></p>
	<p><span style="color:#85c226; font-size:12px;"> Please consider the environment before printing this email. </span></p>
	</body> </html>
	'

	SET @Body= @Body + @Footer

	IF ISNULL(@MaxiLogoPath, '') <> ''
	BEGIN
		IF ISNULL(@FilePath, '') <> ''
			SET @FilePath = CONCAT(@FilePath, ';', @MaxiLogoPath);
		ELSE
			SET @FilePath = @MaxiLogoPath
	END

	BEGIN TRY
		EXEC msdb.dbo.sp_send_dbmail  
			@profile_name = 'Stage', 
			@recipients = @Recipients,
			@copy_recipients = @CopyRecipients,
			@blind_copy_recipients = @BlindCopyRecipients,
			@subject = @Subject,
			@body = @Body,
			@body_format = 'HTML',
			@file_attachments = @FilePath
	END TRY
	BEGIN CATCH
		SET @HasError=1
		SET @ErrorMessage = CONCAT('LINE ', ERROR_LINE(), ' ERROR: ', ERROR_MESSAGE()) 
	END CATCH
END