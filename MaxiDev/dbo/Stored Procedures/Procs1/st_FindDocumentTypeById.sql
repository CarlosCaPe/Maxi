CREATE PROCEDURE st_FindDocumentTypeById
(
	@IdDocumentType		INT
)
AS
BEGIN

	SELECT
		dt.IdDocumentType,
		dt.Name,
		dt.IdType IdOwnerType,
		dt.RelativePath,
		dt.GenerateBySystem,
		dt.IdDocumentTypeDad,
		dt.DateOfBirthRequired
	FROM DocumentTypes dt WITH(NOLOCK)
	WHERE dt.IdDocumentType = @IdDocumentType

END
