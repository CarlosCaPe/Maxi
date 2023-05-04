CREATE PROCEDURE st_NSGetCatalogEntity
(
	@IdEntityType	INT
)
AS
BEGIN
	SELECT
		nc.*
	FROM NSCatalogEntity nc
	WHERE
		nc.IdNSEntity = @IdEntityType
END