CREATE PROCEDURE [dbo].[st_FindFeeDetailById]
(
	@IdFee  INT
)
AS
BEGIN
  SELECT
	pc.IdFeeDetail,pc.IdFee, pc.FromAmount, pc.ToAmount, pc.Fee, 
	pc.DateOfLastChange, pc.EnterByIdUser, pc.IsFeePercentage
	FROM FeeDetail pc
	WHERE pc.IdFee = @IdFee;
	
END