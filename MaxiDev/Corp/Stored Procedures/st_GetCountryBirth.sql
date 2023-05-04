CREATE PROCEDURE [Corp].[st_GetCountryBirth]
AS
	SELECT
		[IdCountryBirth]
		, [Country]
		, [CountryEs]
	FROM [dbo].[CountryBirth] WITH (NOLOCK)

