
CREATE PROCEDURE [Soporte].[sp_FixCancelationsNotRegisteredByIdTransfer]
	@IdTransfer int
AS  

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que inserta registro de cancelación para transferencias canceladas que no afectaron balance.</Description>

<ChangeLog>
<log Date="02/08/2017" Author="jdarellano">Creación</log>
<log Date="18/05/2018" Author="jdarellano" Name="#1">Se agrega nota para envíos, por conciliación</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;  
          
BEGIN 

	--DECLARE @IdTransfer INT = 25383616
	DECLARE @IdAgent INT

	if exists (select 1 from [dbo].[AgentBalance] with(nolock) where IdTransfer=@IdTransfer and TypeOfMovement='TRAN')
	begin
		if exists (select 1 from [dbo].[Transfer] with(nolock) where IdTransfer=@IdTransfer and IdStatus=22)
		begin
			SELECT @IdAgent=IdAgent
			FROM [dbo].[Transfer] with(nolock)
			WHERE IdTransfer=@IdTransfer

			select 'El IdTransfer '+convert(varchar,@IdTransfer)+' se encuentra en la tabla [Transfer].'

			select IdTransfer,claimcode,IdAgent,Folio,IdStatus from [dbo].[Transfer] with(nolock) where IdTransfer=@IdTransfer and IdStatus=22

			If exists(select 1 from [dbo].[AgentBalance] with(nolock) Where IdAgent = @IdAgent AND IdTransfer = @IdTransfer and TypeOfMovement='CANC')
			begin 
				select 'El IdTransfer '+convert(varchar,@IdTransfer)+' ya cuenta con cancelación en balance.'

				Select IdAgent,IdAgentBalance,DateOfMovement,IdTransfer,Amount,Balance,DebitOrCredit,TypeOfMovement,Commission
				from [dbo].[AgentBalance] with(NOLOCK)
				Where IdAgent = @IdAgent AND IdTransfer = @IdTransfer 
				Order by IdAgentBalance desc

				Return
			End

			else 
			begin
				Select IdAgent,IdAgentBalance,DateOfMovement,IdTransfer,Amount,Balance,DebitOrCredit,TypeOfMovement,Commission
				from [dbo].[AgentBalance] with(NOLOCK)
				Where IdAgent = @IdAgent AND IdTransfer = @IdTransfer 
				Order by IdAgentBalance desc
				
				Declare @DateOfTransfer datetime = (select DateOfTransfer from dbo.[Transfer] with (nolock) where IdTransfer=@IdTransfer and IdStatus=22)

				if (((select DATEDIFF(MINUTE,@DateOfTransfer,GETDATE()))<30) and not exists(select 1 from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer and IdStatus=23 ))
				begin
					EXEC st_CancelCreditToAgentBalanceTotalAmount @IdTransfer	
				end 
				
				else
				begin
					EXEC st_CancelCreditToAgentBalance @IdTransfer
				end
			
				select 'Se aplica cancelación en balance'

				Select IdAgent,IdAgentBalance,DateOfMovement,IdTransfer,Amount,Balance,DebitOrCredit,TypeOfMovement,Commission
				from [dbo].[AgentBalance] with(NOLOCK)
				Where IdAgent = @IdAgent AND IdTransfer = @IdTransfer 
				Order by IdAgentBalance desc

				if exists (select 1 from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer and IdStatus=22)
				begin
					insert into [dbo].[TransferNote]--#1
						select Idtransferdetail,3,37,'Envío no acreditado a balance de agente por error sistema en la fecha correcta, envío se acredita a balance con fecha '+CONVERT(varchar,CAST(GETDATE() as date),101),GETDATE()
						from [dbo].[Transferdetail] with(nolock)
						where idtransferdetail=(select max(Idtransferdetail) from [dbo].[Transferdetail] where IdTransfer=@IdTransfer and IdStatus=22)

					select *
					from dbo.TransferNote with (nolock)
					where IdTransferDetail in (select IdTransferDetail from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer)
				end

				else
				begin
					insert into dbo.TransferDetail
						select IdStatus,IdTransfer, DateStatusChange
						from dbo.[Transfer] with (nolock)
						where IdTransfer=@IdTransfer

					insert into [dbo].[TransferNote]--#1
						select Idtransferdetail,3,37,'Envío no acreditado a balance de agente por error sistema en la fecha correcta, envío se acredita a balance con fecha '+CONVERT(varchar,CAST(GETDATE() as date),101),GETDATE()
						from [dbo].[Transferdetail] with(nolock)
						where idtransferdetail=(select max(Idtransferdetail) from [dbo].[Transferdetail] where IdTransfer=@IdTransfer and IdStatus=22)

					select *
					from dbo.TransferNote with (nolock)
					where IdTransferDetail in (select IdTransferDetail from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer)
				end

				select *
				from dbo.TransferNote with (nolock)
				where IdTransferDetail in (select IdTransferDetail from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer)
				
			end
	
		end

		else if exists (select 1 from [dbo].[TransferClosed] with(nolock) where IdTransferClosed=@IdTransfer and IdStatus=22)
		begin
			SELECT @IdAgent=IdAgent
			FROM [dbo].[TransferClosed] with(nolock)
			WHERE IdTransferClosed=@IdTransfer

			select 'El IdTransfer '+convert(varchar,@IdTransfer)+' se encuentra en la tabla [TransferClosed].'

			select IdTransferClosed,claimcode,IdAgent,Folio,IdStatus from [dbo].[TransferClosed] with(nolock) where IdTransferClosed=@IdTransfer and IdStatus=22

			If exists(select 1 from [dbo].[AgentBalance] with(nolock) Where IdAgent = @IdAgent AND IdTransfer = @IdTransfer and TypeOfMovement='CANC')
			begin 
				select 'El IdTransfer '+convert(varchar,@IdTransfer)+' ya cuenta con cancelación en balance.'

				Select IdAgent,IdAgentBalance,DateOfMovement,IdTransfer,Amount,Balance,DebitOrCredit,TypeOfMovement,Commission
				from [dbo].[AgentBalance] with(NOLOCK)
				Where IdAgent = @IdAgent 
					AND IdTransfer = @IdTransfer 
				Order by IdAgentBalance desc

				Return
			End

			else 
			begin
				select 'Se mueve transferencia a "Transfer" y se aplica cancelación en balance'
				
				EXEC [dbo].[st_MoveBackTransfer] @IdTransfer
					
				EXEC st_CancelCreditToAgentBalance @IdTransfer
										
				Select IdAgent,IdAgentBalance,DateOfMovement,IdTransfer,Amount,Balance,DebitOrCredit,TypeOfMovement,Commission
				from [dbo].[AgentBalance] with(NOLOCK)
				Where IdAgent = @IdAgent 
					AND IdTransfer = @IdTransfer 
				Order by IdAgentBalance desc

				if exists (select 1 from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer and IdStatus=22)
				begin
					insert into [dbo].[TransferNote]--#1
						select Idtransferdetail,3,37,'Envío no acreditado a balance de agente por error sistema en la fecha correcta, envío se acredita a balance con fecha '+CONVERT(varchar,CAST(GETDATE() as date),101),GETDATE()
						from [dbo].[Transferdetail] with(nolock)
						where idtransferdetail=(select max(Idtransferdetail) from [dbo].[Transferdetail] where IdTransfer=@IdTransfer and IdStatus=22)

					select *
					from dbo.TransferNote with (nolock)
					where IdTransferDetail in (select IdTransferDetail from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer)
				end

				else
				begin
					insert into dbo.TransferDetail
						select IdStatus,IdTransfer, DateStatusChange
						from dbo.[Transfer] with (nolock)
						where IdTransfer=@IdTransfer

					insert into [dbo].[TransferNote]--#1
						select Idtransferdetail,3,37,'Envío no acreditado a balance de agente por error sistema en la fecha correcta, envío se acredita a balance con fecha '+CONVERT(varchar,CAST(GETDATE() as date),101),GETDATE()
						from [dbo].[Transferdetail] with(nolock)
						where idtransferdetail=(select max(Idtransferdetail) from [dbo].[Transferdetail] where IdTransfer=@IdTransfer and IdStatus=22)

					select *
					from dbo.TransferNote with (nolock)
					where IdTransferDetail in (select IdTransferDetail from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer)
				end

				select *
				from dbo.TransferNote with (nolock)
				where IdTransferDetail in (select IdTransferDetail from dbo.TransferDetail with (nolock) where IdTransfer=@IdTransfer)

			end
		end

		else
		begin
			select 'El envío no aparece en las tablas de transferencias, favor de validar.'
			Return
		end
	end
	
	else 
	begin			
		select 'El IdTransfer '+convert(varchar,@IdTransfer)+' no cuenta con movimientos en balance, favor de validar.'

		Select IdAgent,IdAgentBalance,DateOfMovement,IdTransfer,Amount,Balance,DebitOrCredit,TypeOfMovement,Commission
		from [dbo].[AgentBalance] with(NOLOCK)
		Where Idagent = @IdAgent 
			AND IdTransfer = @IdTransfer 
		Order by IdAgentBalance desc

		Return
				
	end

END

