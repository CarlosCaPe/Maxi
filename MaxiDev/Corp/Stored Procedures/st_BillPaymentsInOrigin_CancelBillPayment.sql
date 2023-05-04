CREATE  PROCEDURE Corp.st_BillPaymentsInOrigin_CancelBillPayment
	@Folio		INT,
	@Confirm	BIT,
	@HasError 	BIT OUT,          
    @Message 	VARCHAR(max) OUT
	
AS
BEGIN

	IF (EXISTS(SELECT 1 FROM BillPayment.TransferR R WHERE R.IdProductTransfer = @Folio))
	BEGIN
	
		--SELECT 'Es Fidelity/Fiserv'
		EXEC [Corp].[st_CancelationOfBillPaymentFidelityFiservOrigin] @ProductTransfer = @Folio, @Confirm = @Confirm,@HasError =  @HasError OUT, @Message = @Message OUT
	
	END
	ELSE IF (EXISTS(SELECT 1 FROM Regalii.TransferR R WHERE R.IdProductTransfer = @Folio))
	BEGIN
	
		--SELECT 'Es Regalii'
		EXEC [Corp].[st_CancelationOfBillPaymentRegaliiOrigin] @ProductTransfer = @Folio, @Confirm = @Confirm, @HasError = @HasError OUT, @Message = @Message OUT
		
	END
	ELSE
	BEGIN
		SET @HasError = 0
		SET @Message = 'Payment could not be found.'
	END

END