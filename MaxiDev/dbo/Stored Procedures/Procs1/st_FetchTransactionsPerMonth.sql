CREATE PROCEDURE st_FetchTransactionsPerMonth
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
		DATEPART(YEAR, t.DateOfTransfer) [Year], 
		DATEPART(MONTH, t.DateOfTransfer) [Month],
		COUNT(DISTINCT t.IdTransfer) Total
	FROM AllTransfers t
	GROUP BY DATEPART(YEAR, t.DateOfTransfer), DATEPART(MONTH, t.DateOfTransfer)
	ORDER BY [Year], [Month]
END
