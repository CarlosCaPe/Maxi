CREATE PROCEDURE [dbo].[st_FindPaymentTypeById]
(
	@Id INT
)
AS
BEGIN
	SELECT
		c.IdPaymentType as Id, c.PaymentName as Name
	FROM PaymentType c 
	WHERE c.IdPaymentType = @Id
END