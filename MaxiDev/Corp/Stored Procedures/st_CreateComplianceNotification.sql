CREATE PROCEDURE [Corp].[st_CreateComplianceNotification]
( 
	 @IdTransfer INT,
	 @IdUser INT,
	 @Note NVARCHAR(MAX),
     @NoteHTML NVARCHAR(MAX) = NULL,
	 @RawMessage NVARCHAR(MAX),
	 @IsSpanishLanguage BIT,
	 @TransferDetail XML OUTPUT, 
	 @HasError BIT OUTPUT,
	 @MessageOut NVARCHAR(MAX) OUTPUT
) 
AS 
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="26/01/2018" Author="jdarellano" Name="#1">Performance: se agregan with(nolock).</log>
</ChangeLog>
*********************************************************************/
SET NOCOUNT ON
BEGIN TRY	

	/*Original*/
	/*--------*/
		DECLARE 
		@IdTransferDetail INT,
		@IdAgent INT,
		@IdMessage INT,
		@IdTransferNoteInserted INT,
		@IdAgentCommunication INT,
		@Folio NVARCHAR(MAX),
		@Customer nvarchar(max),
		@DateOfTransfer nvarchar(max);

		Declare @IdNotes table(idNote int);

		IF LTRIM(@NoteHTML) = ''
		begin
			set @NoteHTML= null;
		end
 
		If Exists (Select 1 from [dbo].[TransferClosed] with(nolock) where IdTransferClosed=@IdTransfer) --#1
		Begin
			EXEC [Corp].[st_MoveBackTransfer] @IdTransfer;
		End

		/**Cambio para obtener el IdTransferDetail correspondiente al Status actual de la transferencia, no el último de TransferDetail**/
		Select @IdTransferDetail= dbo.fun_GetIdTransferDetail(@IdTransfer);
	
		Insert [dbo].[TransferNote] (IdTransferDetail,IdTransferNoteType,IdUser,Note,EnterDate)
			output INSERTED.IdTransferNote into @IdNotes
				values (@IdTransferDetail,3,@IdUser,@Note,GETDATE());

		select top 1 @IdTransferNoteInserted = idNote from @IdNotes;

		Select 
			@IdAgent = IdAgent,
			@Folio= Folio,
			@Customer = (CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName),
			@DateOfTransfer = CONVERT(nvarchar(max),DateOfTransfer) 
		from [dbo].[Transfer] with (nolock) where IdTransfer = @IdTransfer;

		Select @IdAgentCommunication = IdAgentCommunication from [dbo].[Agent] with (nolock) where IdAgent = @IdAgent;
		/*--------*/
		DECLARE @ComplianceProductMessage VARCHAR(MAX) = 'Please submit signed receipt of the above transactions';
		DECLARE @IdComplianceProduct INT = 0;
				SELECT @IdComplianceProduct = IdComplianceProduct
					FROM [dbo].[ComplianceProducts] WITH(nolock)
						WHERE  [Name] = @ComplianceProductMessage OR NameEn = @ComplianceProductMessage; 
		/*--------*/
		
	if(@IdAgentCommunication = 2)  -- Agent es de tipo Phone (Enviar fax)
	Begin
		/*--------*/
		IF (CHARINDEX(@ComplianceProductMessage, @RawMessage) > 0)
		BEGIN			
			EXEC [Corp].[st_CreateComplianceNotificationSignatureHold]
				@IdAgent,
				@IdTransfer,
				@IdComplianceProduct,
				@IdUser,
				@IsSpanishLanguage
				,@RawMessage;
		END
		/*--------*/
		ELSE
		BEGIN
			declare @Parameters table ([name] nvarchar(max), [value] nvarchar(max));
			declare @ParametersString XML;

			insert into @Parameters
			values	('Folio',@Folio),
					('Customer',@Customer),
					('DateOfTransfer',@DateOfTransfer),
					('Message',isnull(@NoteHTML,@Note));

			select @ParametersString =(select [name] as '@name', [value] as '@value'  from @Parameters FOR XML PATH('Parameter'), ROOT('Parameters'));

			EXEC [Corp].[st_InsertFaxToQueueFaxes] 
				@Parameters		= @ParametersString,
				@ReportName		= 'NotificationsReport',
				@Priority			= 1,
				@IdAgent			= @IdAgent,
				@IdLenguage	= 1,
				@enterbyiduser = @IdUser,
				@HasError			= @HasError OUTPUT,
				@ResultMessage		= @MessageOut OUTPUT;
			if(@HasError = 0)
			begin
				Insert into [dbo].[TransferNoteNotification] select IdNote, -1,0 from @IdNotes;
				UPDATE [dbo].[Transfer] SET [AgentNotificationSent] = 1 WHERE [IdTransfer] = @IdTransfer AND [AgentNotificationSent] = 0; -- No one notification has been sent
			end
			else
			begin
				Delete from [dbo].[TransferNote] where IdTransferNote = @IdTransferNoteInserted;
				return;
			end
		END
	End
	Else
	Begin --Agent es de tipo PC, enviar notificación
	
		/*--------*/
		IF (CHARINDEX(@ComplianceProductMessage, @RawMessage) > 0)
		BEGIN
			EXEC [Corp].[st_CreateComplianceNotificationSignatureHold]
				@IdAgent,
				@IdTransfer,
				@IdComplianceProduct,
				@IdUser,
				@IsSpanishLanguage
				,@RawMessage;

		END 
		/*--------*/
		ELSE 
		BEGIN 
			EXEC @IdMessage = [Corp].[st_CreateMessageForAgent]
								@IdAgent			= @IdAgent,
								@IdMessageProvider	= 2,
								@IdUserSender		= @IdUser,
								@RawMessage		= @RawMessage,
								@IsSpanishLanguage	= 0,
								@HasError			= @HasError OUTPUT,
								@Message			= @MessageOut OUTPUT;

			if(@HasError = 0)
			begin
				Insert into [dbo].[TransferNoteNotification] select IdNote, @IdMessage,1 from @IdNotes;
				UPDATE [dbo].[Transfer] SET [AgentNotificationSent] = 1
					WHERE [IdTransfer] = @IdTransfer AND [AgentNotificationSent] = 0; -- No one notification has been sent
			end
			else
			begin
				Delete from [dbo].[TransferNote] where IdTransferNote = @IdTransferNoteInserted;
				return;
			end
		END
	End
	
		--Get xml representation of transfer's details 
		Select @TransferDetail= [dbo].[fun_GetTransferDetailsXml] (@IdTransfer);

		Set @HasError=0;
		Select @MessageOut=dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,38);

End Try 
Begin Catch
	 Set @HasError=1;
	 Select @MessageOut =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,33);
	 Declare @ErrorMessage nvarchar(max);
	 Select @ErrorMessage=ERROR_MESSAGE(); 
	 Insert into [dbo].[ErrorLogForStoreProcedure] (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreateComplianceNotification',Getdate(),@ErrorMessage);
End Catch
