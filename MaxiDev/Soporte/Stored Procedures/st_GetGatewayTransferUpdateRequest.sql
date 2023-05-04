﻿CREATE PROCEDURE [Soporte].[st_GetGatewayTransferUpdateRequest]
(
	@IdGateway			INT
)
AS
BEGIN
	SELECT
		tr.IdTransferUpdateRequest,
		T.IdTransfer,
		T.ClaimCode,
		T.IdStatus,
		CASE 
			WHEN t.IdStatus IN (22, 24, 30, 31) THEN 0
			ELSE 1 
		END IsValid
	INTO #RequestTransfers
	FROM Soporte.TransferUpdateRequest tr
		JOIN Transfer t ON t.IdTransfer = tr.IdTransfer
	WHERE ISNULL(tr.RequestSent, 0) = 0
	AND t.IdGateway = @IdGateway

	UPDATE t SET
		RequestSent = 1,
		ReturnCode = 'ERROR',
		XMLResponse = CONCAT('<ErrorMessage>', 'The transfer (', t.IdTransfer ,') cannot be updated because it has status (', s.IdStatus, ') ', s.StatusName,'</ErrorMessage>'),
		DateOfLastChange = GETDATE()
	FROM Soporte.TransferUpdateRequest t WITH(NOLOCK)
		JOIN #RequestTransfers rt ON rt.IdTransferUpdateRequest = t.IdTransferUpdateRequest
		JOIN Status s WITH(NOLOCK) ON s.IdStatus = rt.IdStatus
	WHERE rt.IsValid = 0


	SELECT
		rt.IdTransferUpdateRequest,
		rt.IdTransfer, 
		rt.ClaimCode
	FROM #RequestTransfers rt
	WHERE rt.IsValid = 1
END