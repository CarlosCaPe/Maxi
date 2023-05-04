CREATe PROCEDURE st_FetchSpecialCommissions
(
	@IdAgent		INT,
	@DateFrom		DATE,
	@DateTo			DATE,

	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN


	SELECT
		COUNT(*) OVER() _PagedResult_Total,
		sc.*,
		sce.*
	FROM SpecialCommissionBalance sc WITH(NOLOCK)
		LEFT JOIN SpecialCommissionBalanceExternal sce WITH(NOLOCK) ON sce.IdSpecialCommissionBalance = sc.IdSpecialCommissionBalance
	WHERE 
		sc.IdAgent = @IdAgent
		AND sc.DateOfMovement BETWEEN @DateFrom AND @DateTo
	ORDER BY sc.IdSpecialCommissionBalance
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END
