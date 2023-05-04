CREATE PROCEDURE [Corp].[st_GetAgentType]
AS  

Set nocount on;
Begin try
	Select IdAgentType, [Name] from AgentType with(nolock)
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentType]',Getdate(),@ErrorMessage);
End catch
