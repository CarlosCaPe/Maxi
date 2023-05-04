CREATE PROCEDURE st_FetchPosTerminal
(
	@TerminalId				VARCHAR(100),
	@SerialNumber			VARCHAR(100),
	@DeviceType				VARCHAR(100),

	@ShowDisabled			BIT = 0,
	@ShowAssigned			BIT = 0
)
AS
BEGIN 
	SELECT
		p.*,
		a.AgentCode
	FROM PosTerminal p WITH(NOLOCK)
		LEFT JOIN AgentPosTerminal apt WITH(NOLOCK) ON apt.IdPosTerminal = p.IdPosTerminal AND apt.IdGenericStatus = 1
		LEFT JOIN AgentPosMerchant apm WITH(NOLOCK) ON apm.IdAgentPosMerchant = apt.IdAgentPosMerchant  AND apt.IdGenericStatus = 1
		LEFT JOIN AgentPosAccount apa WITH(NOLOCK) ON apa.IdAgentPosAccount = apm.IdAgentPosAccount
		LEFT JOIN Agent a WITH(NOLOCK) ON a.IdAgent = apa.IdAgent
	WHERE
		(ISNULL(@TerminalId, '') = '' OR p.TerminalId LIKE CONCAT('%', @TerminalId ,'%'))
		AND (ISNULL(@SerialNumber, '') = '' OR p.SerialNumber LIKE CONCAT('%', @SerialNumber ,'%'))
		AND (ISNULL(@DeviceType, '') = '' OR p.DeviceType LIKE CONCAT('%', @DeviceType ,'%'))
		AND (ISNULL(@ShowDisabled, 0) = 1 OR p.IdGenericStatus = 1)
		AND (ISNULL(@ShowAssigned, 0) = 1 OR (a.IdAgent IS NULL))
END
