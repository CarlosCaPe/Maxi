CREATE PROCEDURE [dbo].[st_ValidateAttemptsAndUpdateUserToSuspended]
	@IdUser int 
AS
/********************************************************************
<Author>mhinojo</Author>
<app>Corporate and Agent</app>
<Description>Validate attempts for user</Description>
<ChangeLog>
<log Date="23/07/2018" Author="mhinojo">Create SP</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
	DECLARE @AttemptsToLogin INT    
	SET @AttemptsToLogin  = (SELECT TOP 1 AttemptsToLogin FROM UsersAditionalInfo WITH(NOLOCK) WHERE IdUser = @IdUser)
	DECLARE @AttemptsToLoginAllowed INT    
	SET @AttemptsToLoginAllowed = dbo.GetGlobalAttributeByName('AttemptsToLoginAllowed');    
	IF (@AttemptsToLogin < @AttemptsToLoginAllowed)
	BEGIN
		SET @AttemptsToLogin = @AttemptsToLogin + 1
		UPDATE UsersAditionalInfo SET AttemptsToLogin = @AttemptsToLogin WHERE IdUser = @IdUser
		IF (@AttemptsToLogin = @AttemptsToLoginAllowed)
			UPDATE Users SET IdGenericStatus = 3 WHERE IdUser = @IdUser
		SELECT @AttemptsToLoginAllowed - @AttemptsToLogin
	END
	ELSE
	BEGIN
		UPDATE Users SET IdGenericStatus = 3 WHERE IdUser = @IdUser
		SELECT 0
	END
END TRY
BEGIN CATCH    
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_ValidateAttemptsAndUpdateUserToSuspended', GETDATE(), ERROR_MESSAGE())
END CATCH
