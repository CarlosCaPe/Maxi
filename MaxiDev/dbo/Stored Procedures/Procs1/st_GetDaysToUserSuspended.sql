CREATE PROCEDURE [dbo].[st_GetDaysToUserSuspended]
@IdUser int 
AS
/********************************************************************
<Author>mhinojo</Author>
<app>Corporate and Agent</app>
<Description>Get Day left to user is suspended</Description>

<ChangeLog>
<log Date="23/07/2018" Author="mhinojo">Create SP</log>
</ChangeLog>
*********************************************************************/
BEGIN TRY
	DECLARE @RemainingDaysToChangePwd INT    
	SET @RemainingDaysToChangePwd = dbo.GetGlobalAttributeByName('RemainingDaysToChangePwd');    
	DECLARE @RemainingDaysToSendMsgChangePwd  INT      
	SET @RemainingDaysToSendMsgChangePwd = dbo.GetGlobalAttributeByName('RemainingDaysToSendMsgChangePwd');    
	DECLARE @dateOfChangeLastPassword AS DATETIME
	SET @dateOfChangeLastPassword = (SELECT TOP 1 DateOfChangeLastPassword FROM UsersAditionalInfo WITH(NOLOCK) WHERE IdUser = @IdUser)
	DECLARE @expirationDate AS DATETIME
	SET @expirationDate = DATEADD(DAY, @RemainingDaysToChangePwd, @dateOfChangeLastPassword)
	DECLARE @NumberDays AS INT
	SET @NumberDays = DATEDIFF(DAY, GETDATE(), @expirationDate)
	DECLARE @IdStatus INT 
	SET @IdStatus = (SELECT TOP 1 IdGenericStatus FROM Users WITH(NOLOCK) WHERE IdUser = @IdUser)
	IF (@IdStatus = 3)
		SELECT 0
	ELSE
	BEGIN
		IF (@NumberDays <= 0)
		BEGIN
			UPDATE Users SET IdGenericStatus = 3 WHERE IdUser = @IdUser
			SELECT 0
		END
		ELSE
		BEGIN
			IF (@NumberDays <= @RemainingDaysToSendMsgChangePwd)
				SELECT @NumberDays
			ELSE
				SELECT NULL
		END
	END
END TRY
BEGIN CATCH    
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) VALUES ('st_GetDaysToUserSuspended', GETDATE(), ERROR_MESSAGE())
END CATCH
