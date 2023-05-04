CREATE PROCEDURE [Corp].[st_GetAgentForIdOwner]
@idOwner int
AS


Select A.IdAgent, A.AgentCode, A.AgentName, Ast.AgentStatus 
FROM Agent A
	inner join AgentStatus Ast on Ast.IdAgentStatus=A.IdAgentStatus
WHERE A.IdOwner=@idOwner
order by A.AgentCode

