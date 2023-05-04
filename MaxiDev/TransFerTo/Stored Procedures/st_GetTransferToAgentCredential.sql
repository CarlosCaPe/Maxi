create procedure TransferTo.st_GetTransferToAgentCredential
as
select 
    idagentcredential,t.idagent,agentname,agentcode,idgenericstatus,a.idagentstatus,Agentstatus
from 
    [TransFerTo].[AgentCredential] t
join agent a on t.idagent=a.idagent
join agentstatus s on a.idagentstatus=s.idagentstatus

