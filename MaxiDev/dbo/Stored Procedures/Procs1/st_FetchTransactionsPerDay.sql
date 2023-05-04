CREATE PROCEDURE st_FetchTransactionsPerDay
(
	@IdAgent		INT,
	@StartDate		DATE,
	@EndDate		DATE
)
AS
BEGIN

	;WITH AllTransfers (IdTransfer, DateOfTransfer) 
	AS
	(
		SELECT
			t.IdTransfer,
			t.DateOfTransfer
		FROM Transfer t WITH(NOLOCK)
		WHERE
			t.IdAgent = @IdAgent
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
		UNION
		SELECT
			t.IdTransferClosed,
			t.DateOfTransfer
		FROM TransferClosed t WITH(NOLOCK)
		WHERE
			t.IdAgent = @IdAgent
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
	)
	SELECT 
		CONVERT(DATE, t.DateOfTransfer) DateOfTransfer,
		COUNT(DISTINCT t.IdTransfer) Total
	FROM AllTransfers t
	GROUP BY CONVERT(DATE, t.DateOfTransfer)
	ORDER BY CONVERT(DATE, t.DateOfTransfer)
END
