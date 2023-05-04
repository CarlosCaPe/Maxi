CREATE PROCEDURE [Corp].[st_GetChecks_PendingGatewayResponse]
	@IdBank	INT
AS
BEGIN

	SELECT C.IdCheck, C.DateOfMovement, A.AgentCode, A.AgentName, C.CheckNumber, C.Account, C.RoutingNumber, C.Amount, B.Name AS BankName, S.StatusName
	FROM Checks C WITH(NOLOCK)
	INNER JOIN Agent A WITH(NOLOCK) ON A.IdAgent = C.IdAgent
	INNER JOIN CheckProcessorBank B WITH(NOLOCK) ON B.IdCheckProcessorBank = C.IdCheckProcessorBank
	INNER JOIN Status S WITH(NOLOCK) ON S.IdStatus = C.IdStatus
	WHERE C.IdStatus = 21
		AND C.IdCheckProcessorBank = @IdBank
		
END 