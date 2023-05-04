CREATE PROCEDURE [Corp].[st_UpdateTransferUpdateInProgres_SearchTransfer]
	@IdStatus	INT
AS 
BEGIN
	
	IF (@IdStatus = 72)
	BEGIN
	
		SELECT T.IdTransfer, A.AgentCode,  A.AgentName, T.Folio, T.ClaimCode, T.DateOfTransfer, S.StatusName, T.DateStatusChange
		FROM TransferModify TM INNER JOIN
			Transfer T WITH(NOLOCK) ON t.IdTransfer = TM.OldIdTransfer INNER JOIN
			Transfer T2 WITH(NOLOCK) ON T2.IdTransfer  = TM.NewIdTransfer INNER JOIN
			Agent A WITH(NOLOCK) ON A.IdAgent = T.IdAgent INNER JOIN 
			Status S WITH(NOLOCK) ON S.IdStatus = T.IdStatus
		WHERE T.IdStatus = 22 and T2.IdStatus = 72 AND TM.IsCancel = 0
		UNION
		SELECT T.IdTransferClosed, A.AgentCode,  A.AgentName, T.Folio, T.ClaimCode, T.DateOfTransfer, S.StatusName, T.DateStatusChange
		FROM TransferModify TM INNER JOIN
			TransferClosed T WITH(NOLOCK) ON t.IdTransferClosed = TM.OldIdTransfer INNER JOIN
			TransferClosed T2 WITH(NOLOCK) ON T2.IdTransferClosed  = TM.NewIdTransfer INNER JOIN
			Agent A WITH(NOLOCK) ON A.IdAgent = T.IdAgent INNER JOIN 
			Status S WITH(NOLOCK) ON S.IdStatus = T.IdStatus
		WHERE T.IdStatus = 22 and T2.IdStatus = 72 AND TM.IsCancel = 0
	
	END
	ELSE
	BEGIN
	
		SELECT T.IdTransfer, A.AgentCode, A.AgentName, T.Folio, T.ClaimCode, T.DateOfTransfer, S.StatusName, T.DateStatusChange
		FROM dbo.[Transfer] T WITH (nolock) 
			INNER JOIN Agent A WITH(NOLOCK) ON A.IdAgent = T.IdAgent
			INNER JOIN Status S WITH(NOLOCK) ON S.IdStatus = T.IdStatus 
		WHERE (T.IdStatus = @IdStatus OR (isnull(@IdStatus, 0) = 0 AND T.IdStatus IN (70, 71)))
			--AND DATEDIFF(MINUTE,T.DateStatusChange,GETDATE())>=30
	
	END
	
	

END