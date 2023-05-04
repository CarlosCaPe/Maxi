CREATE PROCEDURE st_FetchUploadFiles
(
	@IdReference				BIGINT,
	@IdDocumentOwnerType		INT,
	@IncludeBytes				BIT,

	@Offset						BIGINT,
	@Limit						BIGINT
)
AS
BEGIN

	SELECT 
		COUNT(*) OVER() _PagedResult_Total,
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
		CASE 
			WHEN ISNULL(@IncludeBytes, 0) = 1 THEN dbo.GetUploadFilePath(uf.IdUploadFile)
			ELSE NULL
		END FilePath
	FROM UploadFiles uf
		JOIN DocumentTypes dt WITH(NOLOCK) ON dt.IdDocumentType = uf.IdDocumentType
	WHERE
		uf.IdReference = @IdReference AND dt.IdType = @IdDocumentOwnerType
	ORDER BY uf.IdUploadFile
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
