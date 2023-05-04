CREATE PROCEDURE Corp.st_GetTransferReprintHistory
	@IdTransfer INT
AS
BEGIN

	SELECT *
	FROM TransferDetail D WITH(NOLOCK) INNER JOIN
		TransferNote N WITH(NOLOCK) ON N.IdTransferDetail = D.IdTransferDetail
	WHERE N.Note IN ('Receipt was printed', 'Transfer was viewed')
		AND D.IdTransfer = @IdTransfer
	

END