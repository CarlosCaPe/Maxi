CREATE PROCEDURE [Corp].[st_GetAgentDepositByCollectType]
	@dateFrom		DATETIME,
	@dateTo			DATETIME,
	@stateCode		VARCHAR(10),
	@bankAccount	VARCHAR(50)
AS
BEGIN

	DECLARE @totalAmount DECIMAL(19,4)

	SELECT @totalAmount = sum(D.Amount)
	FROM AgentDeposit D WITH(NOLOCK) INNER JOIN
		Agent A WITH(NOLOCK) ON A.IdAgent = D.IdAgent
	WHERE D.DepositDate >= @dateFrom AND  D.DepositDate < @dateTo
		AND (A.AgentState = @stateCode OR isnull(@stateCode, '') = '')
		AND (D.BankName LIKE '%' + @bankAccount +  '%' OR isnull(@bankAccount, '') = '')

	SELECT C.Name AS 'CollectType', 
		sum(D.Amount) AS 'Amount', 
		convert(DECIMAL(19,5), (sum(D.Amount) * 100) / @totalAmount) AS 'Percentage'--, convert(DECIMAL(19,4), (sum(D.Amount) / @totalAmount)) * 100
	FROM AgentDeposit D WITH(NOLOCK) INNER JOIN
		AgentCollectType C WITH(NOLOCK) ON C.IdAgentCollectType = D.IdAgentCollectType INNER JOIN
		Agent A WITH(NOLOCK) ON A.IdAgent = D.IdAgent
	WHERE D.DepositDate >= @dateFrom AND  D.DepositDate < @dateTo
		AND (A.AgentState = @stateCode OR isnull(@stateCode, '') = '')
		AND (ltrim(rtrim(D.BankName)) LIKE '%' + ltrim(rtrim(@bankAccount)) +  '%' OR isnull(@bankAccount, '') = '')
	GROUP BY C.Name

END