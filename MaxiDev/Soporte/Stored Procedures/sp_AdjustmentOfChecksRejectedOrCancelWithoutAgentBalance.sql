CREATE PROCEDURE [Soporte].[sp_AdjustmentOfChecksRejectedOrCancelWithoutAgentBalance]

	@IdCheck int,

	@Confirm bit=0--Variable que permite visualizar el cambio sin afectar (cuando es "0"). Para aplicar el cambio, cambiar a "1"
AS

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que afecta balance de cheques cancelados ó rechazados que no han afectado balance.</Description>

<ChangeLog>
<log Date="13/06/2018" Author="jdarellano">Creación.</log>
</ChangeLog>
*********************************************************************/

BEGIN
	
	if not exists (select 1 from dbo.Checks with(nolock) where IdCheck=@IdCheck)
	begin 
		select 'El cheque con IdCheck '+CONVERT(varchar,@IdCheck)+' no existe en la tabla "Checks"' as Result
		select @IdCheck as IdCheck
		select * from dbo.Checks with (nolock) where IdCheck=@IdCheck
		Return
	end
	else
	begin
		select @IdCheck as IdCheck

		select * from dbo.Checks with (nolock) where IdCheck=@IdCheck

		declare @IdAgent int

		select @IdAgent=IdAgent from dbo.Checks with (nolock) where IdCheck=@IdCheck

		if exists (select 1 from dbo.AgentBalance with(nolock) where IdAgent=@IdAgent and IdTransfer=@IdCheck and TypeOfMovement like 'CH%')
		begin
				if exists (select 1 from dbo.AgentBalance with(nolock) where IdAgent=@IdAgent and IdTransfer=@IdCheck and TypeOfMovement = 'CHRTN')
				Begin
					select 'El cheque '+convert(varchar,@IdCheck)+' ya tiene registro en el "AgentBalance"' as Result

					select *
					from AgentBalance with(nolock)
					where IdAgent=@IdAgent
						and TypeOfMovement like 'CH%'
						and IdTransfer=@IdCheck

					Return
				End
		
				else
				begin
					begin tran
			
						select *
						from dbo.AgentBalance with(nolock)
						where IdAgent=@IdAgent
							and TypeOfMovement like 'CH%'
							and IdTransfer=@IdCheck
				
						exec [Checks].[st_CheckCancelToAgentBalance]
							@IdCheck=@IdCheck,
							@EnterByIdUser=37,
							@IsReject= 0

						select *
						from AgentBalance with(nolock)
						where IdAgent=@IdAgent
							and TypeOfMovement like 'CH%'
							and IdTransfer=@IdCheck
						
						If exists (select 1 from [dbo].[CheckDetails] with (nolock) where IdCheck=@IdCheck and IdStatus=31)
						begin
							insert into [dbo].[CheckNote]--#1
								select IdCheckDetail,3,37,'Cheque sin débito en balance de agente por error sistema en la fecha correcta, cheque se afecta balance con fecha '+CONVERT(varchar,CAST(GETDATE() as date),101),GETDATE()
								from [dbo].[CheckDetails] with(nolock)
								where IdCheckDetail=(select max(idcheckdetail) from [dbo].[CheckDetails] where IdCheck=@IdCheck and IdStatus=31)

							select *--#1
							from dbo.CheckNote with (nolock)
							where IdCheckDetail=(select max(idcheckdetail) from [dbo].[CheckDetails] with (nolock) where IdCheck=@IdCheck and IdStatus=31)
						end
						
						else
						Begin
							insert into dbo.CheckDetails
								select @IdCheck,31,DateStatusChange,'Rejected',37
								from dbo.Checks with (nolock)
								where IdCheck=@IdCheck

							insert into [dbo].[CheckNote]--#1
								select IdCheckDetail,3,37,'Cheque sin débito en balance de agente por error sistema en la fecha correcta, cheque se afecta balance con fecha '+CONVERT(varchar,CAST(GETDATE() as date),101),GETDATE()
								from [dbo].[CheckDetails] with(nolock)
								where IdCheckDetail=(select max(idcheckdetail) from [dbo].[CheckDetails] where IdCheck=@IdCheck and IdStatus=31)

							select *--#1
							from dbo.CheckNote with (nolock)
							where IdCheckDetail=(select max(idcheckdetail) from [dbo].[CheckDetails] with (nolock) where IdCheck=@IdCheck and IdStatus=31)
						End

						if (@Confirm=0)
							rollback
						else
							commit
							select 'El cheque '+convert(varchar,@IdCheck)+' ya afectó el "AgentBalance"' as Result
				end
		end

		else
		Begin
			select 'El cheque '+convert(varchar,@IdCheck)+' no existe en el "AgentBalance"' as Result

			select *
			from AgentBalance with(nolock)
			where IdAgent=@IdAgent
				and TypeOfMovement like 'CH%'
				and IdTransfer=@IdCheck

			Return
		End
	end
END
