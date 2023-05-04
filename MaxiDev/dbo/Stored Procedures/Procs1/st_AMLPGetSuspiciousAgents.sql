CREATE PROCEDURE [dbo].[st_AMLPGetSuspiciousAgents]
AS
BEGIN
	DECLARE @AgentLockTimeOut INT = 10

	SELECT
		@AgentLockTimeOut = ISNULL(ms.Value, @AgentLockTimeOut)
	FROM AMLP_MonitorSettings ms WITH(NOLOCK)
	WHERE ms.IdMonitorSettings = 10

	;WITH CountDetail AS
	(
		SELECT 
			IdSuspiciousAgent,
			[1] NewBeneficiaries,
			[2] IsNewAgent,
			[3] TransactionsToRiskStates,
			[4] CanceledTransactions,
			[5] TransactionsSuspiciousAmount,
			[9] KYCRuleAlert,
			[10] RiskPayers
		FROM 
		(
			SELECT
				sac.IdSuspiciousAgent,
				sad.IdParameter,
				sad.ParameterValue
			FROM AMLP_SuspiciousAgentCurrent sac WITH (NOLOCK)
				JOIN AMLP_SuspiciousAgentDetail sad WITH (NOLOCK) ON sad.IdSuspiciousAgent = sac.IdSuspiciousAgent
		) T
		PIVOT (
			MAX(ParameterValue)
			FOR IdParameter IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10])
		) AS PV
	)
	SELECT
		sa.IdSuspiciousAgent,
		sa.IdAgent,
		a.AgentCode,
		a.AgentName,
		sa.IdCountry,
		c.CountryName Country,
		sa.NumberOfTransactions,
		sa.RiskLevel,
		sa.HoldTransactions,
		ISNULL(cd.NewBeneficiaries, 0) NewBeneficiaries,
		ISNULL(cd.IsNewAgent, 0) IsNewAgent,
		ISNULL(cd.TransactionsToRiskStates, 0) TransactionsToRiskStates,
		ISNULL(cd.CanceledTransactions, 0) CanceledTransactions,
		ISNULL(cd.TransactionsSuspiciousAmount, 0) TransactionsSuspiciousAmount,
		ISNULL(cd.KYCRuleAlert, 0) KYCRuleAlert,
		ISNULL(cd.RiskPayers, 0) RiskPayerLevel,
		(SELECT TOP 1 t.DateOfTransfer FROM [Transfer] t WITH (NOLOCK) WHERE t.IdAgent = sac.IdAgent AND t.DateOfTransfer > CONVERT(DATE, sa.CreationDate) ORDER BY t.DateOfTransfer DESC) DateLastTransaction,
		NULL SkippedDate,
		NULL SkippedUser,
		sa.CreationDate AlertDate,
		CONCAT(ISNULL(cd.NewBeneficiaries, 0), '% (', ((sa.NumberOfTransactions * ISNULL(cd.NewBeneficiaries, 0)) / 100), ')') NewBeneficiariesDetail,
		ISNULL(u.UserName, '') LockByUser
	FROM AMLP_SuspiciousAgentCurrent sac WITH (NOLOCK)
		JOIN Agent a WITH (NOLOCK) ON a.IdAgent = sac.IdAgent
		JOIN Country c WITH (NOLOCK) ON c.IdCountry = sac.IdCountry
		JOIN AMLP_SuspiciousAgent sa WITH (NOLOCK) ON sac.IdSuspiciousAgent = sa.IdSuspiciousAgent
		LEFT JOIN CountDetail cd WITH (NOLOCK) ON cd.IdSuspiciousAgent = sac.IdSuspiciousAgent
		LEFT JOIN AMLP_SuspiciousAgentLock l WITH (NOLOCK) ON l.IdAgent = sac.IdAgent AND l.IdCountry = sac.IdCountry AND DATEDIFF(MINUTE, l.LastUpdate, GETDATE()) <= @AgentLockTimeOut
		LEFT JOIN Users u ON u.IdUser = l.IdUser
END