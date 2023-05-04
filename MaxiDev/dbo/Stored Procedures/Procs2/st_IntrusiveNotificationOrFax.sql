-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-11-26
-- Description:	Sent a intrusive notification or fax to Agent
-- =============================================
CREATE PROCEDURE [dbo].[st_IntrusiveNotificationOrFax]
	-- Add the parameters for the stored procedure here
	@IdTransfer INT,
	@IdUser INT,
	@Note NVARCHAR(MAX),
	@RawMessage NVARCHAR(MAX),
	@IsSpanishLanguage BIT,
	@HasError BIT				OUTPUT,
	@MessageOut NVARCHAR(MAX)	OUTPUT,
	@NoteHTML NVARCHAR(MAX) = NULL
AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE 
		@IdTransferDetail INT,
		@IdAgent INT,
		@IdMessage INT,
		@IdTransferNoteInserted INT,
		@IdAgentCommunication INT,
		@Folio NVARCHAR(MAX),
		@Customer NVARCHAR(MAX),
		@DateOfTransfer NVARCHAR(MAX)
 
	DECLARE @IdNotes table(idNote int)

    IF LTRIM(@NoteHTML) = ''
    BEGIN
        SET @NoteHTML = NULL
    END
 
	IF EXISTS(SELECT TOP 1 1 FROM [dbo].[TransferClosed] WITH (NOLOCK) WHERE [IdTransferClosed] = @IdTransfer)
	BEGIN
		EXEC st_MoveBackTransfer @IdTransfer
	END

	/**Para obtener el IdTransferDetail correspondiente al Status actual de la transferencia, no el último de TransferDetail**/
	--SELECT @IdTransferDetail= dbo.fun_GetIdTransferDetail(@IdTransfer)
	
	--INSERT [dbo].[TransferNote] ([IdTransferDetail], [IdTransferNoteType], [IdUser], [Note], [EnterDate])
	--OUTPUT [inserted].[IdTransferNote] INTO @IdNotes
	--VALUES (@IdTransferDetail,3,@IdUser,@Note,GETDATE()) 

	--SELECT TOP 1 @IdTransferNoteInserted = idNote FROM @IdNotes

	SELECT
		@IdAgent = [IdAgent]
		,@Folio= [Folio]
		,@Customer = ([CustomerName] + ' ' + [CustomerFirstLastName] + ' ' + [CustomerSecondLastName])
		,@DateOfTransfer = CONVERT(NVARCHAR(MAX), [DateOfTransfer]) FROM [dbo].[Transfer] WITH (NOLOCK) WHERE [IdTransfer] = @IdTransfer
	
	SELECT @IdAgentCommunication = [IdAgentCommunication] FROM [dbo].[Agent] WITH (NOLOCK) WHERE [IdAgent] = @IdAgent

	IF(@IdAgentCommunication = 2)  -- Agent es de tipo Phone (Enviar fax)
	BEGIN
		DECLARE @Parameters TABLE ([Name] NVARCHAR(MAX), [Value] NVARCHAR(MAX))
		DECLARE @ParametersString XML

		INSERT INTO @Parameters VALUES
			('Folio',@Folio),
			('Customer',@Customer),
			('DateOfTransfer',@DateOfTransfer),
			('Message',ISNULL(@NoteHTML,@Note))

		SELECT @ParametersString = (SELECT [Name] AS '@name', [Value] AS '@value' FROM @Parameters FOR XML PATH('Parameter'), ROOT('Parameters'))

		EXEC [dbo].[st_InsertFaxToQueueFaxes] 
			@Parameters		= @ParametersString,
			@ReportName		= 'NotificationsReport',
			@Priority			= 1,
			@IdAgent			= @IdAgent,
			@IdLenguage	= 1,
            @enterbyiduser = @IdUser,
			@HasError			= @HasError OUTPUT,
			@ResultMessage		= @MessageOut OUTPUT
		IF(@HasError = 0)
			INSERT INTO [dbo].[TransferNoteNotification] SELECT [IdNote], -1,0 FROM @IdNotes
		ELSE
		BEGIN
			DELETE [dbo].[TransferNote] WHERE [IdTransferNote] = @IdTransferNoteInserted
			RETURN
		END
	END
	ELSE
	BEGIN --Agent es de tipo PC, enviar notificación
		EXEC @IdMessage = [dbo].[st_CreateMessageForAgent]
							@IdAgent			= @IdAgent,
							@IdMessageProvider	= 5, -- Intrusive Notification Provider
							@IdUserSender		= @IdUser,
							@RawMessage		= @RawMessage,
							@IsSpanishLanguage	= 0,
							@HasError			= @HasError OUTPUT,
							@Message			= @MessageOut OUTPUT

		IF(@HasError = 0)
			INSERT INTO [dbo].[TransferNoteNotification] SELECT [IdNote], @IdMessage, 1 FROM @IdNotes
		ELSE
		BEGIN
			DELETE [dbo].[TransferNote] WHERE [IdTransferNote] = @IdTransferNoteInserted
			RETURN
		END
	END
	
	SET @HasError=0 
	SELECT @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,38) 


END TRY
BEGIN CATCH
	SET @HasError=1 
	SELECT @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33) 
	DECLARE @ErrorMessage NVARCHAR(MAX) 
	SELECT @ErrorMessage=ERROR_MESSAGE() 
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage])
		VALUES('st_IntrusiveNotificationOrFax',GETDATE(),@ErrorMessage) 
END CATCH
