CREATE PROCEDURE MoneyGram.st_GetCustomerRelation
(
	@IdCustomer		BIGINT
)
AS
BEGIN

	IF EXISTS (SELECT 1 FROM MoneyGram.Customer c WHERE c.IdCustomer = @IdCustomer)
		SELECT
			c.*
		FROM MoneyGram.Customer c
		WHERE IdCustomer = @IdCustomer
	ELSE
		SELECT 
			0		IdCustomer,
			'0'		IdCustomerMoneyGram,
			NULL	FreqCustCardNumber
END