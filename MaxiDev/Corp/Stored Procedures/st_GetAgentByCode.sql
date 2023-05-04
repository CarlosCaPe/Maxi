CREATE PROCEDURE [Corp].[st_GetAgentByCode]
@AgentCode nvarchar(max)
as
SET NOCOUNT ON;
begin try
    SELECT IdAgent, AgentCode, AgentName, IdAgentBankDeposit, SubAccount, AgentState
	FROM Agent with (nolock) where AgentCode=@AgentCode
end try
begin catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetAgentByCode]',Getdate(),@ErrorMessage);
end catch

