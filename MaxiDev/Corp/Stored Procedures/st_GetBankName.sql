CREATE PROCEDURE Corp.st_GetBankName
AS
BEGIN

/********************************************************************
<Author> Unknown </Author>
<app> Corporativo </app>
<Description> Obtiene Listado de AgentBankDeposit mas las opciones 'Bank Check' y 'Debit Card Payment' </Description>

<ChangeLog>

</ChangeLog>

*********************************************************************/


	SELECT BankName
	FROM AgentBankDeposit 
	WHERE IdGenericStatus = 1
	UNION 
	SELECT 'Bank Check'
	UNION 
	SELECT 'Debit Card Payment'
	ORDER BY BankName ASC 

END


