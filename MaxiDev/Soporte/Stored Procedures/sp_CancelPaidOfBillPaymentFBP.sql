

CREATE PROCEDURE [Soporte].[sp_CancelPaidOfBillPaymentFBP]
	@IdProductTransfer int=0, --2741797
	@Tracenumber nvarchar(255)='', --148548635
	@Confirm bit=0
AS 

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado para la cancelación de pagos de bill solicitados por Maxi para Fidelity o FiServ.</Description>

<ChangeLog>
<log Date="20/09/2019" Author="jdarellano">Creación.</log>
</ChangeLog>
*********************************************************************/    

BEGIN
	declare @HasError bit
	declare @Message nvarchar(max)

	if (@IdProductTransfer!=0 or @Tracenumber!='')
	begin
		If (@IdProductTransfer=0 and @Tracenumber!='')
		begin
			set @IdProductTransfer=(select idProducttransfer from Billpayment.TransferR with (nolock) where tracenumber=@Tracenumber)
			select @IdProductTransfer
		end
		begin transaction
			if ((select IdStatus from Operation.ProductTransfer with (nolock) where IdProductTransfer=@IdProductTransfer)!=22)
			begin
			
				exec [BillPayment].[st_CancelBPTransaction]
					@IdProductTransfer=@IdProductTransfer,
					@EnterByIdUser=37,
					@IdLenguage=1,
					@HasError=@HasError,
					@Message=@Message

				select * from Operation.ProductTransfer with (nolock) where IdProductTransfer=@IdProductTransfer
			end
			else
				select 'El pago de bill ya fué cancelado, favor de validar'

			if (@Confirm=0)
				rollback
			else
				commit
	
	end

	else
	begin
		select 'Favor de ingresar "IdProductTransfer" o "TraceNumber"'
		Return
	end
END
