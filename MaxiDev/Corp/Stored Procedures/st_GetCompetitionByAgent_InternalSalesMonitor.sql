CREATE PROCEDURE [Corp].[st_GetCompetitionByAgent_InternalSalesMonitor]
@IdAgent AS INT
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

DECLARE @IdAgentApplication AS INT = 0
SET @IdAgentApplication = (SELECT TOP 1 IdAgentApplication FROM RelationAgentApplicationWithAgent WITH(NOLOCK) WHERE IdAgent = @IdAgent)
IF (@IdAgentApplication > 0)
BEGIN
	SELECT [IdAgentApplicationCompetition] AS IdCompetition
      ,[Transmitter]
      ,[Country] FROM [AgentApplicationCompetition] WITH(NOLOCK) WHERE IdAgentApplication = @IdAgentApplication
END
ELSE
BEGIN 
	SELECT [IdAgentCompetition] AS IdCompetition
      ,[Transmitter]
      ,[Country] FROM [InternalSalesMonitor].[AgentCompetition] WITH(NOLOCK) WHERE IdAgent = @IdAgent
END

