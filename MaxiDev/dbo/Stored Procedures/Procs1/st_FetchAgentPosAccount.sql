CREATE PROCEDURE st_FetchAgentPosAccount
(
	@IdAgent						INT
)
AS
BEGIN 
	DECLARE @Accounts TABLE(Id INT)

	INSERT INTO @Accounts (Id)
	SELECT a.IdAgentPosAccount
	FROM AgentPosAccount a WITH(NOLOCK)
	WHERE a.IdAgent = @IdAgent

	-- Account
	SELECT
		ac.*
	FROM AgentPosAccount ac WITH(NOLOCK)
		JOIN @Accounts a ON a.Id = ac.IdAgentPosAccount

	-- Merchant
	SELECT
		am.*
	FROM AgentPosMerchant am WITH(NOLOCK)
		JOIN @Accounts a ON a.Id = am.IdAgentPosAccount

	-- Agent PosTerminal
	SELECT 
		apt.*
	FROM AgentPosTerminal apt WITH(NOLOCK)
		JOIN AgentPosMerchant am WITH(NOLOCK) ON am.IdAgentPosMerchant = apt.IdAgentPosMerchant
		JOIN @Accounts a ON a.Id = am.IdAgentPosAccount
	WHERE apt.IdGenericStatus = 1

	-- PosTerminal
	SELECT 
		pt.*
	FROM PosTerminal pt WITH(NOLOCK)
		JOIN AgentPosTerminal apt WITH(NOLOCK) ON apt.IdPosTerminal = pt.IdPosTerminal
		JOIN AgentPosMerchant am WITH(NOLOCK) ON am.IdAgentPosMerchant = apt.IdAgentPosMerchant
		JOIN @Accounts a ON a.Id = am.IdAgentPosAccount
	WHERE apt.IdGenericStatus = 1
	
	-- PC Agent PosTerminal
	SELECT 
		pap.*
	FROM PCAgentPosTerminal pap WITH(NOLOCK) 
		JOIN AgentPosTerminal apt WITH(NOLOCK) ON apt.IdAgentPosTerminal = pap.IdAgentPosTerminal
		JOIN AgentPosMerchant am WITH(NOLOCK) ON am.IdAgentPosMerchant = apt.IdAgentPosMerchant
		JOIN @Accounts a ON a.Id = am.IdAgentPosAccount	
	WHERE apt.IdGenericStatus = 1
	
	SELECT 
		pci.*
	FROM PcIdentifier pci WITH(NOLOCK)
		JOIN PCAgentPosTerminal pap WITH(NOLOCK) ON pap.IdPcIdentifier = pci.IdPcIdentifier
		JOIN AgentPosTerminal apt WITH(NOLOCK) ON apt.IdAgentPosTerminal = pap.IdAgentPosTerminal
		JOIN AgentPosMerchant am WITH(NOLOCK) ON am.IdAgentPosMerchant = apt.IdAgentPosMerchant
		JOIN @Accounts a ON a.Id = am.IdAgentPosAccount
	WHERE apt.IdGenericStatus = 1
END
