CREATE PROCEDURE [dbo].[st_AgentToSendReportExRates]
(
	@IdAgent int = null
)
AS    
--Set nocount on

/*Quitar en produccion*/
/*--------------------*/
--Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
--	Values('st_AgentToSendReportExRates',Getdate(),'Parameters:IdAgent=' + CONVERT(VARCHAR(25),ISNULL(@IdAgent,'')));
/*--------------------*/

Begin try

	Select 
		IdAgent
		,AgentCode
		,AgentName
		,AgentFax
		,ExcludeReportExRates
		, IDAgentCommunication
	From Agent WITH(NOLOCK)
	Where IdAgentStatus=1
		and (IdAgent = ISNULL(@IdAgent,IdAgent));

End try
Begin Catch    
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentToSendReportExRates',Getdate(),@ErrorMessage);
End catch
