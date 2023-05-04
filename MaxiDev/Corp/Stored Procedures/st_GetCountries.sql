CREATE PROCEDURE [Corp].[st_GetCountries] 
	@IdCountry INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@IdCountry = 0)
		BEGIN 
			SELECT [IdCountry], [CountryName], [CountryCode], [DateOfLastChange], [EnterByIdUser]
			FROM [dbo].[Country] WITH(NOLOCK)
			ORDER BY [IdCountry]
		END 
	ELSE
		BEGIN
			SELECT [IdCountry], [CountryName], [CountryCode], [DateOfLastChange], [EnterByIdUser]
			FROM [dbo].[Country] WITH(NOLOCK)
			WHERE [IdCountry] = @IdCountry
			ORDER BY [IdCountry]
		END
END
