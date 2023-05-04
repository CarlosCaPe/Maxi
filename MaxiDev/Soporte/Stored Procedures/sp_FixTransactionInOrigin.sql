
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <09 de septiembre de 2017>
-- Description:	<Procedimiento almacenado que procesa automáticamente transacciones en estatus "Origin".>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_FixTransactionInOrigin]
	@BeginDate dateTime=null
AS     

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;       

BEGIN

	if(@BeginDate is null)
		set @BeginDate= convert(date,GETDATE()-5)


		declare @OriginTran table
		(
			ID int identity(1,1),
			Transactions int
		)

		insert into @OriginTran
			exec Soporte.sp_GetTransactionInOrigin @BeginDate

		if exists (select top 1 1 from @OriginTran)
		begin
			select *
			from @OriginTran

			declare @i int=1, @tot int
			set @tot=(select COUNT(*) from @OriginTran)

			while (@i<=@tot)
			begin
				declare @IdTransfer int
				set @IdTransfer=(select Transactions from @OriginTran where ID=@i)	

				exec Soporte.sp_ProcessTransactionInOrigin @IdTransfer

				select IdTransfer,ClaimCode,IdStatus,DateOfTransfer
				from Transfer(nolock)
				where IdTransfer=@IdTransfer
				
				select top 1 *
				from TransferDetail(nolock) 
				where IdTransfer=@IdTransfer
				order by 1 desc

				select *
				from AgentBalance(nolock)
				where IdTransfer=@IdTransfer

				set @i=@i+1
			end
		end

		else
		begin
			select 'No hay Transacciones en Origin'
			Return
		end
END