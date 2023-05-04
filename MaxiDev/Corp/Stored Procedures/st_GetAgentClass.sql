CREATE PROCEDURE [Corp].[st_GetAgentClass]
	@IdAgentClass INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdAgentClass], [Name], [Description], [DateOfLastChange], [EnterByIdUser], [ClassPercent]	
	FROM [dbo].[AgentClass] WITH(NOLOCK)
	WHERE IdAgentClass = @IdAgentClass

END 
