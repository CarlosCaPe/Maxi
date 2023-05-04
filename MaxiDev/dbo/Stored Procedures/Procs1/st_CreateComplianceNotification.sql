CREATE Procedure [dbo].[st_CreateComplianceNotification]
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

/*new mobile*/
declare @RequiereID bit = 0
declare @RequiereProof bit = 0
declare @CustomerOccupation bit = 0
declare @CustomerAddress bit = 0
declare @CustomerSSN bit = 0
declare @IDNotLegible bit = 0
declare @CustomerIDNumber bit = 0
declare @CustomerDateOfBirth bit = 0
declare @CustomerPlaceOfBirth bit = 0
declare @CustomerIDExpiration bit = 0
declare @CustomerFullName bit = 0
declare @CustomerFullAddress bit = 0
declare @BeneficiaryFullName bit = 0
declare @BeneficiaryDateOfBirth bit = 0
declare @BeneficiaryPlaceOfBirth bit = 0
declare @BeneficiaryRequiereID bit = 0
declare @SignReceipt bit = 0

--set @note=N'jose Required: Falta ID / Customer ID is required;Falta Comprobante de Ingresos / Customer''s Proof of Source of Income is required;Falta Ocupación Detallada / Customer Occupation is required;Falta Dirección Completa / Customer address is required;Se recibió ID, pero faltan datos escritos manualmente para mejor lectura / The ID we received is not legible, please send it again and write down the ID info;Falta Núm. de Seguro Social / Customer SSN is required;Falta Núm. de ID / ID numer is required;Se mandó IFE, falta número vertical / Vertical number on back of IFE ID is required;Falta Lugar de nacimiento del Cliente / Please provide Customer''s place of birth;Falta Fecha de nacimiento del Cliente / Please provide Customer''s date of birth;Falta Fecha de Expiración del ID / Please provide the ID''s expiration date;Especificar qué tipo de ID es la que envía/ Matrícula, Licencia de Conducir, IFE, etc. / The ID we received is not legible, please send it again and write down the ID info;ID no se ve, volver a enviar / The ID we received is not legible, please send it again and write down the ID info;Falta Nombre Completo del Cliente / Please provide the Customer Full Name;Falta Nombre Completo del Beneficiario / Please provide the Beneficiary Full Name;Favor de enviar el recibo firmado por el cliente del(los) folio(s) / Please submit signed receipt of the above transactions'

if @Note like '%Customer ID is required%' or exists( select top 1 tai.[RequiereID] from MaxiMobile.TransferAdditionalInfo tai with (nolock) where IdTransfer=@IdTransfer and tai.RequiereID=1) set @RequiereID = 1
if @Note like '%Customer''s Proof of Source of Income is required%' or exists (select tai.RequiereProof from MaxiMobile.TransferAdditionalInfo tai with (nolock) where IdTransfer=@IdTransfer and tai.RequiereProof=1) set @RequiereProof = 1
if @Note like '%Customer Occupation is required%' or exists (select tai.[CustomerOccupation] from MaxiMobile.TransferAdditionalInfo tai with (nolock) where IdTransfer=@IdTransfer and tai.[CustomerOccupation]=1) set @CustomerOccupation =  1
if @Note like '%Customer address is required%' or exists (select tai.CustomerAddress from MaxiMobile.TransferAdditionalInfo tai with (nolock) where IdTransfer=@IdTransfer and tai.[CustomerAddress]=1) set @CustomerAddress = 1
if @Note like '%The ID we received is not legible, please send it again and write down the ID info%' or exists (select tai.[IDNotLegible] from MaxiMobile.TransferAdditionalInfo tai with (nolock) where IdTransfer=@IdTransfer and tai.[IDNotLegible]=1) set @IDNotLegible = 1
if @Note like '%Customer SSN is required%' or exists (select tai.[CustomerSSN] from MaxiMobile.TransferAdditionalInfo tai with (nolock) where IdTransfer=@IdTransfer and tai.[CustomerSSN]=1) set @CustomerSSN = 1
if @Note like '%ID numer is required%' or exists (select tai.[CustomerIDNumber] from MaxiMobile.TransferAdditionalInfo tai with (nolock) where IdTransfer=@IdTransfer and tai.[CustomerIDNumber]=1) set @CustomerIDNumber = 1
if @Note like '%Vertical number on back of IFE ID is required%' set @CustomerIDNumber = 1
if @Note like '%Please provide Customer''s place of birth%' set @CustomerPlaceOfBirth = 1
if @Note like '%Please provide Customer''s date of birth%' set @CustomerDateOfBirth = 1
if @Note like '%Please provide the ID''s expiration date%' set @CustomerIDExpiration = 1
if @Note like '%The ID we received is not legible, please send it again and write down the ID info%' set @IDNotLegible = 1
if @Note like '%The ID we received is not legible, please send it again and write down the ID info%' set @IDNotLegible = 1
if @Note like '%Please provide the Customer Full Name%' set @CustomerFullName = 1
if @Note like '%Please provide the Beneficiary Full Name%' set @BeneficiaryFullName = 1
if @Note like '%Please provide the Customer Full Name%' set @CustomerFullName = 1
if @Note like '%Please provide Customer''s date of birth%' set @CustomerDateOfBirth = 1
if @Note like '%Please provide Customer''s place of birth%'  set @CustomerPlaceOfBirth = 1
if @Note like '%Customer ID is required%' set @RequiereID = 1
if @Note like '%Please provide the Beneficiary Full Name%' set @BeneficiaryFullName = 1
if @Note like '%Please provide Beneficiary''s date of birth%' set @BeneficiaryDateOfBirth = 1
if @Note like '%Please provide Beneficiary''s place of birth%' set @BeneficiaryPlaceOfBirth = 1
if @Note like '%Beneficiary ID is required%' set @BeneficiaryRequiereID =  1
if @Note like '%Please provide the Customer Full Address%' set @CustomerFullAddress = 1
if @Note like '%Please submit signed receipt of the above transactions%' set @SignReceipt = 1

EXEC	[MaxiMobile].[st_saveTransferAdditionalInfo]
		@IdTransfer = @IdTransfer,
		@Note = @Note,
		@RequiereID = @RequiereID,
		@RequiereProof = @RequiereProof,
		@CustomerOccupation = @CustomerOccupation,
		@CustomerAddress = @CustomerAddress,
		@CustomerSSN = @CustomerSSN,
		@IDNotLegible = @IDNotLegible,
		@CustomerIDNumber = @CustomerIDNumber,
		@CustomerDateOfBirth = @CustomerDateOfBirth,
		@CustomerPlaceOfBirth = @CustomerPlaceOfBirth,
		@CustomerIDExpiration = @CustomerIDExpiration,
		@CustomerFullName = @CustomerFullName,
		@CustomerFullAddress = @CustomerFullAddress,
		@BeneficiaryFullName = @BeneficiaryFullName,
		@BeneficiaryDateOfBirth = @BeneficiaryDateOfBirth,
		@BeneficiaryPlaceOfBirth = @BeneficiaryPlaceOfBirth,
		@BeneficiaryRequiereID = @BeneficiaryRequiereID,
		@SignReceipt = @BeneficiaryRequiereID


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
			EXEC st_MoveBackTransfer @IdTransfer;
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
			EXEC dbo.st_CreateComplianceNotificationSignatureHold 
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

			EXEC [dbo].[st_InsertFaxToQueueFaxes] 
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
			EXEC dbo.st_CreateComplianceNotificationSignatureHold 
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
			EXEC @IdMessage = [dbo].[st_CreateMessageForAgent]
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


