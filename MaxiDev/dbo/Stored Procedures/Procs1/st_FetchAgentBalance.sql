CREATE PROCEDURE st_FetchAgentBalance
(
	@StartDate		DATE,
	@EndingDate		DATE,
	@Amount			MONEY
)
AS
BEGIN	

	SELECT
		ab.*
	FROM AgentBalance ab WITH(NOLOCK)
		JOIN AgentDeposit ad WITH(NOLOCK) ON ad.IdAgentBalance = ab.IdAgentBalance
	WHERE
		CONVERT(DATE, ab.DateOfMovement) BETWEEN @StartDate AND @EndingDate
		AND NOT EXISTS (SELECT 1 FROM ConciliationMatch cm WITH(NOLOCK) WHERE cm.IdAgentDeposit = ad.IdAgentDeposit)
		AND (@Amount IS NULL OR ab.Amount = @Amount)
END
