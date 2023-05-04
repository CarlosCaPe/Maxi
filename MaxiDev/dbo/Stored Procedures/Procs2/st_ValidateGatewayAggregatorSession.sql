
CREATE PROCEDURE [dbo].[st_ValidateGatewayAggregatorSession]
(
	@GUID			uniqueidentifier,
	@IdGateway		INT,
	@IdGatewayUser	INT
)
AS
BEGIN
	DECLARE @Success	BIT,
			@Message	VARCHAR(200)

	SELECT
		ga.*
	INTO #CurrentSession
	FROM GatewayAggregatorUserSession ga WITH (NOLOCK)
	WHERE ga.IdGatewayUser = @IdGatewayUser

	IF NOT EXISTS(SELECT 1 FROM #CurrentSession WITH (NOLOCK))
		SET @Message = 'The user is not logged in'
	ELSE IF EXISTS
	(
		SELECT 1 FROM #CurrentSession cs 
		JOIN GatewayUser gu ON gu.IdGatewayUser = cs.IdGatewayUser
		WHERE gu.IdStatus <> 1
	)
		SELECT
			@Message = CONCAT('The username is ', gs.GenericStatus)
		FROM #CurrentSession cs WITH (NOLOCK)
			JOIN GatewayUser gu WITH (NOLOCK)ON gu.IdGatewayUser = cs.IdGatewayUser
			JOIN GenericStatus gs WITH (NOLOCK)ON gs.IdGenericStatus = gu.IdStatus
	ELSE IF NOT EXISTS(SELECT 1 FROM #CurrentSession cs WITH (NOLOCK) WHERE cs.GUID = @GUID)
		SET @Message = 'This user has started another session, this token / session is not valid'
	--ELSE IF NOT EXISTS(SELECT 1 FROM #CurrentSession cs WHERE cs.IPAddress = @IPAddress)
	--	SET @Message = 'This user has started another session from another IP, this token / session is not valid'
	--ELSE IF NOT EXISTS(SELECT * FROM GatewayWhiteList w WHERE w.IdGateway = @IdGateway AND (w.IPAddress = @IPAddress OR w.IPAddress = '*') AND w.IdStatus = 1)
	--	SET @Message = 'The IP address is no longer valid'

	IF ISNULL(@Message, '') <> ''
		SET @Success = 0
	ELSE
	BEGIN
		UPDATE GatewayAggregatorUserSession SET 
			LastUpdate = GETDATE()
		WHERE IdGatewayUser = @IdGatewayUser

		SET @Success = 1
	END

	SELECT	@Success Success,
			@Message Message
END