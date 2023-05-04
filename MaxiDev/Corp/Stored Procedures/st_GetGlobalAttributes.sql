CREATE PROCEDURE [Corp].[st_GetGlobalAttributes]
	-- Add the parameters for the stored procedure here
	@Name NVARCHAR(MAX) = NULL

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF LTRIM(@Name) = ''
		SET @Name = NULL

	SELECT
		[Name]
		, [Value]
		, [Description]
	FROM [dbo].[GlobalAttributes] WITH (NOLOCK)
	WHERE [Name] = ISNULL(@Name, [Name])
	

END
