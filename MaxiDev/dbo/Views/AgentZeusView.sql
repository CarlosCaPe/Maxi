CREATE VIEW dbo.AgentZeusView
AS
SELECT 	a.IdAgent,
		a.AgentName,
		a.AgentCode,
		a.AgentAddress,
		a.AgentCity,
		a.AgentState,
		a.AgentZipcode,
		a.AgentPhone,
	    CASE
	        WHEN abd.SubAccountRequired = 1
	           THEN a.SubAccount
	           ELSE brr.Account
	    END AS AccountNumber,
	    brr.ABA as RoutingNumber,
		a.OpenDate,
		a.DateOfLastChange,
		brr.BankName,
		abd.IdAgentBankDeposit,
		ags.AgentStatus,
		act.IdAgentCollectType,
		ao.Name,
		ao.LastName,
		ao.Address,
		ao.City,
		ao.State,
		ao.Zipcode,
		ao.Phone,
		ao.Cel
FROM [MaxiDEV].[dbo].Agent AS a WITH (NOLOCK)
INNER JOIN [MaxiDEV].[dbo].AgentBankDeposit AS abd WITH (NOLOCK)
	ON abd.IdAgentBankDeposit = a.IdAgentBankDeposit
INNER JOIN [MaxiDEV].[dbo].AgentStatus AS ags WITH (NOLOCK)
	ON ags.IdAgentStatus = a.IdAgentStatus
INNER JOIN [MaxiDEV].[dbo].AgentCollectType AS act WITH (NOLOCK)
	ON act.IdAgentCollectType = a.IdAgentCollectType
INNER JOIN [MaxiDEV].[dbo].Owner AS ao WITH (NOLOCK)
	ON ao.IdOwner = a.IdOwner
INNER JOIN [MaxiReportsDEV].[dbo].BankRountingRelation AS brr WITH (NOLOCK)
	ON brr.IdAgentBank = abd.IdAgentBankDeposit
WHERE ags.IdAgentStatus NOT IN (6,2,5)
	AND abd.IdAgentBankDeposit <> 6
	AND act.IdAgentCollectType <> 8 