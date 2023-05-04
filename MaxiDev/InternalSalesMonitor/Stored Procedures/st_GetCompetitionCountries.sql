CREATE PROCEDURE [InternalSalesMonitor].[st_GetCompetitionCountries]
AS
--SELECT [IdCompetitionCountry],[Name]
--FROM [dbo].[CompetitionCountry]
SELECT 
IdCountry AS IdCompetitionCountry,
CountryName AS Name
FROM Country 
ORDER BY Name
