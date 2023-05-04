CREATE PROCEDURE Corp.st_GetSMSMessagesByIdTransfer
	@IdTransfer	INT
AS
BEGIN
	
	SELECT M.IdTextMessageInfinite, 
		M.Message AS 'MessageText', 
		M.InserteredDate AS 'MessageDate', 
		isnull(MS.StatusName, '') AS 'MessageStatus', 
		isnull(S.StatusName, '') AS 'ProviderStatus'
	FROM Infinite.TextMessageInfinite M WITH(NOLOCK) LEFT JOIN
		Infinite.Status S ON S.StatusId = M.ProviderStatus LEFT JOIN
		Infinite.TextMessageStatus MS ON MS.IdTextMessageStatus = M.IdTextMessageStatus
	WHERE IdTransfer = @IdTransfer
	
END