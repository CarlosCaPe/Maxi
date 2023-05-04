CREATE PROCEDURE [Corp].[st_GetAgentsByOwner]
	-- Add the parameters for the stored procedure here
	@IdOwner INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT
		A.[IdAgent]
		,A.[AgentCode]
		,A.[AgentName]
		,AC.[Name] AgentClassName
		,S.[AgentStatus]
		,ISNULL(ACB.[Balance],0) CurrentBalance
		,ISNULL(C.[AmountToPay],0) AmountToPay
	FROM [dbo].[Agent] A (NOLOCK)
	JOIN [dbo].[AgentStatus] S (NOLOCK) ON A.[IdAgentStatus] = S.[IdAgentStatus]
	JOIN [dbo].[AgentClass] AC (NOLOCK) ON A.[IdAgentClass] = AC.[IdAgentClass]
	LEFT JOIN [dbo].[AgentCurrentBalance] ACB (NOLOCK) ON A.[IdAgent] = ACB.IdAgent
	LEFT JOIN [dbo].[AgentCollection] C (NOLOCK) ON A.[IdAgent] = C.[IdAgent]
	WHERE A.IdOwner = @IdOwner
	ORDER BY A.[AgentCode]

END
