CREATE PROCEDURE [dbo].[st_FetchCommission]
(
	@Name			VARCHAR(200),
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

	DECLARE @Records TABLE (Id INT, _PagedResult_Total BIGINT)

	INSERT INTO @Records(Id, _PagedResult_Total)
	SELECT
		c.IdCommission,
		COUNT(*) OVER() _PagedResult_Total
	FROM Commission c WITH(NOLOCK)
	WHERE
		(@Name IS NULL OR c.CommissionName LIKE CONCAT('%', @Name ,'%'))
	ORDER BY IdCommission
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY


	SELECT
		c.IdCommission,
		c.CommissionName,
		c.DateOfLastChange,
		c.EnterByIdUser,
		r._PagedResult_Total
	FROM Commission c WITH(NOLOCK)
		JOIN @Records r ON r.Id = c.IdCommission

	SELECT
		cd.IdCommissionDetail,
		cd.IdCommission,
		cd.FromAmount,
		cd.ToAmount,
		cd.AgentCommissionInPercentage,
		cd.CorporateCommissionInPercentage,
		cd.DateOfLastChange,
		cd.EnterByIdUser,
		cd.ExtraAmount
	FROM CommissionDetail cd WITH(NOLOCK)
		JOIN @Records r ON r.Id = cd.IdCommission

END
