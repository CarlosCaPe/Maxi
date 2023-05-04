CREATE PROCEDURE [dbo].[st_ValidateGatewaySession]
(
	@GUID			uniqueidentifier,
	@IdGateway		INT,
	@IdGatewayUser	INT,
	@IPAddress		VARCHAR(40)
)
AS
BEGIN
	DECLARE @Success	BIT,
			@Message	VARCHAR(200)

	SELECT
		ga.*
	INTO #CurrentSession
	FROM GatewayUserSession ga
	WHERE ga.IdGatewayUser = @IdGatewayUser

	IF NOT EXISTS(SELECT 1 FROM #CurrentSession)
		SET @Message = 'The user is not logged in'
	ELSE IF EXISTS
	(
		SELECT 1 FROM #CurrentSession cs 
		JOIN GatewayUser gu ON gu.IdGatewayUser = cs.IdGatewayUser
		WHERE gu.IdStatus <> 1
	)
		SELECT
			@Message = CONCAT('The username is ', gs.GenericStatus)
		FROM #CurrentSession cs 
			JOIN GatewayUser gu ON gu.IdGatewayUser = cs.IdGatewayUser
			JOIN GenericStatus gs ON gs.IdGenericStatus = gu.IdStatus
	ELSE IF NOT EXISTS(SELECT 1 FROM #CurrentSession cs WHERE cs.GUID = @GUID)
		SET @Message = 'This user has started another session, this token / session is not valid'
	ELSE IF NOT EXISTS(SELECT 1 FROM #CurrentSession cs WHERE cs.IPAddress = @IPAddress)
		SET @Message = 'This user has started another session from another IP, this token / session is not valid'
	ELSE IF NOT EXISTS(SELECT * FROM GatewayWhiteList w WHERE w.IdGateway = @IdGateway AND (w.IPAddress = @IPAddress OR w.IPAddress = '*') AND w.IdStatus = 1)
		SET @Message = 'The IP address is no longer valid'

	IF ISNULL(@Message, '') <> ''
		SET @Success = 0
	ELSE
	BEGIN
		UPDATE GatewayUserSession SET 
			LastUpdate = GETDATE()
		WHERE IdGatewayUser = @IdGatewayUser

		SET @Success = 1
	END

	SELECT	@Success Success,
			@Message Message
END