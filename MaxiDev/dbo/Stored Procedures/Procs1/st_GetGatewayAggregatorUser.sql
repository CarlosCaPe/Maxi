
CREATE PROCEDURE [dbo].[st_GetGatewayAggregatorUser]
(
	@UserName			NVARCHAR(50)
)
AS
BEGIN
	SELECT
		gu.*, g.Code
	FROM GatewayUser gu WITH(NOLOCK)
	inner join Gateway g WITH (NOLOCK) on g.IdGateway = gu.IdGateway
	WHERE gu.UserName = @UserName
END


