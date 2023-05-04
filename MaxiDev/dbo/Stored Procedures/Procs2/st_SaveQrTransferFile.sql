
CREATE PROCEDURE [dbo].[st_SaveQrTransferFile]	
	@IdTransfer INT,
	@FileName NVARCHAR(MAX),
	@FileGuid NVARCHAR(MAX),
	@Extension NVARCHAR(MAX),
	@Prefix NVARCHAR(MAX) = 'T'
	AS
BEGIN
	DECLARE @idSystemUser as int

	SET @idSystemUser = dbo.GetGlobalAttributeByName('SystemUserID')

	DECLARE @DocumentType INT

	SET @DocumentType = CASE @Prefix 
						WHEN 'F' THEN 71 -- Compliance Format
						ELSE 55 END -- Transaction Receipt

	INSERT INTO UploadFiles(IdReference, IdDocumentType, [FileName], Fileguid, Extension, IdStatus, IdUser, LastChange_LastDateChange, LastChange_LastUserChange, LastChange_LastIpChange, LastChange_LastNoteChange)
	VALUES(@IdTransfer, @DocumentType, @FileName, @FileGuid, @Extension, 1, @idSystemUser, GETDATE(), @idSystemUser, '::1', 'Processed QR File')

	IF @DocumentType = 55
	BEGIN
		EXEC [dbo].[st_InsertUpdateRelationTransferDocumentTransferStatus] @IdTransfer, 1, @idSystemUser, 1
	END
END
