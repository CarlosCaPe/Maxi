CREATE PROCEDURE [Corp].[st_GetLunexOtherProducts_lunex]
AS

	SELECT
		[IdOtherProducts]
		, [Description]
	FROM [dbo].[OtherProducts] WITH (NOLOCK)
	WHERE [IdOtherProducts] IN (10,11,13,16)
	ORDER BY [Description]



