CREATE PROCEDURE [Corp].[st_CancelationOfBillPaymentRegaliiOrigin]

	@ProductTransfer	INT,--Folio reportado para cancelación
	@Confirm 			BIT = 0, --Variable que permite visualizar el cambio sin afectar (cuando es "0"). Para aplicar el cambio, cambiar a "1"
	@HasError 			BIT OUT,          
    @Message 			VARCHAR(max) OUT
AS

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que cancela pagos de bill para Regalii que se encuentra en estatus "Origin".</Description>

<ChangeLog>
<log Date="23/07/2018" Author="jdarellano">Creación.</log>
</ChangeLog>
*********************************************************************/

BEGIN
	
	declare @IdTransferR INT
	
	SET @IdTransferR = (SELECT IdTransferR FROM [Regalii].[TransferR] WITH(nolock) where IdProductTransfer = @ProductTransfer)
	
	
	IF EXISTS (select 1 from Regalii.[TransferR] with(nolock) where IdTransferR=@IdTransferR and IdStatus NOT IN (1, 22))
	BEGIN
		--SELECT 'Bill Payment not in Origin, it cannot be cancelled.'
		SET @HasError = 0
		SET @Message = 'Bill Payment not in Origin, it cannot be cancelled.'
		
		RETURN
	END

	if exists (select 1 from [dbo].[AgentBalance] with(nolock) where TypeOfMovement='RBP' and IdTransfer=@ProductTransfer)
	begin
		SET @HasError = 0
		SET @Message = 'Payment affected balance, it cannot be cancelled.'

		Return
	end

	else
	BEGIN
	
		SET @IdTransferR = (SELECT IdTransferR FROM [Regalii].[TransferR] WITH(nolock) where IdProductTransfer = @ProductTransfer)
	
		if exists (select 1 from [Regalii].[TransferR] with(nolock) where IdTransferR=@IdTransferR and IdStatus=22)
		begin
			SET @HasError = 0
			SET @Message = 'Payment already cancelled.'
			
			Return
		end

		else
		begin
			begin tran


				UPDATE [Regalii].[TransferR]
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
				
				SET @HasError = 0
				SET @Message = 'Payment cancelled successfully.'
				

			if (@Confirm=1)
				commit
			else
				rollback

		end
	end
END

