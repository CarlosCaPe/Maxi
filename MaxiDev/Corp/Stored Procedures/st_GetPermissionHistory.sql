CREATE procedure [Corp].[st_GetPermissionHistory]
    @idUser int
as

select 
	Uop.Date,
	O.IdOption,
	Uop.Change,
	U.FirstName + ' ' + U.LastName as Name,
	M.Name ModuleName,
	M.Description as 'Module Description',
	O.Name OptionName,
	O.Description as 'Option Description',
	A.Code ActionCode,
	A.Description as 'Action Description'
from Modulo M with(nolock)
	inner join [Option] O with(nolock) on M.IdModule=O.IdModule
	inner join ActionAllowed A with(nolock) on O.IdOption = A.IdOption
	inner join UserOptionChangeHistory Uop with(nolock) on A.IdAction=Uop.idAction
	inner join Users U with(nolock) on Uop.idUser=U.idUser
	where Uop.idUserModified=@idUser
order by Uop.Date desc, Uop.Change, O.IdOption
