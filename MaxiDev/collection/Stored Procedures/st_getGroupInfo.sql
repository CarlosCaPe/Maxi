create procedure collection.st_getGroupInfo
(
	@idgroup int
)
as
declare @IsSpecial bit 

select @IsSpecial=IsSpecial from collection.Groups where IdGroups=@idgroup

create table #real
(
	IdGroupsDetail int,
	Statecode nvarchar(max),
	IdSalesRep int,
	SalesrepName nvarchar(max),
	tot int
)


if @IsSpecial=0
begin
insert into #real
select d.IdGroupsDetail,d.Statecode,d.IdSalesRep, u.UserName SalesrepName, count(1) tot from Collection.Groups g
join collection.Groupsdetail d on g.idgroups=d.idgroups
join agent a on a.IdAgentClass=g.IdAgentClass and a.AgentState=d.statecode and a.IdUserSeller=d.IdSalesRep
left join users u on d.IdSalesRep=u.IdUser
where g.IdGenericStatus=1 and a.IdAgentStatus in (1,4) and [dbo].[fn_GetIsAgentException](idagent)=0 and IsSpecial=0 and g.IdGroups=@idgroup
group by d.IdGroupsDetail,d.Statecode,d.IdSalesRep,u.UserName

--insert into #real
--select d.IdGroupsDetail,d.Statecode,d.IdSalesRep,u.UserName SalesrepName, 0 tot from Collection.Groups g 
--join collection.Groupsdetail d on g.idgroups=d.idgroups
--left join users u on d.IdSalesRep=u.IdUser
--where g.IdGenericStatus=1 and IsSpecial=0 and g.IdGroups=@idgroup and d.IdGroupsDetail not in (select IdGroupsDetail from #real)

select Statecode,IdSalesRep,SalesrepName,tot from #real order by Statecode,SalesrepName

drop table #real

end
else
begin
insert into #real
select d.IdGroupsDetail,d.Statecode,d.IdSalesRep, u.UserName SalesrepName, count(1) tot from Collection.Groups g
join collection.Groupsdetail d on g.idgroups=d.idgroups
join agent a on a.IdAgentClass=g.IdAgentClass and a.AgentState=d.statecode and a.IdUserSeller=d.IdSalesRep
left join users u on d.IdSalesRep=u.IdUser
where g.IdGenericStatus=1 and (a.IdAgentStatus in (3) or [dbo].[fn_GetIsAgentException](idagent)=1) and IsSpecial=1 and g.IdGroups=@idgroup
group by d.IdGroupsDetail,d.Statecode,d.IdSalesRep,u.UserName

--insert into #real
--select d.IdGroupsDetail,d.Statecode,d.IdSalesRep,u.UserName SalesrepName, 0 tot from Collection.Groups g 
--join collection.Groupsdetail d on g.idgroups=d.idgroups
--left join users u on d.IdSalesRep=u.IdUser
--where g.IdGenericStatus=1 and IsSpecial=1 and g.IdGroups=@idgroup and d.IdGroupsDetail not in (select IdGroupsDetail from #real)

select Statecode,IdSalesRep,SalesrepName,tot from #real order by Statecode,SalesrepName

drop table #real

end