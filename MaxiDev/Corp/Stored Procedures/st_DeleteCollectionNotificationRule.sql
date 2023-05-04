CREATE PROCEDURE  [Corp].[st_DeleteCollectionNotificationRule]
@idUser int,
@idCollectionNotificationRule int,
@hasError bit out,
@Message varchar(max) out
	as
BEGIN
SET @hasError=0
SET @Message='Collection Notification Rule was successfully deleted'
	SET NOCOUNT ON;


	BEGIN TRY
	 
	UPDATE [dbo].[CollectionNotificationRule]
   SET 
      [DateofLastChange] = GETDATE()
      ,[EnterByIdUser] =@idUser
	  ,IdStatus=2
      WHERE IdCollectionNotificationRule = @idCollectionNotificationRule

	END TRY
	BEGIN CATCH
	SET @hasError=1;
	declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()
	SET @Message = @ErrorMessage                                          
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_DeleteCollectionNotificationRule]',Getdate(),@ErrorMessage)                                                                                            
	END CATCH 

END

