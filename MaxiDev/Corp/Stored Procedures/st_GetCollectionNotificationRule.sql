CREATE PROCEDURE  [Corp].[st_GetCollectionNotificationRule]
	as
BEGIN

	SET NOCOUNT ON;

SELECT
	   A.AgentName
	   ,A.AgentCode
	   ,CNR.[Condition]
      ,CNR.[IdAgent]
      ,CNR.[IdAgentClass]
      ,O.[IdOwner]
	  ,CNR.[IdCollectionNotificationRule]
      ,CNR.[IdCollectionNotificationRuleType]
        ,CNR.[Name]
		,CNR.[ShowNotification]
		,CNR.[SendFax]
      ,CNR.[JSONMessage]
	  ,CONCAT(O.Name,' ',O.LastName,' ',O.LastName) AS 'OwnerName'
	  ,O.Name
	  ,O.LastName
	  ,O.LastName
  FROM [dbo].[CollectionNotificationRule] CNR with(nolock)
  LEFT JOIN [dbo].[Owner] O with(nolock) ON O.IdOwner=CNR.IdOwner
  LEFT JOIN [dbo].Agent A with(nolock) ON A.IdAgent=CNR.IdAgent
  WHERE CNR.IdStatus = 1

END

