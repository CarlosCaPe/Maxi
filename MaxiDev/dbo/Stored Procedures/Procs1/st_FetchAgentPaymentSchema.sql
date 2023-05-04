CREATE PROCEDURE [dbo].[st_FetchAgentPaymentSchema]
(
	--@Name			VARCHAR(200)=NULL,
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

  SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.IdAgentPaymentSchema as Id, c.PaymentName as Name
	FROM AgentPaymentSchema c 

	ORDER BY c.IdAgentPaymentSchema
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END
