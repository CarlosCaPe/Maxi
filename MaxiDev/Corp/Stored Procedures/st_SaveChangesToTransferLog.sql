CREATE PROCEDURE [Corp].[st_SaveChangesToTransferLog]
(
@IdTransfer INT,
@IdStatus INT,
@Note NVARCHAR(MAX),
@IdUser INT,
@CreateNote BIT = 0
)
AS
/*
CHANGES CONTROLS
1/FEb/2012  by hmg  added insert additional note if is different than empty or null

 */          
SET NOCOUNT ON
BEGIN TRY

	DECLARE @IdValue INT, @IdSystemUser INT
	INSERT INTO [dbo].[TransferDetail] ([IdStatus], [IdTransfer], [DateOfMovement]) VALUES (@IdStatus, @IdTransfer, GETDATE())
	SELECT @IdValue=SCOPE_IDENTITY()

	DECLARE @NoteAdditional NVARCHAR(MAX)
	SELECT @NoteAdditional = COALESCE(NoteAdditional,'') FROM [dbo].[Transfer] WITH (NOLOCK)
	WHERE [IdTransfer] = @IDTransfer
          
	IF @IdUser=0
	BEGIN
		SELECT @IdSystemUser=dbo.GetGlobalAttributeByName('SystemUserID')
		INSERT INTO [dbo].[TransferNote] ([IdTransferDetail], [IdTransferNoteType], [IdUser], [Note], [EnterDate]) VALUES (@IdValue, 1, @IdSystemUser, @Note, GETDATE())
		IF (@NoteAdditional <> '' AND @CreateNote = 1)
		BEGIN
			INSERT INTO [dbo].[TransferNote] ([IdTransferDetail], [IdTransferNoteType], [IdUser], [Note], [EnterDate]) VALUES (@IdValue, 1, @IdSystemUser, @NoteAdditional, GETDATE())
		END
	END
	ELSE
	BEGIN
		INSERT INTO [TransferNote] ([IdTransferDetail], [IdTransferNoteType], [IdUser], [Note], [EnterDate]) VALUES (@IdValue, 2, @IdUser, @Note, GETDATE())
		IF (@NoteAdditional<> '' AND @CreateNote = 1)
		BEGIN
			INSERT INTO [dbo].[TransferNote] ([IdTransferDetail], [IdTransferNoteType], [IdUser], [Note], [EnterDate]) VALUES (@IdValue, 2, @IdUser, @NoteAdditional, GETDATE())          
		END
     
	END
	
	---------------- Mensaje a celular ------------------------------        
        
	EXEC [Corp].[st_InsertSmsFromStatusChange] @IdTransfer, @IdStatus


END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('[Corp].[st_SaveChangesToTransferLog]', GETDATE(), @ErrorMessage)
END CATCH

