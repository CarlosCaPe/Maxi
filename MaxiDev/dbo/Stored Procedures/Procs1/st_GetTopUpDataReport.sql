
create PROCEDURE [dbo].[st_GetTopUpDataReport]
(
    @BeginDate DATETIME,
	@EndDate DATETIME
)
AS

SELECT @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)
SELECT @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)

SELECT A.AgentCode AS AgentCode
	, TT.ReturnTimeStamp AS DateOfTransfer
	, TT.IdTransferTTo AS Folio
	, TT.RetailPrice AS RetailPrice
	, TT.WholeSalePrice AS WholeSalePrice
	, TT.AgentCommission AS AgentCommission
	, TT.CorpCommission AS CorpCommission
	,Operator AS Carrier
	,Country AS Country
	,CONVERT(MONEY, localinfovalue) AS ValueSent
FROM [TransFerTo].[TransferTTo]  TT (NOLOCK)
	JOIN [dbo].[Agent] A (NOLOCK) ON A.IdAgent = TT.IdAgent
WHERE TT.[IdStatus] = 30 /*PAYED*/ AND
	TT.ReturnTimeStamp >= @BeginDate AND 
	TT.ReturnTimeStamp <= @EndDate
order by TT.ReturnTimeStamp


