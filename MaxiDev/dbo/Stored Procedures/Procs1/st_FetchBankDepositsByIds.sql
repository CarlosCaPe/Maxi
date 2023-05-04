CREATE PROCEDURE st_FetchBankDepositsByIds
(
	@IdsBankDeposit				XML
)
AS
BEGIN	
	WITH IdRecords (Id)
	AS ( SELECT t.c.value('.[1]', 'int') Id FROM @IdsBankDeposit.nodes('/root/Id') t(c))
	SELECT 
		bd.*
	FROM IdRecords ir
		JOIN BankDeposit bd WITH(NOLOCK) ON bd.IdBankDeposit = ir.Id
	WHERE
		NOT EXISTS (SELECT 1 FROM ConciliationMatch cm WITH(NOLOCK) WHERE cm.IdBankDeposit = ir.Id)

END
