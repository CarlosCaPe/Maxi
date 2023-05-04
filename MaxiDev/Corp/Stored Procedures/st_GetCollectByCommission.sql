CREATE PROCEDURE [Corp].[st_GetCollectByCommission]
(
    @BeginDate DATETIME,
    @EndDate DATETIME
)
AS

	--declare     @BeginDate datetime,
	--		    @EndDate datetime

	--set @BeginDate = '2013/10/1'
	--set @EndDate = '2013-10-31 00:00:00.000'

	--Inicializacion de variables

	 SELECT @BeginDate = [dbo].[RemoveTimeFromDatetime](@BeginDate)
	 SELECT @EndDate = [dbo].[RemoveTimeFromDatetime](@EndDate+1)  
	 --select @today = dbo.RemoveTimeFromDatetime(getdate())

	SELECT
		C.[IdAgentCollection]
		, CL.[Name] AgentClass
		, [AgentCode]
		, [AgentName]
		, F.[CommissionPercentage]
		, F.[CommisionMoney]
		, SUM(ISNULL([AgentCommission], 0)) [Commission]
		, (ISNULL(C.[AmountToPay], 0) + SUM(ISNULL([specialComm].[SpecialCommission], 0))) [AmountToPay]
		, C.[Fee]
		, F.[IsPercent]
		, SUM(ISNULL([specialComm].[SpecialCommission], 0)) [SpecialCommission]
		, SUM(ISNULL(SCA.[SpecialCommApplied], 0)) [BonusApplied]
		, SUM(ISNULL([specialComm].[SpecialCommission], 0)) - SUM(ISNULL(SCA.[SpecialCommApplied], 0)) [BonusDebt]
	FROM [dbo].[AgentCommissionConfiguration] F WITH (NOLOCK)
	INNER JOIN [dbo].[AgentCollection] C WITH (NOLOCK) ON F.[idagentcollection] = C.[idagentcollection] AND C.[AmountToPay]>0
	JOIN [dbo].[Agent] A WITH (NOLOCK) ON A.[IdAgent] = C.[IdAgent]
	JOIN [dbo].[AgentClass] CL WITH (NOLOCK) ON A.[idagentclass] = CL.[IdAgentClass]
	LEFT JOIN (
		SELECT [IdAgent], SUM(ISNULL([Agentcommission], 0)) [AgentCommission]
			FROM (
				SELECT [IdAgent], [Commission] + [FxFee] [AgentCommission]
				FROM [dbo].[AgentBalance] WITH (NOLOCK)
				WHERE [DateOfMovement] >= @BeginDate AND [DateOfMovement] <= @EndDate AND [Description] <> 'Bonus'
						AND [IdAgent] IN (
											SELECT C.[IdAgent]
											FROM [dbo].[AgentCommissionConfiguration] ACC WITH (NOLOCK)
											INNER JOIN [dbo].[AgentCollection] C WITH (NOLOCK) ON ACC.[IdAgentCollection]=C.[IdAgentCollection] AND C.[AmountToPay]>0
											)
				UNION ALL
    
				SELECT [IdAgent], [Commission]*(-1) [AgentCommission]
				FROM [dbo].[AgentCommisionCollection] WITH (NOLOCK)
				WHERE [DateOfCollection] >= @BeginDate AND [DateOfCollection] <= @EndDate

		) T
		GROUP BY [IdAgent]
	) T ON C.[IdAgent] = T.[IdAgent]
	LEFT JOIN (
		SELECT [IdAgent], SUM([Commission]) SpecialCommission
		FROM [dbo].[SpecialCommissionBalance] WITH (NOLOCK)
		WHERE [DateOfApplication] >= @BeginDate AND [DateOfApplication]<@EndDate
		GROUP BY [IdAgent]
	) [specialComm] ON C.[IdAgent]=[specialComm].[IdAgent]
	LEFT JOIN (
		SELECT [IdAgent], SUM([SpecialCommission]) [SpecialCommApplied]
		FROM [dbo].[AgentSpecialCommCollection] WITH (NOLOCK)
		WHERE [DateOfCollection] >= @BeginDate AND [DateOfCollection]<@EndDate AND [SpecialCommissionConceptId] = 2 GROUP BY [IdAgent]
	)SCA ON A.[IdAgent] = SCA.[IdAgent]
	--verificar si se queda la validacion
	WHERE NOT EXISTS (
						SELECT [IdAgentCommisionCollection]
						FROM [dbo].[AgentCommisionCollection] WITH (NOLOCK)
						WHERE [IdCommisionCollectionConcept] = 1 AND [IdAgent] = C.[IdAgent] AND [DateOfCollection] = @EndDate-1
						)
	GROUP BY C.[idAgentCollection], CL.[Name], [AgentCode], [AgentName], F.[CommissionPercentage], F.[CommisionMoney], C.[AmountToPay], C.[Fee], F.[IsPercent]
	ORDER BY [AgentCode]


