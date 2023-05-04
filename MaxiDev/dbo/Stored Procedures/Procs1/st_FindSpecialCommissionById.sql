CREATe PROCEDURE st_FindSpecialCommissionById
(
	@IdAgent						INT,
	@IdSpecialCommissionBalance		INT
)
AS
BEGIN


	SELECT
		sc.*,
		sce.*
	FROM SpecialCommissionBalance sc WITH(NOLOCK)
		LEFT JOIN SpecialCommissionBalanceExternal sce WITH(NOLOCK) ON sce.IdSpecialCommissionBalance = sc.IdSpecialCommissionBalance
	WHERE sc.IdSpecialCommissionBalance = @IdSpecialCommissionBalance
	AND sc.IdAgent = @IdAgent

END
