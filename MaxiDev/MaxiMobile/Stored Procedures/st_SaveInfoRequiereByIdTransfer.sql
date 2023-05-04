CREATE PROCEDURE [MaxiMobile].[st_SaveInfoRequiereByIdTransfer]
(
	@IdTransfer int,
	@CustomerName nvarchar(max) = null,
	@CustomerFirstLastName nvarchar(max) = null,
	@CustomerSecondLastName nvarchar(max) = null,
	@CustomerOccupation nvarchar(max) = null,
	@CustomerOccupationDetail nvarchar(max) = null,
	@CustomerAddress nvarchar(max) = null,
	@CustomerIDNumber nvarchar(max) = null,
	@CustomerSSN nvarchar(max) = null,
	@CustomerDateOfBirth DateTime = null,
	@CustomerPlaceOfBirth int = null,
	@BeneficiaryName nvarchar(max) = null,
	@BeneficiaryFirstLastName nvarchar(max) = null,
	@BeneficiarySecondLastName nvarchar(max) = null,
	@BeneficiaryDateOfBirth DateTime = null,
	@BeneficiaryPlaceOfBirth int = null,
	@BeneficiaryIdentificationType int = null,
	@BeneficiaryIDNumber nvarchar(max) = null,
	@IsSuccess bit out, 
	@Message nvarchar(max) out
)
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> Sp para guardar la información que se marco como requerida. No aplica para imagenes faltantes </Description>

