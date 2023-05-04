
CREATE PROCEDURE st_FindIdIdAgentClassById
    @IdAgentClass int
AS
BEGIN

	SET NOCOUNT ON;

	SELECT [IdAgentClass] as [Id]
      ,[Name] as [Name]
  FROM [dbo].[AgentClass] WITH(NOLOCK) 
    WHERE IdAgentClass = @IdAgentClass
END
