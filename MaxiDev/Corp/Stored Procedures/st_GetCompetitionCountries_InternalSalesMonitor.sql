CREATE PROCEDURE [Corp].[st_GetCompetitionCountries_InternalSalesMonitor]
AS
--SELECT [IdCompetitionCountry],[Name]
--FROM [dbo].[CompetitionCountry]

/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="04/10/2019" Author="jzuniga">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

SELECT 
IdCountry AS IdCompetitionCountry,
CountryName AS Name
FROM Country WITH(NOLOCK)
ORDER BY Name
