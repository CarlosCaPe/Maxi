CREATE PROCEDURE [dbo].[st_GetUserByIdUser]
@IdUser INT
AS  

SET NOCOUNT ON;
BEGIN TRY
	SELECT IdUser, UserName, UserLogin, UserPassword, u.IdUserType, [Name], IdGenericStatus, salt, DateOfCreation, ChangePasswordAtNextLogin
  	FROM [dbo].[Users] u WITH(nolock) 
  		JOIN UsersType ut WITH(nolock) ON u.IdUserType = ut.IdUserType
  	WHERE u.IdUser = @IdUser
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max);
    SELECT @ErrorMessage=ERROR_MESSAGE();
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)VALUES('st_GetUserByUserLogin',Getdate(),@ErrorMessage);
END CATCH

