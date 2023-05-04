CREATE procedure [Corp].[GetAgentStatusByAgentId]
(
    @IdAgent int
)
as
	select IdAgentStatus from agent with(nolock) where IdAgent = @IdAgent
