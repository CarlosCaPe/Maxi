CREATE PROCEDURE [dbo].[st_MaxiAlertD_CancelationsNotRegistered]
@BeginDate dateTime=null
AS            
BEGIN 

if(@BeginDate is null)
	set @BeginDate= convert(date,GETDATE()-1)


SET NOCOUNT ON;   
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


		Select 
		 'Cancelaciones no registradas'  NameValidation, 
			    'AgentId:'+ISNULL(CAST(A.idAgent AS VARCHAR), '')+'; AgentCode:'+ISNULL(CAST(A.AgentCode AS  VARCHAR), '')+ '; ClaimCode:'+ISNULL(L.ClaimCode, '') 
					+ '; IdTransfer:'+ISNULL(CAST( L.IdTransfer AS  VARCHAR), '') + '; DateOfTransfer:'+ISNULL(CAST( L.DateOfTransfer AS  VARCHAR), '') 
					 + '; DateOfMovement:'+ISNULL(CAST( L.DateOfMovement AS  VARCHAR), '') 	MsgValidation,
				'Verificacion manual' FixDescription,
				'' Fix	
		 from 
		 (
			select TD.IdTransfer, TD.DateOfMovement , T.Folio, T.IdAgent, T.ClaimCode, T.DateOfTransfer, T.IdStatus
			from TransferDetail TD 
				inner join Transfer T on T.IdTransfer=TD.IdTransfer
				inner join TransferDetail TDO on TDO.IdTransfer=T.IdTransfer and TDO.IdStatus=1
			where td.IdStatus=22  and TD.DateOfMovement>=@BeginDate
			union all
			select TD.IdTransferClosed, TD.DateOfMovement , T.Folio, T.IdAgent, T.ClaimCode, T.DateOfTransfer, T.IdStatus
			from TransferClosedDetail TD 
				inner join TransferClosed T on T.IdTransferClosed=TD.IdTransferClosed
				inner join TransferClosedDetail TDO on TDO.IdTransferClosed=T.IdTransferClosed and TDO.IdStatus=1
			where td.IdStatus=22 and TD.DateOfMovement>=@BeginDate
		 )L
		 inner join Agent A on A.IdAgent=L.IdAgent		 
		left join AgentBalance AB on L.IdAgent=AB.IdAgent and L.Folio=AB.Reference and AB.TypeOfMovement='CANC'
		where DATEPART(HOUR, L.DateOfMovement)!= 22 and L.IdStatus!=27 --and  Convert(date,L.DateOfTransfer) not in ('2016-01-15','2016-01-13') 
			and AB.IdAgentBalance is null
		order by L.DateOfTransfer desc





END