<ChangeLog>
<log Date="14/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 

	set @IsSuccess = 1
	set @Message = 'Información actualizada correctamente'

	/* Revisa si hay información del customer que se tenga que actualizar, en caso de ser así se hace una copia de la info actual y se actualiza la info del customer */
	if (@CustomerOccupation is not null or @CustomerAddress is not null or @CustomerSSN is not null or @CustomerIDNumber is not null or @CustomerDateOfBirth is not null or @CustomerPlaceOfBirth is not null 
		or @CustomerName is not null or @CustomerFirstLastName is not null or @CustomerSecondLastName is not null or @CustomerOccupationDetail is not null)
	begin
		/* Se obtiene el tipo de info que se espera se tenga que actualizar */
		declare @CustomerOccupationRequired bit
		declare @CustomerAddressRequired bit
		declare @CustomerSSNRequired bit
		declare @CustomerIdNumberRequired bit
		declare @CustomerDateOfBirthRequired bit
		declare @CustomerPlaceOfBirthRequired bit
		declare @CustomerFullNameRequired bit
		declare @CustomerFullAddressRequired bit

		select @CustomerOccupationRequired = CustomerOccupation, @CustomerAddressRequired = CustomerAddress, @CustomerSSNRequired = CustomerSSN, @CustomerIdNumberRequired = CustomerIDNumber, 
			@CustomerDateOfBirthRequired = CustomerDateOfBirth, @CustomerPlaceOfBirthRequired = CustomerPlaceOfBirth, @CustomerFullNameRequired = CustomerFullName, @CustomerFullAddressRequired = 
			CustomerFullAddress from MaxiMobile.TransferAdditionalInfo (nolock) where IdTransfer = @IdTransfer

		/* Se actualiza la información del customer */
		declare @IdCustomer int
		select @IdCustomer = IdCustomer from Transfer (nolock) where IdTransfer = @IdTransfer

		/* Se guarda la info de customer en CustomerMirror */
		exec st_SaveCustomerMirror @IdCustomer

		/* Se actualiza info en Customer */
		if @IdCustomer is not null 
		BEGIN
			update Customer set Address = ISNULL(@CustomerAddress, Address), SSNumber = ISNULL(@CustomerSSN, SSNumber), IdentificationNumber = ISNULL(@CustomerIDNumber, IdentificationNumber), 
				BornDate = ISNULL(@CustomerDateOfBirth, BornDate), IdCountryOfBirth = ISNULL(@CustomerPlaceOfBirth, IdCountryOfBirth), Name = ISNULL(@CustomerName, Name), FirstLastName = ISNULL(@CustomerFirstLastName, FirstLastName), 
				SecondLastName = ISNULL(@CustomerSecondLastName, SecondLastName), Occupation = ISNULL(@CustomerOccupation, Occupation), OccupationDetail = ISNULL(@CustomerOccupationDetail, OccupationDetail) 
				where IdCustomer = @IdCustomer
		END
		
		/* Se actualiza info en Transfer */
		update Transfer set CustomerAddress = ISNULL(@CustomerAddress, CustomerAddress), CustomerSSNumber = ISNULL(@CustomerSSN, CustomerSSNumber), CustomerIdentificationNumber = ISNULL(@CustomerIDNumber, CustomerIdentificationNumber),
			CustomerBornDate = ISNULL(@CustomerDateOfBirth, CustomerBornDate), CustomerIdCountryOfBirth = ISNULL(@CustomerPlaceOfBirth, CustomerIdCountryOfBirth), CustomerName = ISNULL(@CustomerName, CustomerName), CustomerFirstLastName =
			ISNULL(@CustomerFirstLastName, CustomerFirstLastName), CustomerSecondLastName = ISNULL(@CustomerSecondLastName, CustomerSecondLastName), CustomerOccupation = ISNULL(@CustomerOccupation, CustomerOccupation), DateOfLastChange = 
			GETDATE() --OccupationDetail = ISNULL(NULLIF(@CustomerOccupationDetail, ''), OccupationDetail), 
			where IdTransfer = @IdTransfer

		/* Se actualiza la tabla de TransferAdditionalInfo para ya no solicitar la info proporcionada */
		if (@CustomerOccupationRequired = 1 and (@CustomerOccupation is not null or @CustomerOccupationDetail is not null))
			update MaxiMobile.TransferAdditionalInfo set CustomerOccupation = 0 where IdTransfer = @IdTransfer
			
		if ((@CustomerAddressRequired = 1 or @CustomerFullAddressRequired = 1) and @CustomerAddress is not null)
			update MaxiMobile.TransferAdditionalInfo set CustomerAddress = 0, CustomerFullAddress = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerSSNRequired = 1 and @CustomerSSN is not null)
			update MaxiMobile.TransferAdditionalInfo set CustomerSSN = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerIdNumberRequired = 1 and @CustomerIDNumber is not null)
			update MaxiMobile.TransferAdditionalInfo set CustomerIDNumber = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerDateOfBirthRequired = 1 and @CustomerDateOfBirth is not null)
			update MaxiMobile.TransferAdditionalInfo set CustomerDateOfBirth = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerPlaceOfBirthRequired = 1 and ISNULL(@CustomerPlaceOfBirth, 0) > 0)
			update MaxiMobile.TransferAdditionalInfo set CustomerPlaceOfBirth = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerFullNameRequired = 1 and (@CustomerName is not null or @CustomerFirstLastName is not null or @CustomerSecondLastName is not null))
			update MaxiMobile.TransferAdditionalInfo set CustomerFullName = 0 where IdTransfer = @IdTransfer

	end
	
	/* Revisa si hay información del beneficiario que se tenga que actualizar */
	if (@BeneficiaryName is not null or @BeneficiaryFirstLastName is not null or @BeneficiarySecondLastName is not null or @BeneficiaryDateOfBirth is not null or @BeneficiaryPlaceOfBirth is not null or 
		@BeneficiaryIdentificationType is not null or @BeneficiaryIDNumber is not null)
	begin 
		/* Se obtiene el tipo de info que se espera se tenga que actualizar */
		declare @BeneficiaryFullNameRequired bit
		declare @BeneficiaryDateOfBirthRequired bit
		declare @BeneficiaryPlaceOfBirthRequired bit
		declare @BeneficiaryRequiereIDRequired bit
		
		select @BeneficiaryFullNameRequired = BeneficiaryFullName, @BeneficiaryDateOfBirthRequired = BeneficiaryDateOfBirth, @BeneficiaryPlaceOfBirthRequired = BeneficiaryPlaceOfBirth, 
			@BeneficiaryRequiereIDRequired = BeneficiaryRequiereID from MaxiMobile.TransferAdditionalInfo (nolock) where IdTransfer = @IdTransfer
			
		/* Se actualiza la información del beneficiario */
		declare @IdBeneficiary int
		select @IdBeneficiary = IdBeneficiary from Transfer (nolock) where IdTransfer = @IdTransfer

		/* Se actualiza info en Beneficiary */
		if @IdBeneficiary is not null
		begin 
			update Beneficiary set Name = ISNULL(@BeneficiaryName, Name), FirstLastName = ISNULL(@BeneficiaryFirstLastName, FirstLastName), SecondLastName = ISNULL(@BeneficiarySecondLastName, SecondLastName), BornDate = 
				ISNULL(@BeneficiaryDateOfBirth, BornDate), IdCountryOfBirth = ISNULL(@BeneficiaryPlaceOfBirth, IdCountryOfBirth), IdBeneficiaryIdentificationType = ISNULL(@BeneficiaryIdentificationType, IdBeneficiaryIdentificationType), 
				IdentificationNumber = ISNULL(@BeneficiaryIDNumber, IdentificationNumber) where IdBeneficiary = @IdBeneficiary
		END

		/* Se actualiza info en Transfer */
		update Transfer set BeneficiaryName = ISNULL(@BeneficiaryName, BeneficiaryName), BeneficiaryFirstLastName = ISNULL(@BeneficiaryFirstLastName, BeneficiaryFirstLastName), BeneficiarySecondLastName = ISNULL(@BeneficiarySecondLastName,
			BeneficiarySecondLastName), BeneficiaryBornDate = ISNULL(@BeneficiaryDateOfBirth, BeneficiaryBornDate), BeneficiaryIdCountryOfBirth = ISNULL(@BeneficiaryPlaceOfBirth, BeneficiaryIdCountryOfBirth), 
			IdBeneficiaryIdentificationType = ISNULL(@BeneficiaryIdentificationType, IdBeneficiaryIdentificationType), BeneficiaryIdentificationNumber = ISNULL(@BeneficiaryIDNumber, BeneficiaryIdentificationNumber), 
			DateOfLastChange = GETDATE() where IdTransfer = @IdTransfer
			
		if (@BeneficiaryFullNameRequired = 1 and (@BeneficiaryName is not null or @BeneficiaryFirstLastName is not null or @BeneficiarySecondLastName is not null))
			update MaxiMobile.TransferAdditionalInfo set BeneficiaryFullName = 0 where IdTransfer = @IdTransfer
			
		if (@BeneficiaryDateOfBirthRequired = 1 and @BeneficiaryDateOfBirth is not null)
			update MaxiMobile.TransferAdditionalInfo set BeneficiaryDateOfBirth = 0 where IdTransfer = @IdTransfer
			
		if (@BeneficiaryPlaceOfBirthRequired = 1 and @BeneficiaryPlaceOfBirth is not null)
			update MaxiMobile.TransferAdditionalInfo set BeneficiaryPlaceOfBirth = 0 where IdTransfer = @IdTransfer
			
		if (@BeneficiaryRequiereIDRequired = 1 and (@BeneficiaryIdentificationType is not null and @BeneficiaryIDNumber is not null))
			update MaxiMobile.TransferAdditionalInfo set BeneficiaryRequiereID = 0 where IdTransfer = @IdTransfer
	end

	update MaxiMobile.TransferAdditionalInfo set NumDocs = (select (CONVERT(int, RequiereID) + CONVERT(int, RequiereProof) + CONVERT(int, CustomerOccupation) + CONVERT(int, CustomerAddress) + 
				CONVERT(int, CustomerSSN) + CONVERT(int, IDNotLegible) + CONVERT(int, CustomerIDNumber) + CONVERT(int, CustomerDateOfBirth) + CONVERT(int, CustomerPlaceOfBirth) + CONVERT(int, CustomerIDExpiration) + 
				CONVERT(int, CustomerFullName) + CONVERT(int, CustomerFullAddress) + CONVERT(int, BeneficiaryFullName) + CONVERT(int, BeneficiaryDateOfBirth) + CONVERT(int, BeneficiaryPlaceOfBirth) + 
				CONVERT(int, BeneficiaryRequiereID) + CONVERT(int, SignReceipt)) from MaxiMobile.TransferAdditionalInfo where IdTransfer = @IdTransfer) where IdTransfer = @IdTransfer

END TRY
BEGIN CATCH
	set @IsSuccess = 0
	set @Message = 'Error al actualizar la información proporcionada'
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_SaveInfoRequiereByIdTransfer]',GETDATE(),@ErrorMessage)
END CATCH
