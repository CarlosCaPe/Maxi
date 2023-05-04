CREATE PROCEDURE [Corp].[st_GetAllProducts]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [IdOtherProducts], [Description], [Visible]
    FROM [dbo].[OtherProducts] WITH(NOLOCK)
END 



