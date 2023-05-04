/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="05/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetAgentPaymentTypeSchema]
AS  

Set nocount on;
Begin try
	Select IdAgentPaymentSchema, PaymentName from AgentPaymentSchema with(nolock)

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAgentPaymentTypeSchema',Getdate(),@ErrorMessage);
End catch
