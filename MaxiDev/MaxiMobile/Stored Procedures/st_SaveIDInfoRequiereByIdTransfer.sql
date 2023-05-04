CREATE PROCEDURE [MaxiMobile].[st_SaveIDInfoRequiereByIdTransfer]
(
	@IdTransfer int,
	@CustomerIdType int = null,
	@CustomerIdExpeditionCountry int = null,
	@CustomerIdState int = null,
	--#1
	@CustomerSsnName nvarchar (max)= null,
	@CustomerDateOfBirth DateTime = null,
	@CustomerIdExpirationDate DateTime = null,
	@CustomerOccupation nvarchar(max) = null,
	@CustomerOccupationDetail nvarchar(max) = null,
	@CustomerIDNumber nvarchar(max) = null,
	@IsSuccess bit out, 
	@Message nvarchar(max) out
)
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> Sp para guardar la información que se marco como requerida en para el ID. No aplica para imagenes faltantes </Description>

<ChangeLog>
<log Date="22/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

<ChangeLog>
<id>#1</id>
<log Date="23/12/2019" Author="sgarcia">modification</log>
<description>Se agregó elo (max) a la variable ssNumber ya que estaba regresando mal los valores a la app de fax Android</description>
</ChangeLog>
*********************************************************************/
as
Begin Try 

	set @IsSuccess = 1
	set @Message = 'Información actualizada correctamente'

	/* Revisa si hay información del customer que se tenga que actualizar, en caso de ser así se hace una copia de la info actual y se actualiza la info del customer */
	if (@CustomerIdType is not null or @CustomerIdExpeditionCountry is not null or @CustomerDateOfBirth is not null or @CustomerIdExpirationDate is not null or @CustomerOccupation is not null or 
		@CustomerOccupationDetail is not null or @CustomerIDNumber is not null)
	begin
		/* Se obtiene el tipo de info que se espera se tenga que actualizar */
		declare @CustomerIdNumberRequired bit
		declare @CustomerDateOfBirthRequired bit
		declare @CustomerIdExpirationRequired bit
		declare @CustomerCustomerSSNRequired bit

		select @CustomerIdNumberRequired = CustomerIDNumber, @CustomerDateOfBirthRequired = CustomerDateOfBirth, @CustomerIdExpirationRequired = CustomerIDExpiration, @CustomerCustomerSSNRequired = CustomerSSN
		from MaxiMobile.TransferAdditionalInfo (nolock) where IdTransfer = @IdTransfer

		/* Se actualiza la información del customer */
		declare @IdCustomer int
		select @IdCustomer = IdCustomer from Transfer (nolock) where IdTransfer = @IdTransfer

		/* Se guarda la info de customer en CustomerMirror */
		exec st_SaveCustomerMirror @IdCustomer

		/* Se actualiza info en Customer con idstate*/
		if @IdCustomer is not null and @CustomerIdState > 0
		BEGIN
			update Customer set IdCustomerIdentificationType = ISNULL(@CustomerIdType, IdCustomerIdentificationType), IdentificationIdCountry = ISNULL(@CustomerIdExpeditionCountry, IdentificationIdCountry),
				BornDate = ISNULL(@CustomerDateOfBirth, BornDate), ExpirationIdentification = ISNULL(@CustomerIdExpirationDate, ExpirationIdentification), Occupation = ISNULL(@CustomerOccupation, Occupation),
				OccupationDetail = ISNULL(@CustomerOccupationDetail, OccupationDetail), IdentificationNumber = ISNULL(@CustomerIDNumber, IdentificationNumber), 
				SSNumber = ISNULL(@CustomerSsnName, SSNumber), IdentificationIdState = ISNULL(@CustomerIdState, IdentificationIdState) where IdCustomer = @IdCustomer
		END

		/* Se actualiza info en Customer sin Idstate*/
		if @IdCustomer is not null and (@CustomerIdState is null or @CustomerIdState = 0)
		BEGIN
			update Customer set IdCustomerIdentificationType = ISNULL(@CustomerIdType, IdCustomerIdentificationType), IdentificationIdCountry = ISNULL(@CustomerIdExpeditionCountry, IdentificationIdCountry),
				BornDate = ISNULL(@CustomerDateOfBirth, BornDate), ExpirationIdentification = ISNULL(@CustomerIdExpirationDate, ExpirationIdentification), Occupation = ISNULL(@CustomerOccupation, Occupation),
				OccupationDetail = ISNULL(@CustomerOccupationDetail, OccupationDetail), IdentificationNumber = ISNULL(@CustomerIDNumber, IdentificationNumber), 
				SSNumber = ISNULL(@CustomerSsnName, SSNumber) where IdCustomer = @IdCustomer
		END
		
		/* Se actualiza info en Transfer con idstate*/
		if @IdTransfer is not null and @CustomerIdState > 0
		Begin
			update Transfer set CustomerIdCustomerIdentificationType = ISNULL(@CustomerIdType, CustomerIdCustomerIdentificationType), CustomerIdentificationIdCountry = ISNULL(@CustomerIdExpeditionCountry, 
				CustomerIdentificationIdCountry), CustomerBornDate = ISNULL(@CustomerDateOfBirth, CustomerBornDate), CustomerExpirationIdentification = ISNULL(@CustomerIdExpirationDate, 
				CustomerExpirationIdentification), CustomerOccupation = ISNULL(@CustomerOccupation, CustomerOccupation), CustomerIdentificationNumber = isnull(@CustomerIDNumber, CustomerIdentificationNumber),
				CustomerSSNumber = ISNULL(@CustomerSsnName, CustomerSSNumber), CustomerIdentificationIdState = ISNULL(@CustomerIdState, CustomerIdentificationIdState)
				where IdTransfer = @IdTransfer
		end

		/* Se actualiza info en Transfer sin idstate */
		if @IdTransfer is not null and (@CustomerIdState is null or @CustomerIdState = 0)
		Begin
			update Transfer set CustomerIdCustomerIdentificationType = ISNULL(@CustomerIdType, CustomerIdCustomerIdentificationType), CustomerIdentificationIdCountry = ISNULL(@CustomerIdExpeditionCountry, 
				CustomerIdentificationIdCountry), CustomerBornDate = ISNULL(@CustomerDateOfBirth, CustomerBornDate), CustomerExpirationIdentification = ISNULL(@CustomerIdExpirationDate, 
				CustomerExpirationIdentification), CustomerOccupation = ISNULL(@CustomerOccupation, CustomerOccupation), CustomerIdentificationNumber = isnull(@CustomerIDNumber, CustomerIdentificationNumber),
				CustomerSSNumber = ISNULL(@CustomerSsnName, CustomerSSNumber)
				where IdTransfer = @IdTransfer
		end

		/* Se actualiza la tabla de TransferAdditionalInfo para ya no solicitar la info proporcionada */
		if (@CustomerCustomerSSNRequired = 1 and @CustomerSsnName is not null)
			update MaxiMobile.TransferAdditionalInfo set CustomerSSN = 0 where IdTransfer = @IdTransfer

		if (@CustomerIdNumberRequired = 1 and @CustomerIDNumber is not null)
			update MaxiMobile.TransferAdditionalInfo set CustomerIDNumber = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerDateOfBirthRequired = 1 and @CustomerDateOfBirth is not null)
			update MaxiMobile.TransferAdditionalInfo set CustomerDateOfBirth = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerIdExpirationRequired = 1 and @CustomerIdExpirationDate is not null)
			update MaxiMobile.TransferAdditionalInfo set CustomerIDExpiration = 0 where IdTransfer = @IdTransfer

			update MaxiMobile.TransferAdditionalInfo set NumDocs = (select (CONVERT(int, RequiereID) + CONVERT(int, RequiereProof) + CONVERT(int, CustomerOccupation) + CONVERT(int, CustomerAddress) + 
				CONVERT(int, CustomerSSN) + CONVERT(int, IDNotLegible) + CONVERT(int, CustomerIDNumber) + CONVERT(int, CustomerDateOfBirth) + CONVERT(int, CustomerPlaceOfBirth) + CONVERT(int, CustomerIDExpiration) + 
				CONVERT(int, CustomerFullName) + CONVERT(int, CustomerFullAddress) + CONVERT(int, BeneficiaryFullName) + CONVERT(int, BeneficiaryDateOfBirth) + CONVERT(int, BeneficiaryPlaceOfBirth) + 
				CONVERT(int, BeneficiaryRequiereID) + CONVERT(int, SignReceipt)) from MaxiMobile.TransferAdditionalInfo where IdTransfer = @IdTransfer) where IdTransfer = @IdTransfer
	end	
END TRY
BEGIN CATCH
	set @IsSuccess = 0
	set @Message = 'Error al actualizar la información proporcionada'
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_SaveIDInfoRequiereByIdTransfer]',GETDATE(),@ErrorMessage)
END CATCH

