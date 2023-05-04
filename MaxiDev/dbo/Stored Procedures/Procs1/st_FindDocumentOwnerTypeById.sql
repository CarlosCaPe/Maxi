CREATE PROCEDURE st_FindDocumentOwnerTypeById
(
	@IdDocumentOwnerType		INT
)
AS
BEGIN

	SELECT
		do.IdDocumentOwnerType Id,
		do.Name
	FROM DocumentOwnerType do WITH(NOLOCK)
	WHERE do.IdDocumentOwnerType = @IdDocumentOwnerType

END
