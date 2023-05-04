CREATE PROCEDURE [Corp].[st_GetAgentStatusByIdStatus]
	@IdAgentStatus INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdAgentStatus], [AgentStatus], [DateOfLastChange], [EnterByIdUser], [VisibleForUser]	
	FROM [dbo].[AgentStatus] WITH(NOLOCK)
	WHERE @IdAgentStatus = IdAgentStatus

END 
