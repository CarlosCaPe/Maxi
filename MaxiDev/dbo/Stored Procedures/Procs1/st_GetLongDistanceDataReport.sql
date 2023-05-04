
create PROCEDURE [dbo].[st_GetLongDistanceDataReport]
(
    @BeginDate DATETIME,
	@EndDate DATETIME
)
AS

SELECT @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)
SELECT @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)

SELECT A.AgentCode AS AgentCode
	, P.DateOfTransaction AS DateOfTransfer
	, P.IdPureMinutes AS Folio
	, P.ReceiveAmount AS Amount
	, P.AgentCommission AS AgentCommission
	, P.CorpCommission AS CorpCommission
FROM [dbo].[PureMinutesTransaction]  P (NOLOCK)
	JOIN [dbo].[Agent] A (NOLOCK) on A.IdAgent = P.IdAgent
WHERE P.[Status] = 1 /*PAYED*/ AND
	P.DateOfTransaction >= @BeginDate AND 
	P.DateOfTransaction <= @EndDate
order by P.DateOfTransaction


