CREATE PROCEDURE st_FetchPosStatus
AS
BEGIN
	SELECT
		ps.IdPosStatus	IdCatalog,
		ps.Code			Code,
		ps.PosStatus	[Name]
	FROM PosStatus ps WITH(NOLOCK)
END
