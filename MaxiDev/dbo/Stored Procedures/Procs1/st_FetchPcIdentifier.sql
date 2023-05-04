CREATE PROCEDURE [dbo].[st_FetchPcIdentifier]
(
	@IdAgent				INT,

	@SerialNumber			VARCHAR(MAX),
	@MachineName			VARCHAR(MAX)
)
AS
BEGIN 
	SELECT
		pi.*,
		CASE WHEN pc.IdPCAgentPosTerminal IS NOT NULL THEN 1 ELSE 0 END HasAssignedTerminal,
		pc.IdPCAgentPosTerminal
	FROM PcIdentifier pi WITH(NOLOCK)
		JOIN AgentPc ap WITH(NOLOCK) ON ap.IdPcIdentifier = pi.IdPcIdentifier

		LEFT JOIN PCAgentPosTerminal pc WITH(NOLOCK) ON pc.IdPcIdentifier = pi.IdPcIdentifier AND pc.IdGenericStatus = 1
		LEFT JOIN AgentPosTerminal apt WITH(NOLOCK) ON apt.IdAgentPosTerminal = pc.IdAgentPosTerminal AND apt.IdGenericStatus = 1
		LEFT JOIN AgentPosMerchant apm WITH(NOLOCK) ON apm.IdAgentPosMerchant = apt.IdAgentPosMerchant AND apm.IdGenericStatus = 1
		LEFT JOIN AgentPosAccount apa WITH(NOLOCK) ON apa.IdAgentPosAccount = apm.IdAgentPosAccount AND apa.IdAgent = @IdAgent
	WHERE ap.IdAgent = @IdAgent
		AND (ISNULL(@SerialNumber, '') = '' OR pi.SerialNumber LIKE CONCAT('%', @SerialNumber, '%'))
		AND (ISNULL(@MachineName, '') = '' OR pi.MachineName LIKE CONCAT('%', @MachineName, '%'))
END
