CREATE procedure [Corp].[st_getUserAssignFromGroups_Collection]
as
select Distinct
	IdUserAssign,
	u.UserName 
from 
	Collection.Groups g with(nolock)
join users u with(nolock) on u.IdUser=g.IdUserAssign
where 
	IdUserAssign is not null and g.IdGenericStatus=1
order by 
	u.UserName
