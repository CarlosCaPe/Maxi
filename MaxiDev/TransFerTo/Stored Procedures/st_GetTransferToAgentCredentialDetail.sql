create procedure TransferTo.st_GetTransferToAgentCredentialDetail
(
    @IdAgentCredential int
)
as
select 
    idagentcredential,t.idagent,agentname,agentcode,t.username TToUserName,t.userpassword TToUserPassword,t.DateOfLastChange,t.EnterByIdUser,u.username EnterByIdUserName,t.idgenericstatus 
from 
    [TransFerTo].[AgentCredential] t
join agent a on t.idagent=a.idagent
join users u on u.iduser=t.EnterByIdUser
where idagentcredential=@IdAgentCredential