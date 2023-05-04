CREATE PROCEDURE  [Corp].[st_InsertCollectionNotificationRule]
(
			@Name varchar(max)
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
		   ,@IdCollectionNotificationRule int out
)
	as
BEGIN

	SET NOCOUNT ON;
	BEGIN TRY
	SET @HasError=0;
	INSERT INTO [dbo].[CollectionNotificationRule]
           ([Name]
           ,[IdAgent]
           ,[IdAgentClass]
           ,[IdOwner]
           ,[IdCollectionNotificationRuleType]
           ,[Condition]
           ,[JSONMessage]
           ,[TEXTMessage]
           ,[ShowNotification]
           ,[SendFax]
           ,[CreationDate]
           ,[DateofLastChange]
           ,[EnterByIdUser]
           ,[IdStatus])
     VALUES
           (
			@Name
           ,@IdAgent 
           ,@IdAgentClass 
           ,@IdOwner 
           ,@IdCollectionNotificationRuleType 
           ,@Condition 
           ,@JSONMessage 
           ,@TEXTMessage 
           ,@ShowNotification 
           ,@SendFax 
           ,@CreationDate
           ,@DateofLastChange 
           ,@EnterByIdUser 
           ,@IdStatus )
		   Select @IdCollectionNotificationRule=SCOPE_IDENTITY();
	END TRY
	BEGIN CATCH
	SET @HasError=1;
	declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_InsertCollectionNotificationRule]',Getdate(),@ErrorMessage)                                                                                            
	END CATCH 

END

