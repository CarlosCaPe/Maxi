CREATE PROCEDURE [dbo].[st_GetGatewayUsers]
(
	@IdGateway		INT
)
AS
BEGIN
	SELECT
		gu.IdGatewayUser,
		gu.IdGateway,
		gu.UserName,
		gu.CreatedDate,
		gu.EnterByIdUser,
		gu.IdStatus,
		gs.GenericStatus	StatusName,
		u.UserName			EnterByUser
	FROM GatewayUser gu WITH(NOLOCK)
		JOIN GenericStatus gs WITH(NOLOCK) ON gs.IdGenericStatus = gu.IdStatus
		JOIN Users u WITH(NOLOCK) ON gu.EnterByIdUser = u.IdUser
	WHERE gu.IdGateway = @IdGateway
END
