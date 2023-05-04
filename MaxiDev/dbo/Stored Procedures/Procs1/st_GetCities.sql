CREATE PROCEDURE [dbo].[st_GetCities] 
	@IdState INT,
	@IdCity INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF (@IdCity > 0)
		BEGIN
			SELECT [IdCity], [IdState], [CityName], [DateOfLastChange], [EnterByIdUser]
			FROM [dbo].[City] WITH(NOLOCK)
			WHERE [IdCity] = @IdCity
		END
	ELSE IF (@IdState > 0)
		BEGIN
			SELECT [IdCity], [IdState], [CityName], [DateOfLastChange], [EnterByIdUser]
			FROM [dbo].[City] WITH(NOLOCK)
			WHERE [IdState] = @IdState
		END
	ELSE
		BEGIN
			SELECT [IdCity], [IdState], [CityName], [DateOfLastChange], [EnterByIdUser]
			FROM [dbo].[City] WITH(NOLOCK)
		END
END

