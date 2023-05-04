CREATE PROCEDURE st_GetAgentAMLPActivity
(
	@IdAgent	INT,
	@Date		DATE
)
AS
BEGIN

	WITH AgentActivity AS
	(
		SELECT
			ROW_NUMBER() OVER (ORDER BY sa.IdSuspiciousAgent ASC) AS #,
			sa.IdSuspiciousAgent,
			sa.CreationDate,
			sa.NumberOfTransactions,
			sa.RiskLevel,
			sa.IdCountry,
			sa.IdAgent
		FROM AMLP_SuspiciousAgent sa WITH(NOLOCK)
		WHERE sa.IdAgent = @IdAgent
		AND CONVERT(DATE, sa.CreationDate) = @Date
	)
	SELECT
		aa.#,
		a.AgentName,
		aa.CreationDate,
		ct.CountryName,
		aa.NumberOfTransactions,
		aa.RiskLevel,
		p.Name ParameterName,
		sad.ParameterValue,
		sad.RiskLevel
	FROM AgentActivity aa
		JOIN Country ct WITH(NOLOCK) ON ct.IdCountry = aa.IdCountry
		JOIN AMLP_SuspiciousAgentDetail sad WITH(NOLOCK) ON sad.IdSuspiciousAgent = aa.IdSuspiciousAgent
		JOIN AMLP_Parameter p ON p.IdParameter = sad.IdParameter
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = aa.IdAgent
	ORDER BY aa.IdSuspiciousAgent

	SELECT
		u.UserLogin,
		a.AgentCode,
		ct.CountryName,
		sa.DateStopped,
		sa.DateResume,
		sa.Notes
	FROM AMLP_SkippedSuspiciousAgent sa WITH(NOLOCK)
		JOIN Users u WITH(NOLOCK) ON u.IdUser = sa.IdUser
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = sa.IdAgent
		JOIN Country ct WITH(NOLOCK) ON ct.IdCountry = sa.IdCountry
	WHERE sa.IdAgent = @IdAgent
	AND CONVERT(DATE, sa.DateStopped) = @Date

END
