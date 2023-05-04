CREATE PROCEDURE Corp.st_GetTransferLogHistory
	@IdTransfer		INT
AS
BEGIN

	DECLARE @SystemUserID INT 

	SELECT @SystemUserID = convert(INT, Value)
	FROM GlobalAttributes WHERE Name = 'SystemUserID'
	
	SELECT U.UserName, N.Note, N.EnterDate
	FROM TransferNote N WITH(NOLOCK) INNER JOIN
		TransferDetail D WITH(NOLOCK) ON D.IdTransferDetail = N.IdTransferDetail INNER JOIN
		Users U ON U.IdUser = N.IdUser
	WHERE D.IdTransfer = @IdTransfer
		AND N.Note IN ('Receipt was printed', 'Transfer was viewed')	
	UNION
	SELECT U.UserName, N.Note, N.EnterDate
	FROM TransferNote N INNER JOIN
		TransferDetail D ON D.IdTransferDetail = N.IdTransferDetail INNER JOIN
		Users U ON U.IdUser = N.IdUser
	WHERE D.IdTransfer = @IdTransfer
		AND N.IdUser != @SystemUserID
	ORDER BY N.EnterDate DESC
	
END
