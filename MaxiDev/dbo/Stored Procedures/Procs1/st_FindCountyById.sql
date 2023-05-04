CREATE PROCEDURE [dbo].[st_FindCountyById]
(
	@IdCountry  INT,
	@IdState   INT,
	@IdCounty    INT
)
AS
BEGIN
	SELECT cc.IdCounty, cc.CountyName, cc.DateOfLastChange, cc.EnterByIdUser FROM County cc WITH(NOLOCK)
		JOIN State pc WITH(NOLOCK) ON pc.IdState = cc.IdState
		JOIN Country p WITH(NOLOCK) ON pc.IdCountry = p.IdCountry
		  WHERE cc.IdCounty=@IdCounty AND pc.IdState=@IdState AND p.IdCountry=@IdCountry;
	
END