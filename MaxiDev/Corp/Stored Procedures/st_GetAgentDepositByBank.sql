CREATE PROCEDURE [Corp].[st_GetAgentDepositByBank]
	@dateFrom	DATETIME,
	@dateTo		DATETIME,
	@stateCode	VARCHAR(10)
AS
BEGIN

/********************************************************************
<Author> Unknown </Author>
<app> Corporativo </app>
<Description> Obtiene Reporte AgentDepositsByBank </Description>

<ChangeLog>

</ChangeLog>

*********************************************************************/

	DECLARE @totalAmount DECIMAL(19,4)

	SELECT @totalAmount = sum(D.Amount)
	FROM AgentDeposit D WITH(NOLOCK) INNER JOIN
		Agent A WITH(NOLOCK) ON A.IdAgent = D.IdAgent
	WHERE D.DepositDate >= @dateFrom AND  D.DepositDate < @dateTo
		AND (A.AgentState = @stateCode OR isnull(@stateCode, '') = '')

	SELECT D.BankName, 
		sum(D.Amount) AS 'Amount', 
		convert(DECIMAL(19,4), (sum(D.Amount) * 100) / @totalAmount) AS 'Percentage'
	FROM AgentDeposit D INNER JOIN
		Agent A WITH(NOLOCK) ON A.IdAgent = D.IdAgent
	WHERE D.DepositDate >= @dateFrom AND  D.DepositDate < @dateTo
		AND (A.AgentState = @stateCode OR isnull(@stateCode, '') = '')
	GROUP BY D.BankName 

END