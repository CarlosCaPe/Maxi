
CREATE VIEW [collection].[Group_Assigment] AS
select distinct g.IdGroups,idagent,a.AgentCode,a.IdAgentStatus,a.AgentState,g.groupname,case when IsSpecial=1 then 'Special Category ' else '' end + c.Description  AgentClass,u.username,IdUserAssign,IsSpecial, [dbo].[fn_GetIsAgentException](idagent) IsException from collection.Groups g (nolock)
join collection.Groupsdetail d (nolock) on g.idgroups=d.idgroups
join agent a (nolock) on a.IdAgentClass=g.IdAgentClass and a.AgentState=d.statecode and a.IdUserSeller=d.IdSalesRep
join AgentClass c (nolock) on c.IdAgentClass=g.idagentclass
join users u (nolock) on g.iduserassign=u.IdUser
where g.IdGenericStatus=1 and a.IdAgentStatus in (1,4) and [dbo].[fn_GetIsAgentException](idagent)=0 and IsSpecial=0
union
select distinct g.IdGroups,idagent,a.AgentCode,a.IdAgentStatus,a.AgentState,g.groupname,case when IsSpecial=1 then 'Special Category ' else '' end + c.Description  AgentClass,u.username,IdUserAssign,IsSpecial, [dbo].[fn_GetIsAgentException](idagent) IsException from collection.Groups g (nolock)
join collection.Groupsdetail d (nolock) on g.idgroups=d.idgroups
join agent a (nolock) on a.IdAgentClass=g.IdAgentClass and a.AgentState=d.statecode and a.IdUserSeller=d.IdSalesRep
join AgentClass c (nolock) on c.IdAgentClass=g.idagentclass
join users u (nolock) on g.iduserassign=u.IdUser
where g.IdGenericStatus=1 and (a.IdAgentStatus in (3) or [dbo].[fn_GetIsAgentException](idagent)=1) and IsSpecial=1





