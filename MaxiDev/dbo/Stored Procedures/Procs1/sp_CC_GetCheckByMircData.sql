
-- =============================================
-- Author:		TSI
-- Description:	Regresa el cheque mas viejo registrado que concuerde con los datos del mirc
-- =============================================
CREATE PROCEDURE [dbo].[sp_CC_GetCheckByMircData]
	@ChNum varchar(100),
	@RoutNum varchar(100),
	@AccNum varchar(100)
AS

SET NOCOUNT ON;
SET XACT_ABORT ON;

SELECT TOP (1)
	CH.IdCheck,
	CH.CheckNumber, CH.RoutingNumber, CH.Account,
	CH.IdIssuer, CH.IssuerName, CH.DateOfIssue,
	CH.IdCustomer,
	CONCAT(CH.Name,' ',CH.FirstLastName,' ',CH.SecondLastName) [CustomerName],
	CH.IdStatus, ST.StatusName,
	CH.IdAgent, AG.AgentName,
	CH.Amount,

	CR.IdReturnedReason [IdRejectReason],
	CR.DateOfReject [RejectDate],
	CR.EnterByIdUser [RejectByIdUser],
	RR.RTR_Name [RejectReasonName],
	ISNULL(CR.IrdPrinted,0) IrdPrinted,

	RR.CanReProcessCheck AS [CanReProcessCheck],
	RR.CanRePrintCheck   AS [CanRePrintCheck]

FROM dbo.Checks(NOLOCK) CH
JOIN dbo.CheckRejectHistory(NOLOCK) CR ON( CR.IdCheck = CH.IdCheck )
JOIN dbo.CC_ReturnedReasons(NOLOCK) RR ON( RR.ReturnedReason_ID = CR.IdReturnedReason)
LEFT JOIN dbo.Status(NOLOCK) ST ON ST.IdStatus = CH.IdStatus
LEFT JOIN dbo.Agent(NOLOCK) AG ON AG.IdAgent = CH.IdAgent

WHERE CH.CheckNumber = @ChNum 
AND CH.RoutingNumber = @RoutNum 
AND CH.Account = @AccNum
ORDER BY CH.IdCheck DESC