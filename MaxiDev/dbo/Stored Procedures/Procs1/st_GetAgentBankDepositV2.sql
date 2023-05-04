CREATE procedure [dbo].[st_GetAgentBankDepositV2]
as
begin
SELECT [IdAgentBankDeposit], [BankName], [IdGenericStatus]
    FROM [dbo].[AgentBankDeposit] WITH (NOLOCK)

	end
