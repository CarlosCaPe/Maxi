CREATE PROCEDURE [Corp].[st_GetAgentReceiptType]
AS  

Set nocount on;
Begin try
	Select IdAgentReceiptType, [Name] from AgentReceiptType with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentReceiptType]',Getdate(),@ErrorMessage);
End catch
