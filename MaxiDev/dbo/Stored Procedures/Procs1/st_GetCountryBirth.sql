CREATE PROCEDURE [dbo].[st_GetCountryBirth]
AS

	SELECT
		[IdCountryBirth]
		, [Country]
		, [CountryEs]
	FROM [dbo].[CountryBirth] WITH (NOLOCK)

