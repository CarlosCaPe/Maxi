CREATE PROCEDURE [dbo].[st_FindCity]
(
	@IdCountry INT,
	@IdState   INT,
	@IdCity    INT
)
AS
BEGIN

	SELECT cc.IdCity, cc.CityName, cc.DateOfLastChange, cc.EnterByIdUser FROM City cc WITH(NOLOCK)
		JOIN State pc WITH(NOLOCK) ON pc.IdState = cc.IdState
		JOIN Country p WITH(NOLOCK) ON pc.IdCountry = p.IdCountry
		  WHERE cc.IdCity=@IdCity AND pc.IdState=@IdState AND p.IdCountry=@IdCountry;
	
END
