
create PROCEDURE [dbo].[st_SaveChangesToTransferLog_TEMP_ERROR]
(
@IdTransfer INT,
@IdStatus INT,
@Note NVARCHAR(MAX)

)
AS
/*
CHANGES CONTROLS
1/FEb/2012  by hmg  added insert additional note if is different than empty or null

 */          
SET NOCOUNT ON
BEGIN TRY

	update Transfer set  IdStatus=@IdStatus  where IdTransfer=@IdTransfer

	DECLARE @IdValue INT, @IdSystemUser INT
	INSERT INTO [dbo].[TransferDetail] ([IdStatus], [IdTransfer], [DateOfMovement]) VALUES (@IdStatus, @IdTransfer, GETDATE())
	SELECT @IdValue=SCOPE_IDENTITY()


          
	
		SELECT @IdSystemUser=dbo.GetGlobalAttributeByName('SystemUserID')
		INSERT INTO [dbo].[TransferNote] ([IdTransferDetail], [IdTransferNoteType], [IdUser], [Note], [EnterDate]) VALUES (@IdValue, 1, @IdSystemUser, @Note, GETDATE())
		
	
	
	



END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_SaveChangesToTransferLog_TEMP_ERROR', GETDATE(), @ErrorMessage)
END CATCH
