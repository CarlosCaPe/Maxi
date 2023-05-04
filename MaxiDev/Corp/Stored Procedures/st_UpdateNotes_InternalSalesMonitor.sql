CREATE PROCEDURE [Corp].[st_UpdateNotes_InternalSalesMonitor]
(
	@IdNote		int,
	@IdAgent	int,
	@IdNoteType int,
	@Note varchar(250),
	@EnterByIdUser int,
    @HasError bit out,
	@Message varchar(max) out
)
as
Begin Try

set @HasError = 0;
Set @Message ='';

DECLARE @CreationDate datetime;
SET @CreationDate = GETDATE();

IF(ISNULL(@Note,'') = '')
BEGIN
	Set @HasError = 1;
	Set @Message ='The Note is empty.'
	RAISERROR(@Message,16,1);
END

IF(@IdNote = 0)
BEGIN	
	INSERT INTO [InternalSalesMonitor].[Notes]
           ([IdAgent]
           ,[IdNoteType]
           ,[Note]
           ,[EnterByIdUser]
           ,[CreationDate])
     VALUES
           (@IdAgent
           ,@IdNoteType
           ,@Note
           ,@EnterByIdUser
           ,@CreationDate);
END
ELSE
BEGIN
	UPDATE [InternalSalesMonitor].[Notes]
	   SET 
			--[IdAgent] = @IdAgent,
		  [IdNoteType] = @IdNoteType
		  ,[Note] = @Note
		  ,[EnterByIdUser] = @EnterByIdUser
		  ,[CreationDate] =  @CreationDate
	 WHERE IdNote = @IdNote;
END
SET @Message ='The note was successfully saved.'
End Try
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_UpdateNotes_InternalSalesMonitor]',Getdate(),@ErrorMessage);
End Catch

