
CREATE PROCEDURE [dbo].[st_FindCommissionById]
    @IdCommission int
AS
BEGIN

	SELECT
		c.IdCommission,
		c.CommissionName,
		c.DateOfLastChange,
		c.EnterByIdUser
	FROM Commission c WITH(NOLOCK)
	WHERE c.IdCommission = @IdCommission



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
	WHERE cd.IdCommission = @IdCommission
END
