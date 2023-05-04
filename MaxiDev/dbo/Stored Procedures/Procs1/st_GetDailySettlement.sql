CREATE PROCEDURE st_GetDailySettlement
(
	@IdAgentPosTerminal		INT
)
AS
BEGIN 
	DECLARE @PosSettlement TABLE (IdPosSettlement INT)

	INSERT INTO @PosSettlement(IdPosSettlement)
	SELECT
		ps.IdPosSettlement
	FROM AgentPosTerminal apt WITH(NOLOCK)
		JOIN AgentPosMerchant apm WITH(NOLOCK) ON apm.IdAgentPosMerchant = apt.IdAgentPosMerchant
		JOIN AgentPosAccount apc WITH(NOLOCK) ON apc.IdAgentPosAccount = apm.IdAgentPosAccount

		JOIN PosSettlement ps WITH(NOLOCK) ON ps.IdPosTerminal = apt.IdPosTerminal AND ps.IdAgent = apc.IdAgent
	WHERE apt.IdAgentPosTerminal = @IdAgentPosTerminal
		AND apt.IdGenericStatus = 1
		AND apm.IdGenericStatus = 1
		AND apc.IdGenericStatus = 1
		AND ps.CreationDate >= CONVERT(DATE, GETDATE())

	SELECT
		ps.*
	FROM PosSettlement ps WITH(NOLOCK)
		JOIN @PosSettlement tps ON tps.IdPosSettlement = ps.IdPosSettlement

	SELECT
		pstt.*
	FROM PosSettlementTerminalTotal pstt WITH(NOLOCK)
		JOIN @PosSettlement tps ON tps.IdPosSettlement = pstt.IdPosSettlement

	SELECT
		psgt.*
	FROM PosSettlementGiftTotal psgt WITH(NOLOCK)
		JOIN @PosSettlement tps ON tps.IdPosSettlement = psgt.IdPosSettlement
END
