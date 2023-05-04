
CREATE PROCEDURE [Soporte].[sp_AdjustmentOfChecksWithoutAgentBalance]

	@AgentCode varchar(15),--AgentCode de la agencia reportada

	@CheckNumber varchar(30),--CheckNumber del cheque reportado

	@Confirm bit=0--Variable que permite visualizar el cambio sin afectar (cuando es "0"). Para aplicar el cambio, cambiar a "1"
AS

/********************************************************************
<Author>Juan Diego Arellano</Author>
<app>---</app>
<Description>Procedimiento almacenado que afecta balance de cheques pagados que no han afectado balance.</Description>

<ChangeLog>
<log Date="08/01/2018" Author="jdarellano">Creación.</log>
<log Date="10/05/2018" Author="jdarellano" Name="#1">Se agrega nota por conciliación.</log>
</ChangeLog>
*********************************************************************/

BEGIN
	
	declare @IdAgent int=(select IdAgent from Agent with(nolock) where AgentCode=@AgentCode)

	declare @IdCheck int=(select IdCheck from Checks with(nolock) where IdAgent=@IdAgent and CheckNumber=@CheckNumber)
	
	if not exists (select 1 from Checks with(nolock) where IdAgent=@IdAgent and CheckNumber=@CheckNumber)
	begin 
		select 'El cheque '+CONVERT(varchar,@CheckNumber)+' no existe en la tabla "Checks"' as Result
		select @IdCheck as IdCheck
		Return
	end
	else
	begin
		select @IdCheck as IdCheck

		if exists (select 1 from AgentBalance with(nolock) where IdAgent=@IdAgent and TypeOfMovement like 'CH%' and IdTransfer=@IdCheck)
		begin
			select 'El cheque '+convert(varchar,@IdCheck)+' ya tiene registro en el "AgentBalance"' as Result

			select *
			from AgentBalance with(nolock)
			where IdAgent=@IdAgent
				and TypeOfMovement like 'CH%'
				and IdTransfer=@IdCheck

			Return
		end
		else
		begin
			begin tran
			
				select *
				from AgentBalance with(nolock)
				where IdAgent=@IdAgent
					and TypeOfMovement like 'CH%'
					and IdTransfer=@IdCheck
				
				exec [Checks].[st_CheckApplyToAgentBalance] @IdCheck

				select *
				from AgentBalance with(nolock)
				where IdAgent=@IdAgent
					and TypeOfMovement like 'CH%'
					and IdTransfer=@IdCheck

				insert into [dbo].[CheckNote]--#1
					select IdCheckDetail,3,37,'Cheque no acreditado a balance de agente por error sistema en la fecha correcta, cheque se acredita a balance con fecha '+CONVERT(varchar,CAST(GETDATE() as date),101),GETDATE()
					from [dbo].[CheckDetails] with(nolock)
					where IdCheckDetail=(select max(idcheckdetail) from [dbo].[CheckDetails] where IdCheck=@IdCheck and IdStatus=30)

				select *--#1
				from dbo.CheckNote with (nolock)
				where IdCheckDetail=(select max(idcheckdetail) from [dbo].[CheckDetails] where IdCheck=@IdCheck and IdStatus=30)

				if (@Confirm=0)
					rollback
				else
					commit
					select 'El cheque '+convert(varchar,@IdCheck)+' ya afectó el "AgentBalance"' as Result
		end
	end
END
