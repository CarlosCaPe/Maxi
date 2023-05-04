CREATE PROCEDURE st_CreateGatewayUserSession
(
	@IdGatewayUser		INT,
	@IPAddress			VARCHAR(40)
)
AS
BEGIN
	DELETE FROM GatewayUserSession WHERE IdGatewayUser = @IdGatewayUser

	INSERT INTO GatewayUserSession(IdGatewayUser, LoginDate, IPAddress, [GUID], LastUpdate)
	VALUES (@IdGatewayUser, GETDATE(), @IPAddress, NEWID(), GETDATE())

	SELECT
		CAST(s.GUID AS VARCHAR(200))
	FROM GatewayUserSession s 
	WHERE s.IdGatewayUserSession = @@identity
END