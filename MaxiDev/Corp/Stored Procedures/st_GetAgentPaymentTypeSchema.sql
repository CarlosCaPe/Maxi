CREATE PROCEDURE [Corp].[st_GetAgentPaymentTypeSchema]
AS  

Set nocount on;
Begin try
	Select IdAgentPaymentSchema, PaymentName from AgentPaymentSchema with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentPaymentTypeSchema]',Getdate(),@ErrorMessage);
End catch
