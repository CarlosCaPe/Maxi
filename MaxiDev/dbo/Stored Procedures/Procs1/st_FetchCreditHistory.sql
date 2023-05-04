CREATE PROCEDURE st_FetchCreditHistory
(
	@IdAgent		INT,
	@StartDate		DATE,
	@EndDate		DATE
)
AS
BEGIN


	SELECT
		CONVERT(DATE, ad.DepositDate) DepositDate,
		SUM(ad.Amount) Credit
	FROM AgentDeposit ad WITH(NOLOCK)
	WHERE 
		ad.IdAgent = @IdAgent
		AND CONVERT(DATE, ad.DepositDate) BETWEEN @StartDate AND @EndDate
	GROUP BY CONVERT(DATE, ad.DepositDate)
	ORDER BY DepositDate

END
