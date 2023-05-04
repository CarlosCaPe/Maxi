CREATE PROCEDURE Corp.st_SearchTransferToAddBalance
	@IdAgent	INT,
	@Folio		INT,
	@ClaimCode	VARCHAR(max)
AS
BEGIN




	IF EXISTS (SELECT 1 FROM dbo.[Transfer] WITH(nolock) WHERE (IdAgent = @IdAgent AND Folio = @Folio) OR (ClaimCode = @ClaimCode AND ClaimCode <> ''))
	BEGIN
		
		--SELECT 'Es Transfer'
		
		SELECT T.IdTransfer, 
			T.Folio,
			T.ClaimCode,			
			S.StatusName,
			A.AgentCode,
			A.AgentName, 
			T.DateOfTransfer,
			convert(VARCHAR(10), datediff(mi, T.DateOfTransfer, getdate())) + ' minutes' AS TimeFromCreation
		FROM dbo.[Transfer] T WITH(nolock) 
		INNER JOIN dbo.Status S WITH(NOLOCK) ON S.IdStatus = T.IdStatus
		INNER JOIN dbo.Agent A WITH(nolock) ON A.IdAgent = T.IdAgent
		WHERE (T.IdAgent = @IdAgent AND T.Folio = @Folio) 
			OR (T.ClaimCode = @ClaimCode AND T.ClaimCode <> '')
	
		
			
		
	
	END
	ELSE
	BEGIN
		
		--SELECT 'Es TransferClosed'
		
		SELECT T.IdTransferClosed AS IdTransfer, 
			T.Folio,
			T.ClaimCode,			
			S.StatusName,
			A.AgentCode,
			A.AgentName, 
			T.DateOfTransfer,
			convert(VARCHAR(10), datediff(mi, T.DateOfTransfer, getdate())) + ' minutes' AS TimeFromCreation
		FROM dbo.[TransferClosed] T WITH(nolock) 
		INNER JOIN dbo.Status S WITH(NOLOCK) ON S.IdStatus = T.IdStatus
		INNER JOIN dbo.Agent A WITH(nolock) ON A.IdAgent = T.IdAgent
		WHERE (T.IdAgent = @IdAgent AND T.Folio = @Folio) 
			OR (T.ClaimCode = @ClaimCode AND T.ClaimCode <> '')
	
	END
	
END