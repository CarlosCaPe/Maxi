CREATE PROCEDURE st_GatewayIPAllowed
(
	@IdGateway			INT,
	@IPAddress			VARCHAR(40)
)
AS
BEGIN
	DECLARE @IsValid BIT


	IF EXISTS(SELECT 1 FROM GatewayWhiteList wl WHERE wl.IdGateway = @IdGateway AND (wl.IPAddress = @IPAddress OR wl.IPAddress = '*') AND wl.IdStatus = 1)
		SET @IsValid = 1

	SELECT ISNULL(@IsValid, 0)
END
