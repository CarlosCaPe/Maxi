CREATE PROCEDURE st_FetchTransactionsPerCountry
(
	@IdAgent		INT,
	@StartDate		DATE,
	@EndDate		DATE
)
AS
BEGIN

	;WITH AllTransfers (IdTransfer, DateOfTransfer, IdCountryCurrency) 
	AS
	(
		SELECT
			t.IdTransfer,
			t.DateOfTransfer,
			t.IdCountryCurrency
		FROM Transfer t WITH(NOLOCK)
		WHERE
			t.IdAgent = @IdAgent
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
		UNION
		SELECT
			t.IdTransferClosed,
			t.DateOfTransfer,
			t.IdCountryCurrency
		FROM TransferClosed t WITH(NOLOCK)
		WHERE
			t.IdAgent = @IdAgent
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
	)
	SELECT 
		c.IdCountry,
		MAx(c.CountryName) CountryName,
		COUNT(DISTINCT t.IdTransfer) Total
	FROM AllTransfers t
		JOIN CountryCurrency cc WITH(NOLOCK) ON t.IdCountryCurrency = cc.IdCountryCurrency
		JOIN Country c WITH (NOLOCK) ON c.IdCountry = cc.IdCountry
	GROUP BY c.IdCountry
	ORDER BY c.IdCountry
END
