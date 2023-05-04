CREATE PROCEDURE [Corp].[st_UpdateCollectionNotificationRule]
(
			@Name varchar(max)
		   ,@IdCollectionNotificationRule int 
           ,@IdAgent int
           ,@IdAgentClass int
           ,@IdOwner int
           ,@IdCollectionNotificationRuleType int
           ,@Condition int
           ,@JSONMessage varchar(max)
           ,@TEXTMessage varchar(max)
           ,@ShowNotification bit
           ,@SendFax bit
           ,@CreationDate datetime
           ,@DateofLastChange datetime
           ,@EnterByIdUser int
           ,@IdStatus int
		   ,@HasError bit out
		  
)
	as
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
	SET @HasError=0;
	UPDATE [dbo].[CollectionNotificationRule]
   SET [Name] =@Name
      ,[IdAgent] = @IdAgent
      ,[IdAgentClass] = @IdAgentClass
      ,[IdOwner] = @IdOwner
      ,[IdCollectionNotificationRuleType] = @IdCollectionNotificationRuleType
      ,[Condition] = @Condition
      ,[JSONMessage] = @JSONMessage
      ,[TEXTMessage] = @TEXTMessage
      ,[ShowNotification] = @ShowNotification
      ,[SendFax] = @SendFax
      ,[CreationDate] = @CreationDate
      ,[DateofLastChange] = @DateofLastChange
      ,[EnterByIdUser] = @EnterByIdUser
      ,[IdStatus] = @IdStatus
 WHERE IdCollectionNotificationRule= @IdCollectionNotificationRule

	END TRY
	BEGIN CATCH
	SET @HasError=1;
	declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateCollectionNotificationRule]',Getdate(),@ErrorMessage)                                                                                            
	END CATCH 

END

