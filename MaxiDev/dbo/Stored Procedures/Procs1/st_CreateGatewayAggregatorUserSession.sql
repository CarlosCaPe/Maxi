CREATE PROCEDURE [dbo].[st_CreateGatewayAggregatorUserSession]
(
	@IdGatewayUser		INT,
	@IPAddress			VARCHAR(40) = null
)
AS
BEGIN
	DELETE FROM GatewayAggregatorUserSession WHERE IdGatewayUser = @IdGatewayUser

	INSERT INTO GatewayAggregatorUserSession(IdGatewayUser, LoginDate, [GUID], LastUpdate)
	VALUES (@IdGatewayUser, GETDATE(), NEWID(), GETDATE())

	SELECT
		CAST(s.GUID AS VARCHAR(200))
	FROM GatewayAggregatorUserSession s 
	WHERE s.IdGatewayAggregatorUserSession = @@identity
END