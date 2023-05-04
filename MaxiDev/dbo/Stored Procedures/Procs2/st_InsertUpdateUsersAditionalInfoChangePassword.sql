CREATE PROCEDURE [dbo].[st_InsertUpdateUsersAditionalInfoChangePassword]
	@IdUser int 
AS
/********************************************************************
<Author>mhinojo</Author>
<app>Corporate and Agent</app>
<Description>Insert or update aditional info </Description>

<ChangeLog>
<log Date="23/07/2018" Author="mhinojo">Create SP</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
	IF EXISTS (SELECT TOP 1 1 FROM UsersAditionalInfo WITH(NOLOCK) WHERE IdUser = @IdUser)
		UPDATE UsersAditionalInfo SET DateOfChangeLastPassword = GETDATE(), AttemptsToLogin = 0 WHERE IdUser = @IdUser
	ELSE
		INSERT INTO UsersAditionalInfo (IdUser, DateOfChangeLastPassword, AttemptsToLogin) VALUES (@IdUser, GETDATE(), 0)	
END TRY
BEGIN CATCH    
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_InsertUpdateUsersAditionalInfoChangePassword', GETDATE(), ERROR_MESSAGE())
END CATCH
