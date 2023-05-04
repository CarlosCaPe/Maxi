CREATE PROCEDURE [Corp].[st_GetFieldToValidate] 
	@IdEntityToValidate INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdFieldToVAlidate], [IdEntityToValidate], [Name], [Description]
	FROM [dbo].[FieldToValidate] WITH(NOLOCK)
	WHERE IdEntityToValidate = @IdEntityToValidate

END
