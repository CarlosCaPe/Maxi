CREATE PROCEDURE [dbo].[st_GetPosTerminal]
(
	@IdAgent			INT,
	@PcIdentifier		VARCHAR(200)
)
AS
 /********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
	<log Date="01/04/2023" Author="raarce"> BM-567 : Se cambio LEFT JOIN por INNER JOIN para que solo traiga la terminal asignada al PcIdentifier</log>
</ChangeLog>
********************************************************************/
BEGIN
	SELECT
		CASE	
			WHEN apcc.IdGenericStatus = 1 AND apm.IdGenericStatus = 1 AND apt.IdGenericStatus = 1 THEN 1
			ELSE 0
		END UseOperationFee,
		CASE 
			WHEN apcc.IdAgentPosAccount IS NULL OR pt.IdPosTerminal IS NULL THEN 0
			ELSE 1
		END PosEnabled,
		apt.IdAgentPosTerminal,
		pt.IdPosTerminal,
		apm.MerchantId,
		pt.TerminalId,
		pt.SerialNumber,
		pt.MAC,
		apt.IP,
		apt.Port,
		pt.DeviceType,
		pt.OSVersion,
		pt.IdAsset
	FROM Agent a WITH(NOLOCK)
		JOIN AgentPc apc WITH(NOLOCK) ON apc.IdAgent = a.IdAgent
		JOIN PcIdentifier pci WITH(NOLOCK) ON pci.IdPcIdentifier = apc.IdPcIdentifier
		
		LEFT JOIN AgentPosAccount apcc ON apcc.IdAgent = a.IdAgent AND apcc.IdGenericStatus = 1
		LEFT JOIN AgentPosMerchant apm ON apm.IdAgentPosAccount = apcc.IdAgentPosAccount AND apm.IdGenericStatus = 1
		LEFT JOIN AgentPosTerminal apt ON apt.IdAgentPosMerchant = apm.IdAgentPosMerchant AND apt.IdGenericStatus = 1
		INNER JOIN PCAgentPosTerminal ppt ON ppt.IdPcIdentifier = pci.IdPcIdentifier AND ppt.IdAgentPosTerminal = apt.IdAgentPosTerminal AND ppt.IdGenericStatus = 1
		LEFT JOIN PosTerminal pt WITH(NOLOCK) ON pt.IdPosTerminal = apt.IdPosTerminal AND pt.IdGenericStatus = 1 AND ppt.IdGenericStatus = 1
	WHERE a.IdAgent = @IdAgent
		AND pci.Identifier = @PcIdentifier
END
