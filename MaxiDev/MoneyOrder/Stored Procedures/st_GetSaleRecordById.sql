CREATE   PROCEDURE MoneyOrder.st_GetSaleRecordById
(
	@IdSaleRecord	INT
)
AS
BEGIN
	SELECT * FROM MoneyOrder.SaleRecord sr WITH(NOLOCK)
	WHERE sr.IdSaleRecord = @IdSaleRecord
END