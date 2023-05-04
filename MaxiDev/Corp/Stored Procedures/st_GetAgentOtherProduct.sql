CREATE PROCEDURE [Corp].[st_GetAgentOtherProduct]
	@IdAgent INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdAgent], [IdGenericStatus], [IdOtherProducts]
	FROM [dbo].[AgentProducts] WITH(NOLOCK)
	WHERE IdAgent = @IdAgent
END

