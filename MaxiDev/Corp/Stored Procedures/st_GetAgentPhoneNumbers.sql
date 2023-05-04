CREATE PROCEDURE [Corp].[st_GetAgentPhoneNumbers]
	@IdAgent INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdAgentPhoneNumber], [IdAgent], [PhoneNumber], [Comment]
	FROM [dbo].[AgentPhoneNumber] WITH(NOLOCK)
	WHERE IdAgent = @IdAgent

END 
