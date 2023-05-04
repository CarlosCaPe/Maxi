CREATE PROCEDURE [InternalSalesMonitor].[st_UpdateRepAgent]
(
	@IdAgent	int,
	@IdUserSeller int,
	@EnterByIdUser int,
    @HasError bit out,
	@Message varchar(max) out
)
AS
BEGIN TRY

SET @HasError = 0;
SET @Message ='';

	 UPDATE Agent  
	 SET 
	 [IdUserSeller] = @idUserSeller,
	 [EnterByIdUser] = @EnterByIdUser,
	 [DateOfLastChange] =  GETDATE()
	 WHERE [IdAgent] = @IdAgent;
SET @Message ='The Agent''s Rep was successfully updated.'
END TRY
Begin Catch
	Set @HasError = 1;
	Declare @ErrorMessage nvarchar(max);
	Select @ErrorMessage = ERROR_MESSAGE();
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('InternalSalesMonitor.st_UpdateNotes',Getdate(),@ErrorMessage);
End Catch


