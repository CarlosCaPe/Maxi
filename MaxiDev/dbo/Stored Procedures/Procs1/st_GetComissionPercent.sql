CREATE PROCEDURE [dbo].[st_GetComissionPercent] 
	@type NVARCHAR(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT [Name], [Value], [Description] 
	FROM [dbo].[GlobalAttributes] WITH(NOLOCK) 
	WHERE [Name] = @type


END

