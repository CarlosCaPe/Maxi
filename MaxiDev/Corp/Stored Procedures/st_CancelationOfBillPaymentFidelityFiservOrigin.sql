CREATE PROCEDURE [Corp].[st_CancelationOfBillPaymentFidelityFiservOrigin]

	@ProductTransfer 	INT, --Folio reportado para cancelación
	@Confirm 			BIT = 0, --Variable que permite visualizar el cambio sin afectar (cuando es "0"). Para aplicar el cambio, cambiar a "1"
	@HasError 			BIT OUT,          
    @Message 			VARCHAR(max) OUT
AS

/********************************************************************
<Author>Cesar Garcia</Author>
<app>Nuevo Corpo</app>
<Description>Procedimiento almacenado que cancela pagos de bill para Regalii que se encuentra en estatus "Origin".</Description>


*********************************************************************/

BEGIN
	
	DECLARE @IdTransferR INT
	SET @IdTransferR=(select IdTransferR from Billpayment.[TransferR] with(nolock) where IdProductTransfer = @ProductTransfer)
	
	IF EXISTS (select 1 from Billpayment.[TransferR] with(nolock) where IdTransferR=@IdTransferR and IdStatus NOT IN (1, 22))
	BEGIN
		--SELECT 'Bill Payment not in Origin, it cannot be cancelled.'
		SET @HasError = 0
		SET @Message = 'Bill Payment not in Origin, it cannot be cancelled.'
		
		RETURN
	END

	if exists (select 1 from [dbo].[AgentBalance] with(nolock) where TypeOfMovement='FBP' and IdTransfer = @ProductTransfer)
	BEGIN
		--SELECT 'Payment affected balance, it cannot be cancelled.'
		SET @HasError = 0
		SET @Message = 'Payment affected balance, it cannot be cancelled.'

		Return
	end
	else
	begin		
	
		if exists (select 1 from Billpayment.[TransferR] with(nolock) where IdTransferR=@IdTransferR and IdStatus=22)
		BEGIN
			--SELECT 'Payment already cancelled.'
			SET @HasError = 0
			SET @Message = 'Payment already cancelled.'
			
			Return
		end
		else
		begin
			begin tran


				UPDATE Billpayment.[TransferR]
				SET EnterByIdUserCancel = 37,
					DateOfCancel = GETDATE(),
					IdStatus = 22
				WHERE IdTransferR = @IdTransferR

				UPDATE Operation.ProductTransfer 
				SET DateOfCancel = GETDATE(),
					EnterByIdUserCancel = 37,
					IdStatus = 22,
					TransactionProviderCancelDate = GETDATE() 
				WHERE IdProductTransfer = @ProductTransfer
				
				--SELECT 'Payment cancelled successfully.'
				SET @HasError = 0
				SET @Message = 'Payment cancelled successfully.'



			if (@Confirm=1)
				commit
			else
				rollback

		end
	end
END

