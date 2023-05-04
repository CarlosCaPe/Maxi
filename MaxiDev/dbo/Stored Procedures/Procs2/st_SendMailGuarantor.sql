CREATE procedure [dbo].[st_SendMailGuarantor]
(
	@IdUserSeller int,
	@Note nvarchar(max),
	@subjectMail nvarchar(max),
	@IdAgentApplication int
)
as		
		Declare @EmailProfile nvarchar(max)
		Declare @recipients nvarchar (max)
		set @subjectMail += ' Alert - '

		Select @EmailProfile = Value from GLOBALATTRIBUTES where Name='EmailProfiler'  
		Select @subjectMail += AgentCode from AgentApplications where IdAgentApplication=@IdAgentApplication
		
		set @recipients = 'cob@maxi-ms.com;newagents@maxi-ms.com;'
		select @recipients += Email from Seller where IdUserSeller = @IdUserSeller

		--set @recipients = '' -- comentar en Producción - habilitar linea de arriba
		
		if (@recipients is not null and @recipients != '')
		begin 
			set @Note = replace(@Note, '\n', char(13))
			EXEC msdb.dbo.sp_send_dbmail
			@profile_name = @EmailProfile,                                                       
			@recipients = @recipients,                                                            
			@body = @Note,                                                             
			@subject = @subjectMail
		end