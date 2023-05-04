CREATE procedure [dbo].[st_SendMail]                         
@body nvarchar(max),                        
@subject nvarchar (max)                        
as                        
                        
Declare @recipients nvarchar (max)                        
Declare @EmailProfile nvarchar(max)    
Select @recipients=Value from GLOBALATTRIBUTES where Name='ListEmailErrors'  
Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'  
    
           
 EXEC msdb.dbo.sp_send_dbmail                          
 @profile_name=@EmailProfile,                                                     
 @recipients = @recipients,                                                          
 @body = @body,                                                           
 @subject = @subject
