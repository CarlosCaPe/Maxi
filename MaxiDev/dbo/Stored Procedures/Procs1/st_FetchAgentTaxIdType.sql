CREATE PROCEDURE [dbo].[st_FetchAgentTaxIdType]
(
	@Offset			BIGINT,
	@Limit			BIGINT
)
AS
BEGIN

  SELECT 
		COUNT(*) OVER() _PagedResult_Total,
		c.IdAgentTaxIdType as Id, c.Name
	FROM AgentTaxIdType c 

	ORDER BY c.IdAgentTaxIdType
	OFFSET (@Offset) ROWS
	FETCH NEXT @Limit ROWS ONLY

END