
CREATE PROCEDURE st_FindAgentTypeById
    @IdAgentType int
AS
BEGIN

	SET NOCOUNT ON;

	SELECT [IdAgentType] as [Id] 
      ,[Name] as  [Name]
  FROM [dbo].[AgentType]
  WHERE IdAgentType = @IdAgentType

END
