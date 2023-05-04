/********************************************************************
<Author> smacias </Author>
<app>Agente y Corporativo</app>
<Description> Obtiene los cambios realizados a la tabla de usuarios </Description>

<ChangeLog>
<log Date="29/08/2018" Author="smacias">Creacion</log>
<log Date="05/10/2018" Author="azavala"> Agregar logica de borrado de store si existe</log>
</ChangeLog>
*********************************************************************/
CREATE procedure [dbo].[st_GetUserHistory]
    @idUser int
as

Select UC.idUser, U.FirstName + ' ' + U.LastName + ' ' + U.SecondLastName as Name, idUserModified, Field, Change, Date 
from UserChangeHistory UC with(nolock) join Users U with(nolock) on U.IdUser = UC.idUser
where idUserModified = @idUser
order by Date desc
