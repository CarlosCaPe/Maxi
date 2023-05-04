
CREATE PROCEDURE st_NSBulkInsertCatalogs
(
	 @Source	XML
)
AS
BEGIN
	SELECT
		s.c.value('IdNSEntity[1]', 'INT') IdNSEntity,
		s.c.value('InternalId[1]', 'INT') InternalId,
		s.c.value('Name[1]', 'NVARCHAR(200)') Name,
		s.c.value('ExternalId[1]', 'NVARCHAR(200)') ExternalId
	INTO #TempCatalog
	FROM @Source.nodes('/Source/NSCatalogEntity') s(c)

	INSERT INTO NSCatalogEntity(IdNSEntity, InternalId, Name, ExternalId, CreationDate)
	SELECT
		tc.IdNSEntity,
		tc.InternalId,
		tc.Name,
		tc.ExternalId,
		GETDATE()
	FROM #TempCatalog tc
	WHERE NOT EXISTS (SELECT * FROM NSCatalogEntity nc WHERE nc.InternalId = tc.InternalId AND nc.IdNSEntity = tc.IdNSEntity)

	UPDATE nc SET
		nc.Name = tc.Name,
		nc.ExternalId = tc.ExternalId,
		nc.CreationDate = GETDATE()
	FROM NSCatalogEntity nc
		JOIN #TempCatalog tc ON nc.InternalId = tc.InternalId AND nc.IdNSEntity = tc.IdNSEntity
END
