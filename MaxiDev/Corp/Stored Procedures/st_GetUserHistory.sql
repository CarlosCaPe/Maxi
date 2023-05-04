CREATE procedure [Corp].[st_GetUserHistory]
    @idUser int
as

Select UC.idUser, U.FirstName + ' ' + U.LastName + ' ' + U.SecondLastName as Name, idUserModified, Field, Change, Date from UserChangeHistory UC with(nolock) join Users U with(nolock) on U.IdUser = UC.idUser
where idUserModified = @idUser
order by Date desc
