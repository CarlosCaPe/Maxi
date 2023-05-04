CREATE PROCEDURE st_FetchPosActionType
AS
BEGIN
	SELECT
		pat.IdPosActionType		IdCatalog,
		pat.Code				Code,
		pat.PosActionType		[Name]
	FROM PosActionType pat WITH(NOLOCK)
END
