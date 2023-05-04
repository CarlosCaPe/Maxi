
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <11 de enero de 2018>
-- Description:	<Procedimiento almacenado que elimina registros duplicados de envíos, del "AgentBalance".>
-- =============================================
create PROCEDURE [Soporte].[sp_DeleteDuplicateTransactionsOfAgentBalance]

	@AgentCode varchar(15),--AgentCode de la agencia reportada

	@Folio int,--Folio reportado como duplicado

	@Confirm bit=0--Variable que permite visualizar el cambio sin afectar (cuando es "0"). Para aplicar el cambio, cambiar a "1"
AS
BEGIN
	
	declare @IdAgent int=(select IdAgent from Agent with(nolock) where AgentCode=@AgentCode)
			
	if not exists (select 1 from AgentBalance with(nolock) where IdAgent=@IdAgent and Reference=@Folio)
	begin
		select 'El folio '+CAST(@Folio as varchar)+' de la agencia '+CAST(@AgentCode as varchar)+' no existe, favor de validar' as Result
		Return
	end

	else
	begin
	
		declare @NoRepeats int
		set @NoRepeats=(
			select count(1)
			from AgentBalance with(nolock)
			where IdAgent=@IdAgent
				and Reference=@Folio
				and TypeOfMovement='TRAN')
	
		if (@NoRepeats<2)
		begin
			select 'El folio '+CAST(@Folio as varchar)+' de la agencia '+CAST(@AgentCode as varchar)+' no está repetido, favor de validar' as Result
			Return
		end

		else
		begin
			begin tran

				select *
				from AgentBalance with(nolock)
				where IdAgent=@IdAgent
					and Reference=@Folio
					and TypeOfMovement='TRAN'

				delete
				from AgentBalance
				where Reference=@Folio
					and IdAgentBalance=(select top 1 IdAgentBalance from AgentBalance with(nolock) where IdAgent=@IdAgent and Reference=@Folio and TypeOfMovement='TRAN' order by 1 desc )

				select *
				from AgentBalance with(nolock)
				where IdAgent=@IdAgent
					and Reference=@Folio
					and TypeOfMovement='TRAN'

				if (@Confirm=0)
					rollback
				else
					commit
					select 'El folio duplicado ya se eliminó' as Result
		end
	end
END
