/********************************************************************
<Author>Unknow</Author>
<app>Migración Corporativo</app>
<Description></Description>

<ChangeLog>
	<log Date="28/07/2020" Author="jzuñiga">Se agrega condición para requerimiento M00094</log>
</ChangeLog>
*********************************************************************/
CREATE procedure [Corp].[st_GetGroupInfo_Collection]
(
	@idgroup int
)
as
declare @IsSpecial bit 

select @IsSpecial=IsSpecial from collection.Groups with(nolock) where IdGroups=@idgroup

create table #real
(
	IdGroupsDetail int,
	Statecode nvarchar(max),
	IdSalesRep int,
	SalesrepName nvarchar(max),
	tot int
)

if @IsSpecial=0 begin
	insert into #real
	select d.IdGroupsDetail,d.Statecode,d.IdSalesRep, u.UserName SalesrepName, count(1) tot from Collection.Groups g with(nolock)
	join collection.Groupsdetail d with(nolock) on g.idgroups=d.idgroups
	join agent a with(nolock) on a.IdAgentClass=g.IdAgentClass and a.AgentState=d.statecode and a.IdUserSeller=d.IdSalesRep and (a.AgentCode = d.AgentCode OR isnull(d.AgentCode,'') = '') --M00094
	left join users u with(nolock) on d.IdSalesRep=u.IdUser
	where g.IdGenericStatus=1 and a.IdAgentStatus in (1,4) and [dbo].[fn_GetIsAgentException](idagent)=0 and IsSpecial=0 and g.IdGroups=@idgroup
	group by d.IdGroupsDetail,d.Statecode,d.IdSalesRep,u.UserName

	select Statecode,IdSalesRep,SalesrepName,tot from #real order by Statecode,SalesrepName

	drop table #real

end else begin
	insert into #real
	select d.IdGroupsDetail,d.Statecode,d.IdSalesRep, u.UserName SalesrepName, count(1) tot from Collection.Groups g with(nolock)
	join collection.Groupsdetail d with(nolock) on g.idgroups=d.idgroups
	join agent a with(nolock) on a.IdAgentClass=g.IdAgentClass and a.AgentState=d.statecode and a.IdUserSeller=d.IdSalesRep and (a.AgentCode = d.AgentCode OR isnull(d.AgentCode,'') = '') --M00094
	left join users u with(nolock) on d.IdSalesRep=u.IdUser
	where g.IdGenericStatus=1 and (a.IdAgentStatus in (3) or [dbo].[fn_GetIsAgentException](idagent)=1) and IsSpecial=1 and g.IdGroups=@idgroup
	group by d.IdGroupsDetail,d.Statecode,d.IdSalesRep,u.UserName

	select Statecode,IdSalesRep,SalesrepName,tot from #real order by Statecode,SalesrepName

	drop table #real

end