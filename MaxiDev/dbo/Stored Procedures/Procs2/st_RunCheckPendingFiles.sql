CREATE procedure [dbo].[st_RunCheckPendingFiles]
/********************************************************************
<Author>Not Known</Author>
<app>MaxiJobs</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as
BEGIN TRY
	declare @Id int
	declare @idAgent int
	declare @AgentPendingFilesTemp table
	(
		Id int not null IDENTITY(1,1), 
		IdAgent int
	)

	-- Agencias ---
	insert into @AgentPendingFilesTemp select IdAgent from PendingFilesAgent with(nolock) where IdGenericStatus = 1 and IsUpload = 0 group by IdAgent

	--while (select count(*) from @AgentPendingFilesTemp) > 0
	while EXISTS(select 1 from @AgentPendingFilesTemp)
	begin 
		select top 1 @Id = p.Id, @idAgent = p.IdAgent from @AgentPendingFilesTemp p;
		exec st_CheckPendingFiles @idAgent, 0;
		delete from @AgentPendingFilesTemp where Id = @Id;
	end
	
	-- Agent Application --
	insert into @AgentPendingFilesTemp select IdAgentApplication from PendingFilesAgentApp with(nolock) where IdGenericStatus = 1 and IsUpload = 0 group by IdAgentApplication

	--while (select count(*) from @AgentPendingFilesTemp) > 0
	while EXISTS(select 1 from @AgentPendingFilesTemp)
	begin 
		select top 1 @Id = p.Id, @idAgent = p.IdAgent from @AgentPendingFilesTemp p;
		exec st_CheckPendingFiles @idAgent, 1;
		delete from @AgentPendingFilesTemp where Id = @Id;
	end

--exec st_RunCheckPendingFiles

END TRY
BEGIN CATCH
	declare @ErrorMessage varchar(max)
	Select @ErrorMessage=ERROR_MESSAGE()      
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_RunCheckPendingFiles',Getdate(),@ErrorMessage)   
END CATCH