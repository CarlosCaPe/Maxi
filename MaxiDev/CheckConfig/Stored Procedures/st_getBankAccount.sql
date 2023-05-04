
CREATE PROCEDURE [CheckConfig].[st_getBankAccount]
	@IdBank int,
	@IdAgent int
as
/********************************************************************
<Author> ???? </Author>
<app>Corporate </app>
<Description> Obtiene las cuentas por banco</Description>

<ChangeLog>
<log Date="09/13/2017" Author="DAlmeida">Change parameter to Int</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
declare @IdState int = 0
declare @StateCode nvarchar(50)

select @StateCode = StateCode from agent with(nolock) where IdAgent = @IdAgent

select @IdState=IdState from [state]  with(nolock) where StateCode=@StateCode and IdCountry=18

select IdBankAccount,BankAccountName,IsEnableOtherAccount from CheckConfig.BankAccount with(nolock) where IdGenericStatus=1 and IdBank=@IdBank and IdState is null
union
select IdBankAccount,BankAccountName,IsEnableOtherAccount from CheckConfig.BankAccount with(nolock) where IdGenericStatus=1 and IdBank=@IdBank and IdState = @IdState

