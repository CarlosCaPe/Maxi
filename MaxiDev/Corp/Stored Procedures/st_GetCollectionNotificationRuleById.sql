CREATE PROCEDURE [Corp].[st_GetCollectionNotificationRuleById]
@IdCollectionNR int
	as
BEGIN

	SET NOCOUNT ON;


SELECT [Name] 
      ,[IdAgent] 
      ,[IdAgentClass] 
      ,[IdOwner] 
	  ,IdCollectionNotificationRule
      ,[IdCollectionNotificationRuleType] 
      ,[Condition] 
      ,[JSONMessage] 
      ,[TEXTMessage] 
      ,[ShowNotification] 
      ,[SendFax] 
      ,[CreationDate] 
      ,[DateofLastChange] 
      ,[EnterByIdUser] 
      ,[IdStatus] 
	  from CollectionNotificationRule WITH(NOLOCK)
  WHERE IdCollectionNotificationRule= @IdCollectionNR
  
END

