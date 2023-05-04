CREATE PROCEDURE st_FetchDocumentTypes
(
	@IdDocumentOwnerType	INT,

	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

	SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		dt.IdDocumentType,
		dt.Name,
		dt.IdType IdOwnerType,
		dt.RelativePath,
		dt.GenerateBySystem,
		dt.IdDocumentTypeDad,
		dt.DateOfBirthRequired
	FROM DocumentTypes dt
	WHERE (@IdDocumentOwnerType IS NULL OR dt.IdType = @IdDocumentOwnerType)
	ORDER BY dt.IdDocumentType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
END
