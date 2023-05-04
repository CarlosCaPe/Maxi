CREATE PROCEDURE Corp.st_GetAgentsToCorrectBalance
AS
BEGIN

	SELECT A.AgentCode, A.AgentName, convert(DATETIME, ATC.[BEGIN]) AS 'ApplyDate', S.AgentStatus
	FROM soporte.AgentToCorrect ATC WITH(NOLOCK)
	INNER JOIN Agent A WITH(NOLOCK) ON A.IdAgent = ATC.IdAgent
	INNER JOIN AgentStatus S WITH(NOLOCK) ON S.IdAgentStatus = A.IdAgentStatus
	ORDER BY ATC.[BEGIN] ASC

END 