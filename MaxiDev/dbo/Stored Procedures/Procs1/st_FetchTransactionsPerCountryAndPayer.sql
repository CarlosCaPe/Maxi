CREATE PROCEDURE st_FetchTransactionsPerCountryAndPayer
(
	@IdAgent		INT,
	@StartDate		DATE,
	@EndDate		DATE
)
AS
BEGIN

	;WITH AllTransfers (IdTransfer, DateOfTransfer, IdCountryCurrency, IdPayer) 
	AS
	(
		SELECT
			t.IdTransfer,
			t.DateOfTransfer,
			t.IdCountryCurrency,
			t.IdPayer
		FROM Transfer t WITH(NOLOCK)
		WHERE
			t.IdAgent = @IdAgent
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
		UNION
		SELECT
			t.IdTransferClosed,
			t.DateOfTransfer,
			t.IdCountryCurrency,
			t.IdPayer
		FROM TransferClosed t WITH(NOLOCK)
		WHERE
			t.IdAgent = @IdAgent
			AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @StartDate AND @EndDate
	)
	SELECT 
		c.IdCountry,
		MAx(c.CountryName) CountryName,
		p.IdPayer,
		MAX(p.PayerName) PayerName,
		COUNT(DISTINCT t.IdTransfer) Total
	FROM AllTransfers t
		JOIN CountryCurrency cc WITH(NOLOCK) ON t.IdCountryCurrency = cc.IdCountryCurrency
		JOIN Country c WITH (NOLOCK) ON c.IdCountry = cc.IdCountry

		JOIN Payer p WITH(NOLOCK) ON p.IdPayer = t.IdPayer
	GROUP BY c.IdCountry, p.IdPayer
	ORDER BY c.IdCountry, p.IdPayer
END
