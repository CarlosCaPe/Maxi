CREATE PROCEDURE [dbo].[st_AMLPGetSuspiciousAgentDetail]
(
	@IdAgent	INT,
	@IdCountry	INT
)
AS
BEGIN
	
	DECLARE @IdSuspiciousAgent	INT,
			@DayOfWeek			INT

	SELECT TOP 1
		@IdSuspiciousAgent = sac.IdSuspiciousAgent
	FROM AMLP_SuspiciousAgentCurrent sac WITH(NOLOCK)
	WHERE sac.IdAgent = @IdAgent AND sac.IdCountry = @IdCountry

	SET @DayOfWeek = DATEPART(WEEKDAY, GETDATE()) - 1

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
		(SELECT TOP 1 t.DateOfTransfer FROM Transfer t WHERE t.IdAgent = sa.IdAgent ORDER BY t.DateOfTransfer DESC) DateLastTransaction,
		NULL SkippedDate,
		NULL SkippedUser,
		sa.CreationDate AlertDate,
		CASE WHEN ch.StartTime IS NULL OR ch.EndTime IS NULL
			THEN 'Closed'
			ELSE CONCAT(
				DATENAME(WEEKDAY, GETDATE()), 
				', ', 
				FORMAT(CAST(ch.StartTime AS DATETIME), 'HH:mm'),
				' - ', 
				FORMAT(CAST(ch.EndTime AS DATETIME), 'HH:mm')
			)
		END DaySchedule
	FROM AMLP_SuspiciousAgent sa WITH(NOLOCK) 
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = sa.IdAgent
		JOIN Country c WITH(NOLOCK) ON c.IdCountry = sa.IdCountry
		LEFT JOIN CollectionCallendarHours ch WITH(NOLOCK) ON ch.IdAgent = sa.IdAgent AND ch.DayNumber = @DayOfWeek
	WHERE sa.IdSuspiciousAgent = @IdSuspiciousAgent

	SELECT
		sad.IdSuspiciousAgentDetail,
		sad.IdSuspiciousAgent,
		sad.IdParameter,
		p.Name ParameterName,
		sad.ParameterValue,
		sad.RiskLevel,
		sad.CreationDate
	FROM AMLP_SuspiciousAgentDetail sad WITH(NOLOCK)
		JOIN AMLP_Parameter p WITH(NOLOCK) ON p.IdParameter = sad.IdParameter
	WHERE sad.IdSuspiciousAgent = @IdSuspiciousAgent
END
