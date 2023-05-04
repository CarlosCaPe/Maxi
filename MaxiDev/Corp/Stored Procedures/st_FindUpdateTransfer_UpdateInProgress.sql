CREATE PROCEDURE Corp.st_FindUpdateTransfer_UpdateInProgress
	@ClaimCode	NVARCHAR(50),
	@IdStatus	INT
AS
BEGIN

	SELECT idtransfer,idagent,folio,claimcode,DateofTransfer,idstatus,datestatuschange 
	FROM dbo.[Transfer] WITH(nolock) 
	WHERE IdStatus IN (70,71)
		AND ClaimCode = @ClaimCode
		AND (IdStatus = @IdStatus OR isnull(@IdStatus, 0) = 0)

END