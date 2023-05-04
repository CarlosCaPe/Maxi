
CREATE procedure [dbo].[st_GetAgentWithActiveMessages] as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

select 
	a.IdAgent,
	a.AgentCode, 
	a.AgentName, 
	count(DISTINCT m.IdMessage) as ActiveNotifications 
from msg.MessageSubcribers ms with(nolock)
	inner join msg.[Messages] m with(nolock)on ms.IdMessage = m.IdMessage 
	inner join AgentUser au with(nolock) on ms.IdUser = au.IdUser
	inner join Agent a with(nolock) on au.IdAgent = a.IdAgent
where ms.IdMessageStatus <= 3
group by a.IdAgent, a.AgentCode, a.AgentName
order by a.AgentCode