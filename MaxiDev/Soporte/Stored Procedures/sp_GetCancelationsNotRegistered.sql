
-- =============================================
-- Author:		<Juan Diego Arellano>
-- Create date: <02 de agosto de 2017>
-- Description:	<Procedimiento almacenado que identifica transacciones canceladas que no afectaron balance.>
-- =============================================
CREATE PROCEDURE [Soporte].[sp_GetCancelationsNotRegistered]
@BeginDate dateTime=null
AS            
BEGIN 

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)


SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


		Select 
		 *
		 from 
		 (
			select TD.IdTransfer, TD.DateOfMovement , T.Folio, T.IdAgent, T.ClaimCode, T.DateOfTransfer, T.IdStatus
			from TransferDetail TD(NOLOCK) 
				inner join Transfer T(NOLOCK) on T.IdTransfer=TD.IdTransfer
				inner join TransferDetail TDO(NOLOCK) on TDO.IdTransfer=T.IdTransfer and TDO.IdStatus=1
			where td.IdStatus=22  and TD.DateOfMovement>=@BeginDate
			union all
			select TD.IdTransferClosed, TD.DateOfMovement , T.Folio, T.IdAgent, T.ClaimCode, T.DateOfTransfer, T.IdStatus
			from TransferClosedDetail TD(NOLOCK) 
				inner join TransferClosed T(NOLOCK) on T.IdTransferClosed=TD.IdTransferClosed
				inner join TransferClosedDetail TDO(NOLOCK) on TDO.IdTransferClosed=T.IdTransferClosed and TDO.IdStatus=1
			where td.IdStatus=22 and TD.DateOfMovement>=@BeginDate
		 )L
		 inner join Agent A on A.IdAgent=L.IdAgent		 
		left join AgentBalance AB (nolock) on L.IdAgent=AB.IdAgent and L.Folio=AB.Reference and AB.TypeOfMovement='CANC'
		where DATEPART(HOUR, L.DateOfMovement)!= 22 and L.IdStatus!=27 --and  Convert(date,L.DateOfTransfer) not in ('2016-01-15','2016-01-13') 
			and AB.IdAgentBalance is null
		order by L.DateOfTransfer desc



END


