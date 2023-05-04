CREATE PROCEDURE [Corp].[st_GetCompetitionTransmitters_InternalSalesMonitor]
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="04/10/2019" Author="jzuniga">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

SELECT [IdCompetitionTransmitter],[Name]
FROM [dbo].[CompetitionTransmitter] WITH(NOLOCK) ORDER BY Name 
