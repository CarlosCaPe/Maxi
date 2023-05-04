CREATE PROCEDURE [Corp].[st_GetAgentStatus]
(
    @IdAgent int
)
as

if((select IdAgentStatus from agent where IdAgent = @IdAgent) = 1)
	select IdGenericStatus as IdAgentStatus from TransFerTo.AgentCredential where IdAgent = @IdAgent
else
	select IdAgentStatus from agent where IdAgent = @IdAgent
