/***
st_CreateComplianceNotificationCheck 20160915
***/
CREATE PROCEDURE [dbo].[st_CreateComplianceNotificationCheck]
( 
	@IdCheck INT,
	@IdUser INT,
	@Note NVARCHAR(MAX),
	@NoteHTML NVARCHAR(MAX) = NULL,
	@RawMessage NVARCHAR(MAX),
	@IsSpanishLanguage BIT,
	@CheckDetail XML OUTPUT,
	@HasError BIT OUTPUT,
	@MessageOut NVARCHAR(MAX) OUTPUT
) 
AS 
SET NOCOUNT ON
BEGIN TRY

	DECLARE 
		@idCheckDetail INT,
		@IdAgent INT, 
		@IdMessage INT, 
		@IdStatus INT,
		@IdCheckNoteInserted INT, 
		@IdAgentCommunication INT,	
		@Customer nvarchar(max),
		@DateOfMovement nvarchar(max),
		@CheckNumber NVARCHAR(MAX)

	DECLARE @IdNotes table(idNote int)

	IF LTRIM(@NoteHTML) = ''
	BEGIN
        SET @NoteHTML= null
    END

	SELECT TOP 1 @idCheckDetail = cd.idCheckDetail
	FROM dbo.checks c WITH(NOLOCK)
	INNER JOIN dbo.CheckDetails cd WITH(NOLOCK) ON cd.idCheck = c.idCheck AND cd.IdStatus = c.IdStatus
	WHERE c.IdCheck = @IdCheck
	ORDER BY cd.IdCheckDetail

	-- >> INITIAL DATA CHECKS
	IF @idCheckDetail IS NULL
	BEGIN 
		SELECT TOP 1  @idCheckDetail = cd.idCheckDetail
		FROM CheckDetails cd WITH(NOLOCK)
		WHERE idCheck = @IdCheck
		ORDER BY IdCheckDetail DESC
	END

	SELECT 
		@IdAgent = IdAgent, 
		@Customer = ( Name+' '+ FirstLastName +' '+ SecondLastName), 
		@CheckNumber = CheckNumber,
		@DateOfMovement = CONVERT(NVARCHAR(max),DateOfMovement),
		@IdStatus = idStatus
	FROM checks WITH(NOLOCK) 
	WHERE IdCheck  = @Idcheck

	SELECT 
		@IdAgentCommunication = IdAgentCommunication 
	FROM Agent WITH(NOLOCK) 
	WHERE IdAgent = @IdAgent

	-- << INITIAL DATA CHECKS NOTIFICATION


	INSERT CheckNote (idCheckDetail, idCheckNoteType, idUser, Note, EnterDate)
	OUTPUT INSERTED.idCheckNote into @IdNotes
	VALUES (@idCheckDetail, 3, @IdUser, @Note, GETDATE());

	SELECT TOP 1 @IdCheckNoteInserted = idNote FROM @IdNotes

	IF (@IdAgentCommunication = 2)  -- Agent es de tipo Phone (Enviar fax)
	BEGIN
		DECLARE @Parameters TABLE (name NVARCHAR(MAX), value NVARCHAR(MAX))
		DECLARE @ParametersString XML

		INSERT INTO @Parameters
		VALUES	('CheckNumber',@CheckNumber),
				('Customer',@Customer),
				('DateOfMovement',@DateOfMovement),
				('Message',isnull(@NoteHTML,@Note))

		SELECT @ParametersString =(SELECT name AS '@name', value AS '@value' FROM @Parameters FOR XML PATH('Parameter'), ROOT('Parameters'))

		EXEC [dbo].[st_InsertFaxToQueueFaxes] 
			@Parameters		= @ParametersString,
			@ReportName		= 'NotificationsReportCheck',
			@Priority		= 1,
			@IdAgent		= @IdAgent,
			@IdLenguage		= 1,
            @enterbyiduser	= @IdUser,
			@HasError		= @HasError OUTPUT,
			@ResultMessage	= @MessageOut OUTPUT

		IF(@HasError = 0)
		BEGIN
			INSERT INTO CheckNoteNotification 
				SELECT IdNote, -1,0 
				FROM @IdNotes
			
			UPDATE [dbo].[Checks] 
			SET [AgentNotificationSent] = 1 
			WHERE 
				idCheck = @idCheck 
				AND AgentNotificationSent = 0 -- No one notification has been sent
		END
		ELSE
		BEGIN
			DELETE CheckNote WHERE IdCheckNote  = @IdCheckNoteInserted
			RETURN;
		END
	END
	ELSE
	BEGIN --Agent es de tipo PC, enviar notificación
		EXEC @IdMessage = [dbo].[st_CreateMessageForAgent]
							@IdAgent			= @IdAgent,
							@IdMessageProvider	= 2,
							@IdUserSender		= @IdUser,
							@RawMessage			= @RawMessage,
							@IsSpanishLanguage	= 0,
							@HasError			= @HasError OUTPUT,
							@Message			= @MessageOut OUTPUT

		IF(@HasError = 0)
		BEGIN
			INSERT INTO CheckNoteNotification 
				SELECT IdNote, @IdMessage,1 
				FROM @IdNotes

			UPDATE [dbo].Checks SET [AgentNotificationSent] = 1
			 WHERE idCheck = @IdCheck AND [AgentNotificationSent] = 0 -- No one notification has been sent
		END
		ELSE
		BEGIN
			DELETE CheckNote WHERE  idCheckNote = @IdCheckNoteInserted
			RETURN
		END
	END
	
	SET @HasError = 0 
	SELECT @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,38) 

END TRY
BEGIN CATCH
	 SET @HasError=1 
	 SELECT @MessageOut = dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33) 
	 DECLARE @ErrorMessage NVARCHAR(MAX)
	 SELECT @ErrorMessage = ERROR_MESSAGE() 
	 INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_CreateComplianceNotificationCheck',GETDATE(),@ErrorMessage) 
END CATCH
