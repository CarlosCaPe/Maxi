CREATE PROCEDURE [dbo].[st_FindFeeById]
(
	@IdFee	        INT
	
)
AS
BEGIN
	SELECT
	cc.IdFee, cc.FeeName, cc.DateOfLastChange, cc.EnterByIdUser
	FROM Fee cc WITH(NOLOCK)
	JOIN FeeDetail pc WITH(NOLOCK) ON cc.IdFee = pc.IdFee
	WHERE cc.IdFee = @IdFee

END