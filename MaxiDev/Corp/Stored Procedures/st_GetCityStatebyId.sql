CREATE PROCEDURE [Corp].[st_GetCityStatebyId]
	@IdCity INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@IdCity > 0)
		BEGIN
			SELECT c.[IdCity], c.[IdState], c.[CityName], c.[DateOfLastChange], c.[EnterByIdUser], s.[StateName]
			FROM [dbo].[City] as c WITH(NOLOCK)
			left join [dbo].[State] as s WITH(NOLOCK) ON c.[IdState] = s.[IdState]
			WHERE [IdCity] = @IdCity
		END
END