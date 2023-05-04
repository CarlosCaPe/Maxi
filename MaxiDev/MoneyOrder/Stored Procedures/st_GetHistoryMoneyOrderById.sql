CREATE   PROCEDURE MoneyOrder.st_GetHistoryMoneyOrderById
(
	
	@IdSaleRecord		INT
)
AS
BEGIN
	SELECT 
		ms.IdSaleRecordDetails,
		ms.IdSaleRecord,
		s.IdStatus,
		s.StatusName,
		ms.DateOfMovement,
		ms.Note,
		CONCAT(u.FirstName, ' ', u.LastName, ' ', u.SecondLastName) UserName,
		u.IdUser
	FROM 
		MoneyOrder.SaleRecordDetails ms WITH(NOLOCK)
		INNER JOIN Status s WITH(NOLOCK) ON ms.IdStatus = s.IdStatus
		INNER JOIN Users u WITH(NOLOCK) ON u.IdUser = ms.EnterByIdUser
	WHERE
		ms.IdSaleRecord = @IdSaleRecord
	ORDER BY ms.DateOfMovement DESC
END
