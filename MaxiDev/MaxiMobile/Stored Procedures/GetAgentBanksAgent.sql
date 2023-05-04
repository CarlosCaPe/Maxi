/********************************************************************
<Author> Luis Antonio Lopez </Author>
<app> WebApi </app>
<Description> Sp para optener el banco del agente del usuario </Description>

*********************************************************************/
Create procedure [MaxiMobile].[GetAgentBanksAgent]
(
	@idagent int
)
as
Declare @IdAgenteBankDepositoTemp Int
select @IdAgenteBankDepositoTemp = IdAgentBankDeposit from Agent with (nolock) where IdAgent = @idagent
select IdAgentBankDeposit as IdDepositBankAccount, BankName,AccountNumber as AccountNo from AgentBankDeposit with (nolock) where IdAgentBankDeposit= @IdAgenteBankDepositoTemp
