CREATE PROCEDURE [MaxiMobile].[st_InsertDocumentByTransferReceipt]
(
	@IdTransfer int, 
	@IdDocumentType int,
	--@IdDocumentImageType int, 
	@FileName nvarchar(max),
	@FileGuid nvarchar(max),
	@Extension nvarchar(max),
	@EnterByIdUser int, 
	--@ExpirationDate datetime,
	--@DateOfBirth datetime,
	@HasError bit out, 
	@Message nvarchar(max) out
)
/********************************************************************
<Author> Juan Hernandez </Author>
<app> MaxiFaxApp </app>
<Description> Sp para guardar el recibo de la Transferencia </Description>

*********************************************************************/
as
Begin Try 
	set @HasError = 0
	set @Message = 'Información creada correctamente'
			
		declare @UploadFileId int

		/* Se inserta en la tabla de UploadFiles el registro y su detalle */
		insert into UploadFiles (IdReference, IdDocumentType, FileName, FileGuid, Extension, IdStatus, IdUser, LastChange_LastUserChange, LastChange_LastDateChange, LastChange_LastIpChange, LastChange_LastNoteChange,
			ExpirationDate, CreationDate, IsPhysicalDeleted, DateOfBirth) values (@IdTransfer, @IdDocumentType, @FileName, @FileGuid, @Extension, 1, @EnterByIdUser, @EnterByIdUser, getdate(), '::1', 
			'Upload from MaxiMobile', null, getdate(), null, null)
			
		set @UploadFileId = SCOPE_IDENTITY()
		--insert into UploadFilesDetail (IdUploadFile, IdDocumentImageType, IdCountry, IdState) values (@UploadFileId, @IdDocumentImageType, null, null)
		insert into UploadFilesDetail (IdUploadFile, IdDocumentImageType, IdCountry, IdState) values (@UploadFileId, 3, null, null)
	
		/* Se guarda la relacion del documento con la Transferencia */
		exec [dbo].[st_InsertUpdateRelationTransferDocumentTransferStatus] @IdTransfer,1,@EnterByIdUser,0

END TRY
BEGIN CATCH
	set @HasError = 1
	set @Message = 'Error al actualizar la información proporcionada'
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_InsertDocumentByTransferReceipt]',GETDATE(),@ErrorMessage)
END CATCH
