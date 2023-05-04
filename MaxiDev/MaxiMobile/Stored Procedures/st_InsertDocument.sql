CREATE PROCEDURE [MaxiMobile].[st_InsertDocument]
(
	@IdTransfer int, 
	@IdCustomer int,
	@IdDocumentType int,
	@IdDocumentImageType int, 
	@FileName nvarchar(max),
	@FileGuid nvarchar(max),
	@Extension nvarchar(max),
	@EnterByIdUser int, 
	@ExpirationDate datetime,
	@DateOfBirth datetime,
	@HasError bit out, 
	@Message nvarchar(max) out
)
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> Sp para guardar la imagen de la identificacion en la tabla de UploadDocument </Description>

<ChangeLog>
<log Date="24/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 
select * from MaxiMobile.TransferAdditionalInfo
	set @HasError = 0
	set @Message = 'Información actualizada correctamente'

		/* Se obtiene el tipo de info que se espera se tenga que actualizar */
		declare @CustomerIdRequired bit
		declare @CustomerIdNotLegibleRequired bit
		declare @CustomerDateOfBirthRequired bit
		declare @CustomerIdExpirationRequired bit
		declare @UploadFileId int

		select @CustomerIdRequired = RequiereID, @CustomerIdNotLegibleRequired = IDNotLegible, @CustomerDateOfBirthRequired = CustomerDateOfBirth, 
			@CustomerIdExpirationRequired = CustomerIDExpiration from MaxiMobile.TransferAdditionalInfo (nolock) where IdTransfer = @IdTransfer
			
		/* Se guarda la info de customer en CustomerMirror */
		exec st_SaveCustomerMirror @IdCustomer

		/* Se actualiza info en Customer */
		update Customer set IdCustomerIdentificationType = @IdDocumentType, ExpirationIdentification = @ExpirationDate, BornDate = @DateOfBirth where IdCustomer = @IdCustomer
		
		/* Se actualiza info en Transfer */
		update Transfer set CustomerIdCustomerIdentificationType = @IdDocumentType, CustomerBornDate = @DateOfBirth, CustomerExpirationIdentification = @ExpirationDate where IdTransfer = @IdTransfer

		/* Se inserta en la tabla de UploadFiles el registro y su detalle */
		insert into UploadFiles (IdReference, IdDocumentType, FileName, FileGuid, Extension, IdStatus, IdUser, LastChange_LastUserChange, LastChange_LastDateChange, LastChange_LastIpChange, LastChange_LastNoteChange,
			ExpirationDate, CreationDate, IsPhysicalDeleted, DateOfBirth) values (@IdCustomer, @IdDocumentType, @FileName, @FileGuid, @Extension, 1, @EnterByIdUser, @EnterByIdUser, getdate(), '::1', 
			'Upload from Maxi mobile', @ExpirationDate, getdate(), null, @DateOfBirth)
			
		set @UploadFileId = SCOPE_IDENTITY()
		insert into UploadFilesDetail (IdUploadFile, IdDocumentImageType, IdCountry, IdState) values (@UploadFileId, @IdDocumentImageType, null, null)


		/* Se actualiza la tabla de TransferAdditionalInfo para ya no solicitar la info proporcionada */
		if (@CustomerIdRequired = 1)
			update MaxiMobile.TransferAdditionalInfo set RequiereID = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerIdNotLegibleRequired = 1)
			update MaxiMobile.TransferAdditionalInfo set IDNotLegible = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerDateOfBirthRequired = 1)
			update MaxiMobile.TransferAdditionalInfo set CustomerDateOfBirth = 0 where IdTransfer = @IdTransfer
			
		if (@CustomerIdExpirationRequired = 1)
			update MaxiMobile.TransferAdditionalInfo set CustomerIDExpiration = 0 where IdTransfer = @IdTransfer

			update MaxiMobile.TransferAdditionalInfo set NumDocs = (select (CONVERT(int, RequiereID) + CONVERT(int, RequiereProof) + CONVERT(int, CustomerOccupation) + CONVERT(int, CustomerAddress) + 
				CONVERT(int, CustomerSSN) + CONVERT(int, IDNotLegible) + CONVERT(int, CustomerIDNumber) + CONVERT(int, CustomerDateOfBirth) + CONVERT(int, CustomerPlaceOfBirth) + CONVERT(int, CustomerIDExpiration) + 
				CONVERT(int, CustomerFullName) + CONVERT(int, CustomerFullAddress) + CONVERT(int, BeneficiaryFullName) + CONVERT(int, BeneficiaryDateOfBirth) + CONVERT(int, BeneficiaryPlaceOfBirth) + 
				CONVERT(int, BeneficiaryRequiereID) + CONVERT(int, SignReceipt)) from MaxiMobile.TransferAdditionalInfo where IdTransfer = @IdTransfer) where IdTransfer = @IdTransfer
	
END TRY
BEGIN CATCH
	set @HasError = 1
	set @Message = 'Error al actualizar la información proporcionada'
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_InsertDocument]',GETDATE(),@ErrorMessage)
END CATCH
