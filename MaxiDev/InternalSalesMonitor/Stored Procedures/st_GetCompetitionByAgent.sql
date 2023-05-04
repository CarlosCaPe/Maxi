CREATE PROCEDURE [InternalSalesMonitor].[st_GetCompetitionByAgent]
@IdAgent AS INT
AS
DECLARE @IdAgentApplication AS INT = 0
SET @IdAgentApplication = (SELECT TOP 1 IdAgentApplication FROM RelationAgentApplicationWithAgent WHERE IdAgent = @IdAgent)
IF (@IdAgentApplication > 0)
BEGIN
	SELECT [IdAgentApplicationCompetition] AS IdCompetition
      ,[Transmitter]
      ,[Country] FROM [AgentApplicationCompetition] WHERE IdAgentApplication = @IdAgentApplication
END
ELSE
BEGIN 
	SELECT [IdAgentCompetition] AS IdCompetition
      ,[Transmitter]
      ,[Country] FROM [AgentCompetition] WHERE IdAgent = @IdAgent
END


