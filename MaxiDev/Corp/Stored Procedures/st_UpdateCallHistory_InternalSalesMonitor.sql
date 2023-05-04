CREATE PROCEDURE [Corp].[st_UpdateCallHistory_InternalSalesMonitor]
(
	@IdCallHistory	int,
	@IdAgent	int,
	@IdTaskStatus	int,
    @IdTaskPriority	int,
	@Note varchar(500),
	@EnterByIdUser int,
    @HasError bit out,
	@Message varchar(max) out
)
as
Begin Try

set @HasError = 0;
Set @Message ='';
DECLARE @CreationDate datetime;


IF(ISNULL(@Note,'') = '')
BEGIN
	Set @HasError = 1;
	Set @Message ='The Note is empty.'
	RAISERROR(@Message,16,1);
END

IF(@IdCallHistory = 0)
BEGIN	
	SET @CreationDate = GETDATE();
	INSERT INTO [InternalSalesMonitor].[CallHistory]
           ([IdAgent]
           ,[IdTaskStatus]
           ,[IdTaskPriority]
           ,[Note]
           ,[EnterByIdUser]
           ,[CreationDate]
           ,[LastChangeByIdUser]
           ,[DateOfLastChange])
     VALUES
           (@IdAgent
           ,@IdTaskStatus
           ,@IdTaskPriority
           ,@Note
           ,@EnterByIdUser
		   ,GETDATE()
           ,NULL
		   ,NULL);
END
ELSE
BEGIN
	UPDATE [InternalSalesMonitor].[CallHistory]
	   SET
		  [IdAgent] = @IdAgent,
		  [IdTaskStatus] = @IdTaskStatus
		  ,[IdTaskPriority] = @IdTaskPriority
		  ,[Note] = @Note
		  ,[LastChangeByIdUser] = @EnterByIdUser
		  ,[DateOfLastChange] = GETDATE()
	 WHERE IdCallHistory = @IdCallHistory;
END
SET @Message ='The Task was successfully saved.'
End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateCallHistory_InternalSalesMonitor]',Getdate(),@ErrorMessage);
End Catch

