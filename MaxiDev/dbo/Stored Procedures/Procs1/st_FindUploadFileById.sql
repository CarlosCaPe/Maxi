CREATE PROCEDURE st_FindUploadFileById
(
	@IdUploadFile		INT
)
AS
BEGIN
	SELECT
		uf.IdUploadFile,
		uf.IdReference,
		uf.IdDocumentType,
		uf.FileName,
		uf.FileGuid,
		uf.Extension,
		uf.IdStatus,
		uf.IdUser,
		uf.LastChange_LastUserChange,
		uf.LastChange_LastDateChange,
		uf.LastChange_LastIpChange,
		uf.LastChange_LastNoteChange,
		uf.ExpirationDate,
		uf.CreationDate,
		uf.IsPhysicalDeleted,
		uf.DateOfBirth,
		dbo.GetUploadFilePath(uf.IdUploadFile) FilePath
	FROM UploadFiles uf WITH(NOLOCK)
	WHERE uf.IdUploadFile = @IdUploadFile
END
