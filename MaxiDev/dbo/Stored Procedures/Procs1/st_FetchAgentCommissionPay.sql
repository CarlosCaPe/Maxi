CREATE PROCEDURE [dbo].[st_FetchAgentCommissionPay]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

  SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.IdAgentCommissionPay as Id, c.AgentCommissionPayName as Name
	FROM AgentCommissionPay c 

	ORDER BY c.IdAgentCommissionPay
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END