
create PROCEDURE [dbo].[st_GetBillPaymentDataReport]
(
    @BeginDate DATETIME,
	@EndDate DATETIME
)
AS

SELECT @BeginDate=dbo.RemoveTimeFromDatetime(@BeginDate)
SELECT @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)

SELECT A.AgentCode AS AgentCode
	, B.PaymentDate AS DateOfTransfer
	, B.IdBillPayment AS Folio
	, B.ReceiptAmount AS Amount
	, B.Fee AS Fee
	, B.BillPaymentProviderFee AS ProviderFee
	, B.AgentCommission AS AgentCommission
	,B.CorpCommission AS CorpCommission
	, ba.BillerDescription AS Biller
FROM [dbo].[BillPaymentTransactions] B (NOLOCK)
	JOIN [dbo].[Agent] A (NOLOCK) on A.IdAgent = B.IdAgent
    join BillAccounts ba (NOLOCK) on b.BillAccountId=ba.IdBillAccounts
WHERE B.[Status] = 1 /*PAYED*/ AND
	B.PaymentDate >= @BeginDate AND 
	B.PaymentDate <= @EndDate
order by B.PaymentDate


