CREATE PROCEDURE [Corp].[st_GetAgentCommunication]
AS  

Set nocount on;
Begin try
	Select IdAgentCommunication, Communication from AgentCommunication with(nolock)
End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentCommunication]',Getdate(),@ErrorMessage);
End catch
