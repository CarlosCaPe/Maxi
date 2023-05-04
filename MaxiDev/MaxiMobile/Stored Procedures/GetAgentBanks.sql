CREATE procedure [MaxiMobile].[GetAgentBanks]
(
	@idagent int
)
as
select IdAgentBankDeposit IdDepositBankAccount, BankName,AccountNumber AccountNo from AgentBankDeposit 
where IdGenericStatus=1
order by BankName

