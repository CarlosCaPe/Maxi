CREATE PROCEDURE [Corp].[st_GetEntityToValidate] 
	@IdEntityToValidate INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdEntityToValidate], [Name], [Description], [IsAllowedToEdit]
	FROM [dbo].[EntityToValidate] WITH(NOLOCK)
	WHERE IdEntityToValidate = @IdEntityToValidate
END
