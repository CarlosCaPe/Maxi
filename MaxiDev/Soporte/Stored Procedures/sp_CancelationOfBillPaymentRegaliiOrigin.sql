CREATE PROCEDURE [Soporte].[sp_CancelationOfBillPaymentRegaliiOrigin]

	@ProductTransfer int,--Folio reportado para cancelación

	@Confirm bit=0--Variable que permite visualizar el cambio sin afectar (cuando es "0"). Para aplicar el cambio, cambiar a "1"
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
	
	declare @IdTransferR int

	if exists (select 1 from [dbo].[AgentBalance] with(nolock) where TypeOfMovement='RBP' and IdTransfer=@ProductTransfer)
	begin
		select 'El pago afectó balance' as Result

		select * from [dbo].[AgentBalance] with(nolock) where TypeOfMovement='RBP' and IdTransfer=@ProductTransfer

		Return
	end

	else
	begin
		set @IdTransferR=(select IdTransferR from [Regalii].[TransferR] with(nolock) where IdProductTransfer=@ProductTransfer)
	
		if exists (select 1 from [Regalii].[TransferR] with(nolock) where IdTransferR=@IdTransferR and IdStatus=22)
		begin
			select 'El pago ya está cancelado' as Result

			select IdTransferR,IdAgent,DateOfCreation,EnterByIdUserCancel,DateOfCancel,IdStatus,IdProductTransfer,CustomerName,CustomerFirstLastName,CustomerSecondLastName
			from [Regalii].[TransferR] with(nolock)
			where IdTransferR=@IdTransferR

			select * from Operation.ProductTransfer with (nolock) where IdProductTransfer=@ProductTransfer

			Return
		end

		else
		begin
			begin tran

				select IdTransferR,IdAgent,DateOfCreation,EnterByIdUserCancel,DateOfCancel,IdStatus,IdProductTransfer,CustomerName,CustomerFirstLastName,CustomerSecondLastName
				from [Regalii].[TransferR] with(nolock)
				where IdTransferR=@IdTransferR

				select * from Operation.ProductTransfer with (nolock) where IdProductTransfer=@ProductTransfer

				update [Regalii].[TransferR]
				set EnterByIdUserCancel=37,
					DateOfCancel=GETDATE(),
					IdStatus=22
				where IdTransferR=@IdTransferR

				update Operation.ProductTransfer set DateOfCancel=GETDATE(),EnterByIdUserCancel=37,IdStatus=22,TransactionProviderCancelDate=GETDATE() where IdProductTransfer=@ProductTransfer

				select IdTransferR,IdAgent,DateOfCreation,EnterByIdUserCancel,DateOfCancel,IdStatus,IdProductTransfer,CustomerName,CustomerFirstLastName,CustomerSecondLastName
				from [Regalii].[TransferR] with(nolock)
				where IdTransferR=@IdTransferR

				select * from Operation.ProductTransfer with (nolock) where IdProductTransfer=@ProductTransfer


			if (@Confirm=1)
				commit
			else
				rollback

		end
	end
END
