/********************************************************************
<Author> DAlmeida </Author>
<app>Corporate </app>
<Description> Consulta </Description>

<ChangeLog>
<log Date="09/13/2017" Author="DAlmeida">Create</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
CREATE PROCEDURE [CheckConfig].[st_getBank]
as
select IdBank,BankName from CheckConfig.Bank with(nolock) where IdGenericStatus=1
