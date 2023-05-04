CREATE PROCEDURE [Corp].[st_GetBranchGatewayCode]
	@IdBranch INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT [IdGateway], [IdBranch], [GatewayBranchCode], [DateOfLastChange], [EnterByIdUser]
	FROM [dbo].[GatewayBranch] WITH(NOLOCK)
	WHERE IdBranch = @IdBranch
END


