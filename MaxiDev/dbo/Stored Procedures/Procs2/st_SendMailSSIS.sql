
CREATE procedure [dbo].[st_SendMailSSIS]                         
	@MailType int
as                        
                        
DECLARE @ProcID VARCHAR(200)
SET @ProcID =OBJECT_NAME(@@PROCID)

DECLARE @recipients NVARCHAR(MAX)
DECLARE @subject NVARCHAR(MAX)
DECLARE @body NVARCHAR(MAX)

Select @recipients=Value from GLOBALATTRIBUTES where Name='ListEmailErrors' 
SET @recipients = 'soportemaxi@BOZ.MX'

select @subject=subject, @body=body from [SSISConfigMail] where [IdSSISConfigMail]=@MailType

if @subject is null return

print 'Send Mail'

	EXEC sp_MailQueue 
			@Source   =  @ProcID,
			@To 	  =  @recipients,      
			@Subject  =  @subject,
			@Body  	  =  @body
