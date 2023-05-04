/********************************************************************
<Author>Miguel Prado</Author>
<date>19/Octubre/2022</date>
<app>MaxiAgente</app>
<Description>Sp para actualizar IdTransfer en TransferReasonNotCustomerPhone en Interceptor</Description>
*********************************************************************/
CREATE PROCEDURE [dbo].[st_UpdateTransferReasonNotCustomerPhone] 
	@IdTransferReasonNotCustomerPhone	INT,
	@IdPreTransfer						INT,
	@IdTransfer							INT,
	@HasError							BIT = '' OUTPUT
AS
BEGIN TRY

	UPDATE TR set TR.[IdTransfer] = @IdTransfer
	FROM TransferReasonNotCustomerPhone TR WITH (NOLOCK)
	WHERE TR.[IdTransferReasonNotCustomerPhone] = @IdTransferReasonNotCustomerPhone
	AND TR.IdPreTransfer = @IdPreTransfer;

	UPDATE T set T.[IsRequiredCustomerPhoneNumber] = 1
	FROM Transfer T WITH (NOLOCK)
	WHERE T.[IdTransfer] = @IdTransfer;

	SET @HasError = 0;

	SELECT @HasError;

END TRY
BEGIN CATCH
	
	DECLARE @ErrorMessage NVARCHAR(MAX)
	      
	SELECT @ErrorMessage = ERROR_MESSAGE();
	
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[st_UpdateTransferReasonNotCustomerPhone]',Getdate(),@ErrorMessage);
	
	SET @HasError = 1;

    SELECT @HasError;

END CATCH
