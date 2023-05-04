CREATE PROCEDURE [dbo].[st_AMLPGetCustomerHistory]
(
	@IdCustomer		INT
)
AS
BEGIN
	SELECT
		c.*
	FROM Customer c 
	WHERE c.IdCustomer = @IdCustomer
END
