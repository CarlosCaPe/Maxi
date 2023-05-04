CREATE PROCEDURE [Corp].[st_getBank_CheckConfig]
as
select IdBank,BankName from CheckConfig.Bank where IdGenericStatus=1

