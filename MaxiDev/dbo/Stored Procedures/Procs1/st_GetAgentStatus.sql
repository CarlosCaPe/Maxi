
CREATE PROCEDURE [dbo].[st_GetAgentStatus]
(
    @IdAgent int
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

if((select IdAgentStatus from agent with(nolock) where IdAgent = @IdAgent) = 1)
	select IdGenericStatus as IdAgentStatus from TransFerTo.AgentCredential with(nolock) where IdAgent = @IdAgent
else
	select IdAgentStatus from agent with(nolock) where IdAgent = @IdAgent
