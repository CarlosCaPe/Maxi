CREATE PROCEDURE [Corp].[st_SaveNotification]
(
	@Id int = 0,
	@IdAgentApplication int,
	@IdSeller int,
	@IdNotificationType int,
	@DateOfLastChange datetime,
	@Title nvarchar(max),
	@ReadedByUser bit,
	@IdUserLastChange int
)
AS
/********************************************************************
<Author></Author>
<app>MaxiCorp</app>
<Description>Save Notification</Description>
<ChangeLog>
<log Date="15/11/2019" Author="esalazar">Creation</log>
</ChangeLog>
*************************/
BEGIN TRY

IF(@Id =0)
BEGIN
INSERT INTO [dbo].[Notifications]
           ([IdAgentApplication]
           ,[IdSeller]
           ,[IdNotificationType]
           ,[Title]
           ,[ReadedByUser]
           ,[DateOfLastChange]
           ,[IdUserLastChange])
     VALUES
           (@IdAgentApplication,
           @IdSeller, 
           @IdNotificationType,
           @Title,
           @ReadedByUser,
           @DateOfLastChange,
           @IdUserLastChange)
END
ELSE
BEGIN 
	IF EXISTS(SELECT TOP 1 1 FROM Notifications WITH(NOLOCK) WHERE IdNotification = @Id)
	BEGIN
		UPDATE [dbo].[Notifications]
	   SET [IdAgentApplication] = @IdAgentApplication
		  ,[IdSeller] = @IdSeller
		  ,[IdNotificationType] = @IdNotificationType
		  ,[Title] = @Title
		  ,[ReadedByUser] = @ReadedByUser
		  ,[DateOfLastChange] = @DateOfLastChange
		  ,[IdUserLastChange] = @IdUserLastChange
	 WHERE IdNotification = @Id
	END
END


END TRY
BEGIN CATCH
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select  @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveNotification',Getdate(),@ErrorMessage)
END CATCH
