CREATE PROCEDURE [Corp].[st_getBankAccount_CheckConfig]
	@IdBank int,
	@IdAgent int
as
declare @IdState int = 0
declare @StateCode nvarchar(50)

select @StateCode = StateCode from agent where IdAgent = @IdAgent

select @IdState=IdState from state where StateCode=@StateCode and IdCountry=18

select IdBankAccount,BankAccountName,IsEnableOtherAccount from CheckConfig.BankAccount where IdGenericStatus=1 and IdBank=@IdBank and IdState is null
union
select IdBankAccount,BankAccountName,IsEnableOtherAccount from CheckConfig.BankAccount where IdGenericStatus=1 and IdBank=@IdBank and IdState = @IdState

