CREATE PROCEDURE [MaxiMobile].[st_InsertSourceFound]
(
	@IdTransfer int, 
	@IdDocumentType int,
	@FileName nvarchar(max),
	@FileGuid nvarchar(max),
	@Extension nvarchar(max),
	@EnterByIdUser int, 
	@HasError bit out, 
	@Message nvarchar(max) out
)
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> Sp para guardar la imagen del comprobante de ingresos en la tabla de UploadDocument </Description>

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
		declare @RequiereProof bit

		select @RequiereProof = RequiereProof from MaxiMobile.TransferAdditionalInfo (nolock) where IdTransfer = @IdTransfer
		
		/* Se inserta en la tabla de UploadFiles el registro y su detalle */
		insert into UploadFiles (IdReference, IdDocumentType, FileName, FileGuid, Extension, IdStatus, IdUser, LastChange_LastUserChange, LastChange_LastDateChange, LastChange_LastIpChange, LastChange_LastNoteChange,
			ExpirationDate, CreationDate, IsPhysicalDeleted, DateOfBirth) values (@IdTransfer, @IdDocumentType, @FileName, @FileGuid, @Extension, 1, @EnterByIdUser, @EnterByIdUser, getdate(), '::1', 
			'Upload from Maxi mobile', null, getdate(), null, null)
			


		/* Se actualiza la tabla de TransferAdditionalInfo para ya no solicitar la info proporcionada */
		if (@RequiereProof = 1)
			update MaxiMobile.TransferAdditionalInfo set RequiereProof = 0 where IdTransfer = @IdTransfer
	
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
	VALUES('[MaxiMobile].[st_InsertSourceFound]',GETDATE(),@ErrorMessage)
END CATCH
