CREATE PROCEDURE st_FetchCardType
AS
BEGIN
	SELECT
		ct.IdCardType		IdCatalog,
		ct.Code				Code,
		ct.CardType			[Name]
	FROM CardType ct WITH(NOLOCK)
END
