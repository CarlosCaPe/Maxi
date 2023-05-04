CREATE PROCEDURE [dbo].[st_CreateGatewayUser]
(
	@IdGatewayUser	INT,
	@IdGateway		INT,
	@UserName		VARCHAR(200),
	@Password		VARCHAR(200),
	@Salt			VARCHAR(200),
	@EnterByIdUser	INT,
	@IdStatus		INT,
	@ChangePassword	BIT,

	@Success		BIT OUT,
	@Message		VARCHAR(200) OUT
)
AS
BEGIN
	DECLARE @MSG_ERROR NVARCHAR(500)

	IF ISNULL(@IdGatewayUser, 0) = 0 AND EXISTS (SELECT 1 FROM GatewayUser gu WHERE gu.UserName = @UserName)
		SET @Message = CONCAT('The username (', @UserName ,') is already in use')

	IF ISNULL(@Message, '') <> ''
	BEGIN
		SET @Success = 0
		RETURN
	END

	DECLARE @OutputTable TABLE (IdGateway INT, UserName VARCHAR(50), Password VARCHAR(50), Salt VARCHAR(50), CreatedDate DATETIME, EnterByIdUser INT, IdStatus INT)

	BEGIN TRANSACTION
	BEGIN TRY
		DECLARE @UserExists BIT = 0
	
		IF EXISTS(SELECT 1 FROM GatewayUser gu WHERE gu.IdGatewayUser = @IdGatewayUser)
		BEGIN
			SET @UserExists = 1
			IF @ChangePassword = 0
				SELECT 
					@Password = gu.Password,
					@Salt = gu.Salt
				FROM GatewayUser gu 
				WHERE gu.IdGatewayUser = @IdGatewayUser

			UPDATE GatewayUser SET
				Password = @Password,
				Salt = @Salt,
				IdStatus = @IdStatus
			OUTPUT DELETED.IdGateway, DELETED.UserName, DELETED.Password, DELETED.Salt, DELETED.CreatedDate, DELETED.EnterByIdUser, DELETED.IdStatus 
			INTO @OutputTable(IdGateway, UserName, Password, Salt, CreatedDate, EnterByIdUser, IdStatus)
			WHERE IdGatewayUser = @IdGatewayUser
		END
		ELSE
		BEGIN
			INSERT INTO GatewayUser(IdGateway, UserName, Password, Salt, CreatedDate, EnterByIdUser, IdStatus)
			VALUES (@IdGateway, @UserName, @Password, @Salt, GETDATE(), @EnterByIdUser, @IdStatus)

			SET @IdGatewayUser = @@identity
		END

		DECLARE @LogMessage VARCHAR(MAX)
		SET @LogMessage = CONCAT(
			CASE WHEN @UserExists = 1 THEN 'UPDATE' ELSE 'CREATE' END, 
			' User (', @UserName, ')', 
			' by (', @EnterByIdUser, ')',
			' CurrentValues: (',
			(SELECT ga.* FROM GatewayUser ga WHERE ga.IdGatewayUser = @IdGatewayUser FOR XML PATH(''))
			,') OldValues: (', 
			(SELECT * FROM @OutputTable FOR XML PATH(''))
			,')'
		)

		DELETE FROM GatewayUserSession WHERE IdGatewayUser = @IdGatewayUser

		EXEC MAXILOG.dbo.st_CreateOperationBrokerLog 'Users', @LogMessage, NULL, NULL, @EnterByIdUser 
		SET @Success = 1
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		ROLLBACK TRANSACTION

		SET @Success = 0
		SET @Message = 'Internal server error'
		IF(ISNULL(@MSG_ERROR, '') = '')
			SET @MSG_ERROR = ERROR_MESSAGE();

		EXEC MAXILOG.dbo.st_CreateOperationBrokerLog 'Users', 'Internal SP Error', @MSG_ERROR, NULL, @EnterByIdUser 

		RAISERROR(@MSG_ERROR, 16, 1);
	END CATCH
END
