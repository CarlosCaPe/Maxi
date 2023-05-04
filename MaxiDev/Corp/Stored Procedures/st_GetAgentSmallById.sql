CREATE procedure [Corp].[st_GetAgentSmallById]
@idAgent int
as
begin try
    SELECT AgentCode, IdAgent, AgentState + ', ' + AgentCity + ', ' + AgentAddress + ', ' + AgentZipcode as [Location], AgentName
	FROM Agent with (nolock) where IdAgent=@idAgent
end try
begin catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentSmallById]',Getdate(),@ErrorMessage);
end catch
