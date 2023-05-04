--store usuarios asignados a los grupos.
create procedure collection.st_getUserAssignFromGroups
as
select Distinct
	IdUserAssign,
	u.UserName 
from 
	Collection.Groups g
join users u on u.IdUser=g.IdUserAssign
where 
	IdUserAssign is not null and g.IdGenericStatus=1
order by 
	u.UserName