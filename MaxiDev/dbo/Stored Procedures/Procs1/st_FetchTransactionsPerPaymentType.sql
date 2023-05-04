CREATE PROCEDURE st_FetchTransactionsPerPaymentType
(
	@IdAgent		INT,
	@StartDate		DATE,
	@EndDate		DATE
)
AS
BEGIN

	;WITH AllTransfers (IdTransfer, DateOfTransfer, IdPaymentType) 
	AS
	(
		SELECT
			t.IdTransfer,
			t.DateOfTransfer,
			t.IdPaymentType
		FROM Transfer t WITH(NOLOCK)
		WHERE
			t.IdAgent = @IdAgent
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
		UNION
		SELECT
			t.IdTransferClosed,
			t.DateOfTransfer,
			t.IdPaymentType
		FROM TransferClosed t WITH(NOLOCK)
		WHERE
			t.IdAgent = @IdAgent
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
	)
	SELECT 
		t.IdPaymentType,
		MAX(pt.PaymentName) PaymentName,
		COUNT(DISTINCT t.IdTransfer) Total
	FROM AllTransfers t
		JOIN PaymentType pt WITH(NOLOCK) ON pt.IdPaymentType = t.IdPaymentType
	GROUP BY t.IdPaymentType
	ORDER BY t.IdPaymentType
END
