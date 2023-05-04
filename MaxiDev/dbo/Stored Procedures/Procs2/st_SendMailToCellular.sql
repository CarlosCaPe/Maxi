/********************************************************************
<Author>Not Known</Author>
<app>-</app>
<Description></Description>

<ChangeLog>
<log Date="27/06/2018" Author="azavala">Add columns insert EmailCellularLog</log>
</ChangeLog>
********************************************************************/
CREATE procedure [dbo].[st_SendMailToCellular]                         
@FullEmail nvarchar(max),                        
@IdStatus int,
@IdPaymentType int,
@ClaimCode nvarchar(max)                        
as                        
                        
Declare @EmailProfile nvarchar(max),@SubjectMessage nvarchar(max),@BodyMessage nvarchar(max)    
Select @EmailProfile=dbo.GetGlobalAttributeByName('EmailProfiler')

Select @SubjectMessage=SubjectMessage+ ' '+ @ClaimCode,@BodyMessage=BodyMessage from  StatusToSendCellularMsg (nolock) where IdStatus=@IdStatus And IdPaymentType=@IdPaymentType

--select GETDATE()--2016-01-26 10:40:01.617	           
 --EXEC msdb.dbo.sp_send_dbmail                          
 --@profile_name=@EmailProfile,                                                     
 --@recipients = @FullEmail,                                                          
 --@body = @BodyMessage,                                                           
 --@subject = @SubjectMessage 

 Insert into EmailCellularLog (Number,Body,[Subject],[DateOfMessage]) values(@FullEmail,@BodyMessage,@SubjectMessage,GETDATE())

