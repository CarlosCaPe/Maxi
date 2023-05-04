CREATE PROCEDURE [dbo].[st_FindRejected]
(
@StartDate datetime,
@EndDate datetime,
@FlagReview int
)
as
SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


SELECT @StartDate= dbo.RemoveTimeFromDatetime(@StartDate)
SELECT @EndDate= dbo.RemoveTimeFromDatetime(@EndDate)
SET @EndDate=DATEADD(DAY,1,@EndDate)


SELECT
A.ClaimCode, 
A.IdAgent,
B.AgentCode,
A.CustomerName,
A.CustomerFirstLastName,
A.CustomerSecondLastName,
B.AgentName,
A.DateOfTransfer,
A.IdTransfer,
A.Folio,
C.PayerName,
A.AmountInDollars,
A.IdStatus,
D.StatusName,
E.PhysicalIdCopy,
A.ReviewDenyList,
A.ReviewOfac,
A.ReviewKyc,
ISNULL(A.ReviewRejected,0)  ReviewRejected,
A.IdBeneficiary,
A.IdCustomer
, CASE
    WHEN EXISTS (SELECT TOP 1 1 FROM [dbo].[TransferHolds] TH WHERE TH.[IdStatus]=9 AND TH.[IdTransfer] = A.[IdTransfer] AND TH.[IsReleased]=0) THEN CONVERT(BIT,1)
    ELSE CONVERT(BIT,0)
    END WasRejectedByKycHold
FROM [dbo].[Transfer] A
LEFT JOIN [dbo].[Agent] B ON (A.IdAgent=B.IdAgent)
LEFT JOIN [dbo].[Payer] C ON (A.IdPayer=C.IdPayer)
LEFT JOIN [dbo].[Status] D ON (A.IdStatus=D.IdStatus)
LEFT JOIN [dbo].[Customer] E ON (A.IdCustomer=E.IdCustomer)
LEFT JOIN [dbo].[TransferDetail] F ON (F.IdTransfer=A.IdTransfer)
WHERE A.IdStatus=31 AND F.IdStatus=31 AND F.DateOfMovement>=@StartDate AND F.DateOfMovement<@EndDate AND
ISNULL(A.ReviewRejected,0) =  CASE WHEN @FlagReview=1 THEN 0 --Not Review
                                   WHEN @FlagReview=2 THEN 1 --Reviewed
                                   WHEN @FlagReview=3 THEN ISNULL(A.ReviewRejected,0) END--Both
                        
UNION                        

SELECT
A.ClaimCode, 
A.IdAgent,
B.AgentCode,
A.CustomerName,
A.CustomerFirstLastName,
A.CustomerSecondLastName,
B.AgentName,
A.DateOfTransfer,
A.IdTransferClosed AS IdTransfer,
A.Folio,
A.PayerName,
A.AmountInDollars,
A.IdStatus,
A.StatusName,
E.PhysicalIdCopy,
A.ReviewDenyList,
A.ReviewOfac,
A.ReviewKyc,
ISNULL(A.ReviewRejected,0)  ReviewRejected,
A.IdBeneficiary,
A.IdCustomer
, CASE
    WHEN EXISTS (SELECT TOP 1 1 FROM [dbo].[TransferClosedHolds] TCH WHERE TCH.[IdStatus]=9 AND TCH.[IdTransferClosed] = A.[IdTransferClosed] AND TCH.[IsReleased]=0) THEN CONVERT(BIT,1)
    ELSE CONVERT(BIT,0)
    END WasRejectedByKycHold
FROM [dbo].[TransferClosed] A
LEFT JOIN Agent B ON (A.IdAgent=B.IdAgent)
LEFT JOIN Customer E ON (A.IdCustomer=E.IdCustomer)
LEFT JOIN TransferClosedDetail F ON (F.IdTransferClosed=A.IdTransferClosed)
WHERE A.IdStatus=31 AND F.IdStatus=31 AND F.DateOfMovement>=@StartDate  AND F.DateOfMovement<@EndDate AND
ISNULL(A.ReviewRejected,0)=  CASE WHEN @FlagReview=1 THEN 0 --Not Review
                                  WHEN @FlagReview=2 THEN 1 --Reviewed
                                  WHEN @FlagReview=3 THEN ISNULL(A.ReviewRejected,0) END--Both



