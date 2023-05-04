CREATE PROCEDURE [InternalSalesMonitor].[st_GetCompetitionTransmitters]
AS
SELECT [IdCompetitionTransmitter],[Name]
FROM [dbo].[CompetitionTransmitter] ORDER BY Name 
