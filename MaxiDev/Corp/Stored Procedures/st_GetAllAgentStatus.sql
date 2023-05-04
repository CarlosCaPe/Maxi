CREATE PROCEDURE [Corp].[st_GetAllAgentStatus]
	@Visible bit = null
AS  
Set nocount on;
Begin try
	Select IdAgentStatus, AgentStatus from AgentStatus with(nolock) where VisibleForUser = ISNULL(@Visible,VisibleForUser)
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetAgentType',Getdate(),@ErrorMessage);
End catch
