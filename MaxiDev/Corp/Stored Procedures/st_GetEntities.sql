CREATE PROCEDURE [Corp].[st_GetEntities] 
	@IdEntityToValidate INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@IdEntityToValidate = 0)
		BEGIN
			SELECT [IdEntityToValidate], [Name], [Description], [IsAllowedToEdit]
			FROM [dbo].[EntityToValidate] WITH(NOLOCK)
			WHERE IsAllowedToEdit = 1
		END 
	ELSE 
		BEGIN 
			SELECT [IdEntityToValidate], [Name], [Description], [IsAllowedToEdit]
			FROM [dbo].[EntityToValidate] WITH(NOLOCK)
			WHERE IsAllowedToEdit = 1 AND IdEntityToValidate = @IdEntityToValidate
		END
END
