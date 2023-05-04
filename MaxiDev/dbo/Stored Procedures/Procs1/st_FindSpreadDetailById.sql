CREATE PROCEDURE [dbo].[st_FindSpreadDetailById]
(
	@IdSpread  INT
)
AS
BEGIN
  SELECT
	pc.IdSpreadDetail,pc.IdSpread, pc.FromAmount, pc.ToAmount, pc.SpreadValue, 
	pc.DateOfLastChange, pc.EnterByIdUser
	FROM SpreadDetail pc
	WHERE pc.IdSpread = @IdSpread;
	
END