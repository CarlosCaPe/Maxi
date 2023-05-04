CREATE PROCEDURE st_GetGatewayWhiteList
(
	@IdGateway		INT
)
AS
BEGIN
	SELECT
		gw.*,
		gs.GenericStatus	StatusName,
		u.UserName			EnterByUser
	FROM GatewayWhiteList gw 
		JOIN GenericStatus gs WITH(NOLOCK) ON gs.IdGenericStatus = gw.IdStatus
		JOIN Users u WITH(NOLOCK) ON gw.EnterByIdUser = u.IdUser
	WHERE gw.IdGateway = @IdGateway
END
