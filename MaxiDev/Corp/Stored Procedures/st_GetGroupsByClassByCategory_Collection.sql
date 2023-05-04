﻿CREATE procedure [Corp].[st_GetGroupsByClassByCategory_Collection]
(
	@IdAgentClass int,
	@IsSpecial bit 
)
as
/********************************************************************
<Author></Author>
<app>Migracion Corporativo</app>
<Description></Description>

<ChangeLog>
	<log Date="28/07/2020" Author="omurillo">Se agregaron parametros para las consultas || requerimiento M00094</log>
</ChangeLog>
*********************************************************************/
create table #tmpinfo
(
	IdGroups int,
	groupName nvarchar(max),
	IdUserAssign int,
	UserAssigned nvarchar(max),
	IdAgentClass int,
	ClassName nvarchar(50),
	tot int
)

if @IsSpecial=0 begin
	insert into #tmpinfo
	select g.IdGroups,groupName, isnull(g.IdUserAssign,0) IdUserAssign, isnull(u.UserName,'') UserAssigned,g.IdAgentClass,c.Description ClassName, count(1) tot from Collection.Groups g with(nolock)
	join collection.Groupsdetail d with(nolock) on g.idgroups=d.idgroups
	join agent a with(nolock) on a.IdAgentClass=g.IdAgentClass and a.AgentState=d.statecode and a.IdUserSeller=d.IdSalesRep and (a.AgentCode = d.AgentCode OR isnull(d.AgentCode,'') = '') --M00094
	join AgentClass c with(nolock) on g.IdAgentClass=c.IdAgentClass
	left join users u with(nolock) on g.iduserassign=u.IdUser
	where g.IdGenericStatus=1 and a.IdAgentStatus in (1,4) and [dbo].[fn_GetIsAgentException](idagent)=0 and IsSpecial=0 and g.IdAgentClass=@idagentclass
	group by g.IdGroups,groupName,IdUserAssign,g.IdUserAssign,u.UserName,g.IdAgentClass,c.Description
end else begin
	insert into #tmpinfo
	select g.IdGroups,groupName, isnull(g.IdUserAssign,0) IdUserAssign, isnull(u.UserName,'') UserAssigned,g.IdAgentClass,c.Description ClassName, count(1) tot from Collection.Groups g with(nolock)
	join collection.Groupsdetail d with(nolock) on g.idgroups=d.idgroups
	join agent a with(nolock) on a.IdAgentClass=g.IdAgentClass and a.AgentState=d.statecode and a.IdUserSeller=d.IdSalesRep and (a.AgentCode = d.AgentCode OR isnull(d.AgentCode,'') = '') --M00094
	join AgentClass c with(nolock) on g.IdAgentClass=c.IdAgentClass
	left join users u with(nolock) on g.iduserassign=u.IdUser
	where g.IdGenericStatus=1 and (a.IdAgentStatus in (3) or [dbo].[fn_GetIsAgentException](idagent)=1) and IsSpecial=1 and g.IdAgentClass=@idagentclass
	group by g.IdGroups,groupName,IdUserAssign,g.IdUserAssign,u.UserName,g.IdAgentClass,c.Description
end

insert into #tmpinfo
select g.IdGroups,groupName, isnull(g.IdUserAssign,0) IdUserAssign, isnull(u.UserName,'') UserAssigned,g.IdAgentClass,c.Description ClassName, 0 tot from Collection.Groups g with(nolock)
join AgentClass c with(nolock) on g.IdAgentClass=c.IdAgentClass
left join users u with(nolock) on g.iduserassign=u.IdUser
where g.IdGenericStatus=1 and IsSpecial=@IsSpecial and g.IdAgentClass=@IdAgentClass and IdGroups not in (select IdGroups from #tmpinfo)

select * from #tmpinfo order by groupName,UserAssigned