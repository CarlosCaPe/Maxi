
CREATE PROCEDURE st_FindAgentStatusById
    @IdAgentStatus int
AS
BEGIN

	SET NOCOUNT ON;

    SELECT [IdAgentStatus] as [Id] 
      ,[AgentStatus] as  [Name]
    FROM [dbo].[AgentStatus]
	WHERE IdAgentStatus = @IdAgentStatus

END
