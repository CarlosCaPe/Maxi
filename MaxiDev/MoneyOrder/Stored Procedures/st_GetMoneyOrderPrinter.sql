CREATE PROCEDURE MoneyOrder.st_GetMoneyOrderPrinter
(
	@Identifier				NVARCHAR(200)
)
AS
BEGIN
	SELECT MoneyOrderPrinter FROM PcIdentifier WITH(NOLOCK)
	WHERE Identifier = @Identifier
END