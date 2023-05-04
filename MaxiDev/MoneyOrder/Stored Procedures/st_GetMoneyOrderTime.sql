CREATE   PROCEDURE [MoneyOrder].[st_GetMoneyOrderTime]
(
	@IdSaleRecord						INT
)
AS
BEGIN
	SELECT DATEDIFF(MINUTE, s.CreationDate, GETDATE()) FROM MoneyOrder.SaleRecord s WHERE IdSaleRecord = @IdSaleRecord
END