CREATE PROCEDURE [Corp].[st_GetAgentWithActiveMessages]
as
SET NOCOUNT ON;
select 

	a.IdAgent,
	a.AgentCode, 
	a.AgentName, 
	count(DISTINCT m.IdMessage) as ActiveNotifications 
from msg.MessageSubcribers ms WITH(NOLOCK)
	inner join msg.Messages m WITH(NOLOCK) on ms.IdMessage = m.IdMessage 
	inner join AgentUser au WITH(NOLOCK) on ms.IdUser = au.IdUser
	inner join Agent a WITH(NOLOCK) on au.IdAgent = a.IdAgent
where ms.IdMessageStatus <= 3
group by a.IdAgent, a.AgentCode, a.AgentName
order by a.AgentCode
