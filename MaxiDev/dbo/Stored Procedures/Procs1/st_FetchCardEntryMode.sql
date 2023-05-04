CREATE PROCEDURE st_FetchCardEntryMode
AS
BEGIN
	SELECT
		ce.IdCardEntryMode	IdCatalog,
		ce.Code				Code,
		ce.CardEntryMode	[Name]
	FROM CardEntryMode ce WITH(NOLOCK)
END
