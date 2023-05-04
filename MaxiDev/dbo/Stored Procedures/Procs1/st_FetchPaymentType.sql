CREATE PROCEDURE [dbo].[st_FetchPaymentType]
(
	@Name			VARCHAR(200),
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

  SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.IdPaymentType as Id, c.PaymentName as Name
	FROM PaymentType c WITH(NOLOCK)
	WHERE 		
		(@Name IS NULL OR (c.PaymentName LIKE CONCAT('%', @Name, '%')))
	ORDER BY c.IdPaymentType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY
	
END
