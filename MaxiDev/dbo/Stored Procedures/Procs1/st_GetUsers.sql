/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="14/12/2018" Author="smacias"> Creado </log>
<log Date="11/09/2019" Author="jzuniga"> Se añade Filtro de GenericStatus = 3 </log>
<log Date="04/10/2019" Author="jzuniga"> Remplazo de order by "2" por "u.UserName" </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetUsers]
AS  
Set nocount on;
Begin try
	SELECT IdUser, UserName
	FROM [dbo].[Users] u WITH(nolock)
	where (IdGenericStatus = 1 or u.IdGenericStatus = 3) and
		  IdUserType = 3 order by u.UserName
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetUsers',Getdate(),@ErrorMessage);
End catch
