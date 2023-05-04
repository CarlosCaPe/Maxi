/********************************************************************
<Author> ???</Author>
<app>Corporate </app>
<Description> Inserta o actualiza los usuarios </Description>

<ChangeLog>
<log Date="29/08/2018" Author="smacias"> Creacion del sp</log>
<log Date="10/09/2018" Author="smacias"> Se cambio la consulta basada en actionid</log>
<log Date="05/10/2018" Author="azavala"> Agregar logica de borrado de store si existe</log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetPermissionHistory]
    @idUser int
as

select 
	Uop.[Date],
	O.IdOption,
	Uop.Change,
	U.FirstName + ' ' + U.LastName + ' ' + U.SecondLastName as Name,
	M.Name ModuleName,
	M.[Description] as 'Module Description',
	O.Name OptionName,
	O.[Description] as 'Option Description',
	A.Code ActionCode,
	A.[Description] as 'Action Description'
from Modulo M WITH(NOLOCK)
	inner join [Option] O WITH(NOLOCK) on M.IdModule=O.IdModule
	inner join ActionAllowed A WITH(NOLOCK) on O.IdOption = A.IdOption
	inner join UserOptionChangeHistory Uop WITH(NOLOCK) on A.IdAction=Uop.idAction
	inner join Users U WITH(NOLOCK) on Uop.idUser=U.idUser
	where Uop.idUserModified=@idUser
order by Uop.[Date] desc, Uop.Change, O.IdOption
