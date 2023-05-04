
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <02 de agosto de 2017>
-- Description:	<Procedimiento almacenado que registra transacciones canceladas que no afectaron balance en el día anterior.>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_FixCancelationsNotRegistered]
	@BeginDate dateTime=null,
	@IsVisible bit=0
AS 

SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;       

BEGIN TRY

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)


SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


		Select 
			L.IdTransfer, L.DateOfMovement , L.Folio, L.IdAgent, L.ClaimCode, L.DateOfTransfer, L.IdStatus
		 into #TmpTest
		 from 
		 (
			select TD.IdTransfer, TD.DateOfMovement , T.Folio, T.IdAgent, T.ClaimCode, T.DateOfTransfer, T.IdStatus
			from TransferDetail TD with (nolock)
				inner join [Transfer] T with (nolock) on T.IdTransfer=TD.IdTransfer
				inner join TransferDetail TDO with (nolock) on TDO.IdTransfer=T.IdTransfer and TDO.IdStatus=1
			where td.IdStatus=22  and TD.DateOfMovement>=@BeginDate
			union all
			select TD.IdTransferClosed, TD.DateOfMovement , T.Folio, T.IdAgent, T.ClaimCode, T.DateOfTransfer, T.IdStatus
			from TransferClosedDetail TD 
				inner join TransferClosed T with (nolock) on T.IdTransferClosed=TD.IdTransferClosed
				inner join TransferClosedDetail TDO with (nolock) on TDO.IdTransferClosed=T.IdTransferClosed and TDO.IdStatus=1
			where td.IdStatus=22 and TD.DateOfMovement>=@BeginDate
		 )L
		 inner join Agent A with (nolock) on A.IdAgent=L.IdAgent		 
		left join AgentBalance AB (nolock) on L.IdAgent=AB.IdAgent and L.Folio=AB.Reference and AB.TypeOfMovement='CANC'
		where DATEPART(HOUR, L.DateOfMovement)!= 22 and L.IdStatus!=27 --and  Convert(date,L.DateOfTransfer) not in ('2016-01-15','2016-01-13') 
			and AB.IdAgentBalance is null
		order by L.DateOfTransfer desc

		if (@IsVisible=1)
		begin
			select * from #TmpTest
		end

		select distinct IdTransfer 
		into #IdTransfer
		from #TmpTest with (nolock)
		order by IdTransfer


		if exists(select 1 from #IdTransfer)
		begin
			declare @idtr int

			while exists (select 1 from #IdTransfer)
			begin
	
				set @idtr=(select top 1 IdTransfer from #IdTransfer with (nolock))

				exec Soporte.sp_FixCancelationsNotRegisteredByIdTransfer @idtr

				if (@IsVisible=1)
				begin
					select * from AgentBalance(nolock)
					where IdTransfer=@idtr
					and TypeOfMovement='CANC'
				end

				delete from #IdTransfer where IdTransfer=@idtr
			end

			drop table #IdTransfer
			drop table #TmpTest
		end

		else
		begin
			drop table #IdTransfer
			drop table #TmpTest
		end

END TRY
Begin Catch    
DECLARE @ErrorMessage varchar(max)                                                                 
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Soporte.sp_FixCancelationsNotRegistered',Getdate(),@ErrorMessage)
End catch

