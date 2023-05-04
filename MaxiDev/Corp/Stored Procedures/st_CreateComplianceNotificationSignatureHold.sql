CREATE PROCEDURE [Corp].[st_CreateComplianceNotificationSignatureHold]
( 
	@IdAgent INT,
	@IdTransfer INT,
	@IdComplianceProduct INT,
	@IdUser INT,
	@IsSpanishLanguage BIT
	,@RawMessage NVARCHAR(MAX) = NULL
) 
AS 
SET NOCOUNT ON

DECLARE @TransferDetail XML = NULL;
DECLARE @HasError BIT = 0;
DECLARE @MessageOut NVARCHAR(MAX)= '';

BEGIN TRY

	DECLARE @Transfers TABLE
	(
		IdAgent INT,
		IdTransfer INT,	
		AgentCode  VARCHAR(250), 
		AgentName VARCHAR(250),
		Folio VARCHAR(250),
		ClaimCode VARCHAR(250),
		DateOfTransfer DATETIME,

		CustomerName VARCHAR(250), 
		CustomerFirstLastName VARCHAR(250), 
		CustomerSecondLastName VARCHAR(250),	

		IdStatus INT,
		IdAgentCommunication  INT,
		EnterByIdUser  INT
	)

	/*Paso 1:Obtener las operciones en Verified Hold que tengan un Signature Hold correspondientes a la Agencia*/
	Insert Into @Transfers
	select 
		T.IdAgent,
		T.IdTransfer,	
		A.AgentCode, 
		A.AgentName,
		T.Folio,
		T.ClaimCode,
		T.DateOfTransfer,

		T.CustomerName, 
		T.CustomerFirstLastName, 
		T.CustomerSecondLastName,	

		T.IdStatus,		
		A.IdAgentCommunication
		,T.EnterByIdUser
		from transfer T with(nolock)
			join Agent A with(nolock) on T.IdAgent=A.IdAgent
			join TransferHolds H with(nolock) on T.IdTransfer=H.IdTransfer and H.IdStatus=3 and H.IsReleased is null
		where T.IdStatus = 41 
			and IdAgentStatus <>  2 /*Disabled*/
			and T.IdAgent = @IdAgent
		order by IdTransfer desc;

	/*Remesa que ya se trabajo*/
	--DELETE FROM @Transfers WHERE IdTransfer = @IdTransfer; /*20170207*/

	/*Paso 1.1: Crear Nota*/
	/*------------------------------*/
	DECLARE @NoteProcess NVARCHAR(100) = 'Fax has been sent to Agency to request signed recepit';
	DECLARE @Note NVARCHAR(MAX);

	/*Paso 1.1.1: Crear Nota*/
	DECLARE @NoteEs NVARCHAR(MAX);
	DECLARE @NoteEn NVARCHAR(MAX);
	SELECT 
		@NoteEs= name
		, @NoteEn=nameen 
	FROM ComplianceProducts WITH(nolock) WHERE  IdComplianceProduct = @IdComplianceProduct;
	--SET @Note  = @Note + ':' + @NoteProcess + ':' + @NoteEs +' / ' + @NoteEn;
	SET @Note  = ISNULL(@Note,'') + ':' + ISNULL(@NoteProcess,'');

	/*Paso 1.1.2: Crear Nota*/
    DECLARE @NoteHTML NVARCHAR(MAX) = NULL;	
	SET @NoteHTML = @NoteProcess + 	'<br/><br/>Required:<br/><strong>*' + @NoteEn +'</strong> /'+ @NoteEs;	
	
	/**/
	DECLARE @NoteText NVARCHAR(MAX);
	DECLARE @Text NVARCHAR(MAX) = 'Note';
	/*Convertir mensaje en una tabla y buscar los un reglon con un parametro especifico*/
	SET @NoteText = REPLACE( (SELECT TOP 1 * FROM [dbo].[fnSplit](@RawMessage,',') WHERE item like '%'+ @Text +'%'),'"','');
	SET @NoteText = REPLACE(@NoteText, '{','');
	SET @NoteText = REPLACE(@NoteText, '}','');
	SET @NoteText = REPLACE(@NoteText, '[','');
	SET @NoteText = REPLACE(@NoteText, ']','');

	IF EXISTS(SELECT TOP 1 * FROM [dbo].[fnSplit](@NoteText,':') WHERE item = 'null')
	BEGIN
		SET @NoteText = NULL;
	END
	/**/
	
	DECLARE @IdTransferTop INT;
	SET @IdTransferTop  = @IdTransfer;

	/*Paso 2: Generara cada una de las notificaciones*/
	while Exists(SELECT TOP 1 1 FROM  @Transfers)
	BEGIN
		DECLARE 
			@IdTransferDetail INT,
			@IdMessage INT,
			@IdTransferNoteInserted INT,
			@IdAgentCommunication INT,
			@AgentCode  NVARCHAR(100),
			@AgentName  NVARCHAR(100),		
			@Folio NVARCHAR(MAX),
			@ClaimCode  NVARCHAR(100),
			@Customer nvarchar(max),
			@DateOfTransfer nvarchar(max),
			@IdStatus INT
			,@EnterByIdUser INT;

		/*Paso 2.1: Seleccionar transaccion a trabajar*/
		Select Top 1
			@IdAgent = IdAgent,
			@IdTransfer = IdTransfer,
			@AgentCode = AgentCode,
			@AgentName = AgentName,
			@Folio= Folio,
			@ClaimCode  = ClaimCode,
			@Customer = (CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName),
			@DateOfTransfer = CONVERT(nvarchar(50),DateOfTransfer,127),
			@IdAgentCommunication = IdAgentCommunication,
			@IdStatus = IdStatus
			,@EnterByIdUser = EnterByIdUser
		from @Transfers

		/*Paso 2.2: Inicializacion/Validacion Nota*/
		/*------------------------------*/
		Declare @IdNotes table(idNote int);

		IF LTRIM(@NoteHTML) = ''
		begin
			set @NoteHTML= null
		end

		/*Paso 2.2.1: Validacion de "sesiones"*/
		DECLARE @SEND BIT;
		SET @SEND = 1;
		IF NOT EXISTS(SELECT TOP 1 1 FROM [dbo].[AgentUser] AS A with(nolock) 
						INNER JOIN UsersSession AS US with(nolock)  ON A.IdUser = US.IdUser
							WHERE A.IdAgent = @IdAgent
								AND [dbo].[RemoveTimeFromDatetime](DateOfCreation) >= [dbo].[RemoveTimeFromDatetime](GETDATE()))
		BEGIN
			IF EXISTS(SELECT TOP 1 1 FROM Transfer WITH(NOLOCK)
							WHERE IdAgent = @IdAgent
								And [dbo].[RemoveTimeFromDatetime](DateOfTransfer) >= [dbo].[RemoveTimeFromDatetime](GETDATE()))
			BEGIN
				SET @IdAgentCommunication = 2;
			END
			ELSE
			BEGIN
				SET @SEND = 0;
			END
		END

		/*20170207*/
		IF(@SEND = 0)
		BEGIN
			SET @IdAgentCommunication = 1;
			SET @SEND = 1;
		END

		IF(@SEND = 1)
		BEGIN

		DECLARE @TXT VARCHAR(MAX) = NULL;
		DECLARE @Folios nvarchar(max) = '';
		/*Paso 2.3: Crear Notificacion/Fax*/
		if(@IdAgentCommunication = 2)  -- Agent es de tipo Phone (Enviar fax)
		BEGIN

			/*Paso 2.3.1: Insercion de notas individuales: la nota es difertente a la de la primera remesa*/			
			while Exists(SELECT TOP 1 1 FROM  @Transfers WHERE IdAgent = @IdAgent)
			BEGIN
				
				SELECT TOP 1
					@IdTransfer = IdTransfer
					,@Folio = Folio
				FROM @Transfers WHERE IdAgent = @IdAgent
					ORDER BY IdTransfer DESC;

				/*Insercion de nota de la "primera" remesa*/
				IF(@IdTransferTop = @IdTransfer)
					BEGIN
						SET @TXT = ISNULL(@NoteText,'');
					END
				ELSE
					BEGIN
						SET @TXT = ISNULL(@NoteProcess,'');
					END

				/**Cambio para obtener el IdTransferDetail correspondiente al Status actual de la transferencia, no el último de TransferDetail**/
				Select @IdTransferDetail= dbo.fun_GetIdTransferDetail(@IdTransfer);

				Insert TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate)
					output INSERTED.IdTransferNote into @IdNotes
						values (@IdTransferDetail,3,@IdUser,ISNULL(@NoteProcess,''),GETDATE());

				select top 1 @IdTransferNoteInserted = idNote from @IdNotes;

				SET @Folios = @Folios+','+@Folio;

				DELETE FROM @Transfers WHERE IdTransfer = @IdTransfer;
			END
			
			IF(SUBSTRING(@Folios, 1, 1) = ',')
			BEGIN
				SET @Folios = SUBSTRING(@Folios,2, LEN(@Folios));
			END

			/*Paso 2.3.2: Insercion de fax*/
			declare @Parameters table (name nvarchar(max), value nvarchar(max));
			declare @ParametersString XML;

			insert into @Parameters
				values	('Folios',@Folios),
						('Agent',@AgentCode),
						('DateOfTransfer',@DateOfTransfer),
						('MessageEs',isnull(@NoteEs,'')),
						('MessageEn',isnull(@NoteEn,''));
						---,('Note', isnull(@NoteText,''));

			select @ParametersString =(select name as '@name', value as '@value'  from @Parameters FOR XML PATH('Parameter'), ROOT('Parameters'));

			EXEC [Corp].[st_InsertFaxToQueueFaxes] 
				@Parameters		= @ParametersString,
				@ReportName		= 'NotificationsSignatureHold', /*NotificationsReport*/
				@Priority		= 1,
				@IdAgent		= @IdAgent,
				@IdLenguage		= 1,
				@enterbyiduser	= @IdUser,
				@HasError		= @HasError OUTPUT,
				@ResultMessage	= @MessageOut OUTPUT;

			if(@HasError = 0)
			begin
				Insert into TransferNoteNotification select IdNote, -1,0 from @IdNotes;
				UPDATE [dbo].[Transfer] SET [AgentNotificationSent] = 1 WHERE [IdTransfer] = @IdTransfer AND [AgentNotificationSent] = 0; -- No one notification has been sent
			end
			else
			begin
				Delete TransferNote where IdTransferNote = @IdTransferNoteInserted;
				return
			end
		End
		Else
		Begin --Agent es de tipo PC, enviar notificación

			/*Paso 2.3.1: Insercion de nota de la "primera" remesa*/
			/*Paso 2.3.1: Insercion de notas individuales: la nota es difertente a la de la primera remesa*/			
			while Exists(SELECT TOP 1 1 FROM  @Transfers WHERE IdAgent = @IdAgent)
			BEGIN
				
				SELECT TOP 1
					@IdTransfer = IdTransfer
					,@Folio = Folio
				FROM @Transfers WHERE IdAgent = @IdAgent
					ORDER BY IdTransfer DESC;

				/*Insercion de nota de la "primera" remesa*/
				IF(@IdTransferTop = @IdTransfer)
					BEGIN
						SET @TXT = ISNULL(@NoteText,'');
					END
				ELSE
					BEGIN
						SET @TXT = ISNULL(@NoteProcess,'');
					END

				/**Cambio para obtener el IdTransferDetail correspondiente al Status actual de la transferencia, no el último de TransferDetail**/
				Select @IdTransferDetail= dbo.fun_GetIdTransferDetail(@IdTransfer);

				Insert TransferNote (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate)
					output INSERTED.IdTransferNote into @IdNotes
						values (@IdTransferDetail,3,@IdUser,ISNULL(@NoteProcess,''),GETDATE());

				select top 1 @IdTransferNoteInserted = idNote from @IdNotes;

				SET @Folios = @Folios+','+@Folio;

				DELETE FROM @Transfers WHERE IdTransfer = @IdTransfer;
			END
			
			IF(SUBSTRING(@Folios, 1, 1) = ',')
			BEGIN
				SET @Folios = SUBSTRING(@Folios,2, LEN(@Folios));
			END
			/**/

			SET @RawMessage ='{"IdMessageSource":1, "IsIntrusive":true' + 
				', "Message":"'+ @Folios + '"' +
				', "MessageUS":"'+ @NoteEn + '"' +
				', "MessageEs":"'+ @NoteEs + '"' +
				', "CanClose":true}';

			/*---------------*/
			/*Valida la existencia de notificaciones*/
			DECLARE @Update INT = 0;
			EXEC @Update = [Corp].[st_GetMessagesExisting] 
								@IdAgent,	
								@NoteEn, /*@ComplianceProductMessage = @NoteEn*/
								@Update OUTPUT,
								@HasError OUTPUT,
								@MessageOut OUTPUT;
			   
			IF(@HasError = 0)
			BEGIN
				/*Inserta notificaciones*/
				EXEC @IdMessage = [Corp].[st_CreateMessageForAgent]
									@IdAgent			,
									5, /*Direct Message -> [msg].[MessageProviders]*/
									@IdUser,
									@RawMessage,
									@IsSpanishLanguage	= 0,
									@HasError			= @HasError OUTPUT,
									@Message			= @MessageOut OUTPUT;
			END

		End
	
		END
		/*------------------------------*/

		/*Eliminar transacion trabajada*/
		DELETE FROM @IdNotes;
		DELETE FROM @Transfers WHERE IdTransfer = @IdTransfer;

	END


End Try 
Begin Catch
	 Set @HasError=1 
	 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33) 
	 Declare @ErrorMessage nvarchar(max) 
	 Select @ErrorMessage=ERROR_MESSAGE() 
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_CreateComplianceNotificationSignatureHold',Getdate(),@ErrorMessage) 
End Catch 





