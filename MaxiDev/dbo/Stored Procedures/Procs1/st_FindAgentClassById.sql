
CREATE PROCEDURE [dbo].[st_FindAgentClassById]
    @IdAgentClass int
AS
BEGIN

	SET NOCOUNT ON;

    SELECT [IdAgentClass] as [Id] 
      ,[Name] as  [Name]
    FROM [dbo].[AgentClass]
	WHERE IdAgentClass = @IdAgentClass

END