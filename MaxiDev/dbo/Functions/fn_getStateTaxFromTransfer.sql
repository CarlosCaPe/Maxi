CREATE FUNCTION [dbo].[fn_getStateTaxFromTransfer] (@idTransfer INT)
RETURNS MONEY
AS
/********************************************************************
<Author>Not Known</Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="24/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
BEGIN 
DECLARE @CalculateTable TABLE (Amount MONEY, AgentState VARCHAR(5))
DECLARE @Percentage BIT = 0, @Calculate MONEY, @Tax MONEY

INSERT INTO @CalculateTable

SELECT tc.AmountInDollars, a.AgentState
FROM TransferClosed AS tc WITH(NOLOCK)
JOIN Agent a WITH(NOLOCK) ON a.IdAgent = tc.idagent 
WHERE IdTransferClosed =@idTransfer

UNION 
	
SELECT tc.AmountInDollars, a.AgentState
FROM [Transfer] AS tc WITH(NOLOCK)
JOIN Agent a WITH(NOLOCK) ON a.IdAgent = tc.idagent 
 WHERE IdTransfer =@idTransfer


SELECT @Percentage=IsPercentage, @Calculate=tax.Amount 
FROM TaxByState AS tax WITH(NOLOCK)
JOIN @CalculateTable AS ct
ON ct.AgentState = tax.StateCode
WHERE 
ct.Amount >= tax.FromAmount AND 
ct.Amount < isnull(ToAmount,999999999)


SELECT @Tax =CASE @Percentage WHEN 0 THEN @Calculate ELSE Amount * @Calculate/100  END  FROM @CalculateTable

RETURN isnull(@Tax,0)
END 

