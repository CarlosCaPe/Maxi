CREATE PROCEDURE [Corp].[st_GetAgentReasonClose]
AS  

Set nocount on;
Begin try
	Select IdReasonClose, IdAgentCategoryClose, [Description] from AgentReasonClose with(nolock)
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentReasonClose]',Getdate(),@ErrorMessage);
End catch
