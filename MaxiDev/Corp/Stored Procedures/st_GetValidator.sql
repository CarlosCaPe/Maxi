CREATE PROCEDURE [Corp].[st_GetValidator] 
	@IdValidator INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdValidator], [ValidatorName], [Description]
	FROM [dbo].[Validator] WITH(NOLOCK)
	WHERE IdValidator = @IdValidator
END
