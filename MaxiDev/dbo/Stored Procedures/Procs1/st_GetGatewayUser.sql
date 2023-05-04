CREATE PROCEDURE st_GetGatewayUser
(
	@UserName			NVARCHAR(50)
)
AS
BEGIN
	SELECT
		gu.*
	FROM GatewayUser gu WITH(NOLOCK)
	WHERE gu.UserName = @UserName
END


