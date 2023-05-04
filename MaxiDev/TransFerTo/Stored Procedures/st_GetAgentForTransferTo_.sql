create  procedure [TransFerTo].[st_GetAgentForTransferTo?]
as
select idagent,agentcode,agentname,a.idagentstatus, agentstatus
from 
    agent a with (nolock)
join
    agentstatus s on s.IdAgentStatus=a.IdAgentStatus
where 
    idagent in
    (
        select idagent from dbo.AgentOtherProductInfo where IdOtherProduct=7
    )
order by agentcode