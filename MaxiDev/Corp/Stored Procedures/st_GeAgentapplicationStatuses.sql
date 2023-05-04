CREATE PROCEDURE  [Corp].[st_GeAgentapplicationStatuses] 
	as
BEGIN

	SET NOCOUNT ON;


SELECT [IdAgentApplicationStatus]
      ,[StatusCodeName]
      ,[StatusName]
      ,[VisibleForUser]
      ,[DateOfLastChange]
      ,[IdUserLastChange]
      ,[IsHold]
  FROM [dbo].[AgentApplicationStatuses] with (nolock)


END
