
CREATE VIEW [dbo].[vw_DepositSlipsCountLegacy]
AS
--SELECT IdAgent,SUM(Fichas) AS DepositSlipsCount,SUM(Amount) AS Amount,[Date],BankName  FROM (
--						SELECT AB.IdAgent,
--							   CASE WHEN AB.DebitOrCredit ='Credit' THEN SUM(AB.Amount) 
--									WHEN AB.DebitOrCredit ='Debit' THEN -SUM(AB.Amount) END AS Amount,
--							   CASE WHEN AB.DebitOrCredit ='Credit' THEN count(1) 
--									WHEN AB.DebitOrCredit ='Debit' THEN -count(1) END AS Fichas,
--							   AD.BankName,
--							   CAST(AB.DateOfMovement AS DATE) AS [Date]
--						FROM AgentBalance AB WITH (NOLOCK)
--						JOIN AgentDeposit AD WITH (NOLOCK) ON AB.IdAgentBalance=AD.IdAgentBalance
--						WHERE AB.DateOfMovement >= CAST(GETDATE()-1 AS DATE) AND AB.DateOfMovement < CAST(GETDATE() AS DATE)
--					--	AND AB.IdAgent=11158
--						--AND AB.IdAgentBalance in (105472235,105472256,105472292)
--						GROUP BY AB.IdAgent,AB.DebitOrCredit,CAST(AB.DateOfMovement AS DATE),AD.BankName
--						) AS T
--GROUP BY IdAgent,[Date],BankName 
SELECT * FROM DepositSlipsCountLegacy WITH (NOLOCK)
