CREATE PROCEDURE [Corp].[st_GetGateways] 
	@IdGateway INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@IdGateway = 0)
		BEGIN 
			SELECT [IdGateway], [GatewayName], [DateOfLastChange], [EnterByIdUser], [Code]
			FROM [dbo].[Gateway] WITH(NOLOCK)
		END
	ELSE
		BEGIN
			SELECT [IdGateway], [GatewayName], [DateOfLastChange], [EnterByIdUser], [Code]
			FROM [dbo].[Gateway] WITH(NOLOCK)
			WHERE IdGateway = @IdGateway
		END 

END 
