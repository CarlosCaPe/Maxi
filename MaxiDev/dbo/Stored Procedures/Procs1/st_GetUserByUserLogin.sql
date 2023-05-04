/********************************************************************
<Author>smacias</Author>
<app>??</app>
<Description>??</Description>

<ChangeLog>
<log Date="14/12/2018" Author="smacias"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [dbo].[st_GetUserByUserLogin]
@UserLogin nvarchar(max)
AS  

Set nocount on;
Begin try
	SELECT IdUser, UserName, UserLogin, UserPassword, u.IdUserType, [Name], IdGenericStatus, salt, DateOfCreation, ChangePasswordAtNextLogin
  FROM [dbo].[Users] u WITH(nolock) join UsersType ut WITH(nolock) on u.IdUserType = ut.IdUserType

  WHERE UPPER(UserLogin)= UPPER(@UserLogin)
End try
Begin Catch
	DECLARE @ErrorMessage varchar(max);
    Select @ErrorMessage=ERROR_MESSAGE();
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetUserByUserLogin',Getdate(),@ErrorMessage);
End catch
