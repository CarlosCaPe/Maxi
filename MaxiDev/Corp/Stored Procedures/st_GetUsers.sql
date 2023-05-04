CREATE PROCEDURE [Corp].[st_GetUsers]
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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_GetUsers',Getdate(),@ErrorMessage);
End catch
