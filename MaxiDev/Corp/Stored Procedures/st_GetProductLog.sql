CREATE PROCEDURE [Corp].[st_GetProductLog] 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [id], [idProduct], [logDate], [idAgent], [Provider], [Operation], [Message], [Request], [Response]
	FROM [dbo].[ProductsLog] WITH(NOlOCK)
END

