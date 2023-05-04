CREATE PROCEDURE BillPayment.st_GetBillPaymentTransactionReceipt
(
	@IdProductTransfer		BIGINT
)
AS 
BEGIN
	
	DECLARE @IdProvider	INT
	SELECT
		@IdProvider = IdProvider
	FROM Operation.ProductTransfer WITH(NOLOCK)
	WHERE IdProductTransfer = @IdProductTransfer

	IF @IdProvider = 5
		EXEC regalii.st_GetTransactionReceiptRegalii @IdProductTransfer
	ELSE
		EXEC [BillPayment].[st_GetTransactionReceiptBillPayment] @IdProductTransfer
END