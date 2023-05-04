CREATE PROCEDURE [dbo].[st_FetchAgentReceiptType]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

  SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.IdAgentReceiptType as Id, c.Name
	FROM AgentReceiptType c 

	ORDER BY c.IdAgentReceiptType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END