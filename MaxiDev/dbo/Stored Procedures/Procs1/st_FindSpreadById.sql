CREATE PROCEDURE [dbo].[st_FindSpreadById]
(
	@IdSpread	        INT
	
)
AS
BEGIN
	SELECT
	cc.IdSpread, cc.SpreadName, cc.DateOfLastChange, cc.EnterByIdUser, cc.IdCountryCurrency
	FROM Spread cc WITH(NOLOCK)
	JOIN SpreadDetail pc WITH(NOLOCK) ON cc.IdSpread = pc.IdSpread
	WHERE cc.IdSpread = @IdSpread

END