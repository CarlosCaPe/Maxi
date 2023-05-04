CREATE PROCEDURE [dbo].[st_GetCollectByCommissionDeb]
(
    @BeginDate DATETIME,
    @EndDate DATETIME,
	@CollectTypeId INT = NULL,
	@CommissionFilter INT = NULL -- 0 No aply filter, 1 CommissionRetain > 0, 2 CommissionRetain <= 0
)
AS
	--declare @BeginDate DATETIME = '2015-01-01 00:00:00'
	--declare @EndDate DATETIME = '2016-01-31 00:00:00'
	--declare @CollectTypeId INT = 1
	--declare @CommissionFilter INT = 0 
	----------------------------------------
	----------------------------------------

	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

	DECLARE @Enviroment NVARCHAR(MAX)
	SET @Enviroment = [dbo].[GetGlobalAttributeByName]('Enviroment')
	
	--IF @Enviroment <> 'Production'
	--	SET @EndDate=GETDATE()-1

	SELECT @BeginDate = [dbo].[RemoveTimeFromDatetime](@BeginDate)
	SELECT @EndDate = [dbo].[RemoveTimeFromDatetime](@EndDate+1)
	
	--SELECT @BeginDate AS BeginDate, @EndDate AS EndDate

    IF @CollectTypeId <= 0 SET @CollectTypeId = NULL
    IF @CommissionFilter IS NULL SET @CommissionFilter = 0

	CREATE TABLE  #pivotAgent  (idAgent INT,IdAgentStatus INT, RetainMoneyCommission INT, PeriodoActual BIT, IdAgentCommissionPay INT, IdAgentPaymentSchema INT) 
	CREATE TABLE #AgentMirror (idAgent int, RetainMoneyCommission bit, IdAgentStatus int, IdAgentCommissionPay int, IdAgentPaymentSchema int)
    
    INSERT INTO #pivotAgent (idAgent, PeriodoActual, IdAgentCommissionPay, IdAgentPaymentSchema)
	SELECT IdAgent, 0, IdAgentCommissionPay, IdAgentPaymentSchema FROM Agent WHERE IdAgentStatus IN (1,2,3,4,7) 

	INSERT INTO #AgentMirror
	SELECT idagent, RetainMoneyCommission, IdAgentStatus, IdAgentCommissionPay, IdAgentPaymentSchema
	FROM (
	      SELECT am.idagent, am.RetainMoneyCommission, am.IdAgentStatus, am.IdAgentCommissionPay, am.IdAgentPaymentSchema, 
	             Flag = CASE WHEN ROW_NUMBER() OVER(PARTITION BY am.IdAgent ORDER BY ID ASC) = 1 THEN 1 ELSE 0 END
	        FROM AgentMirror am WITH (NOLOCK)
	       WHERE am.InsertDate > @EndDate
	         AND EXISTS(SELECT 1 FROM #pivotAgent AS pa WITH(NOLOCK) WHERE 1 = 1 AND pa.IdAgent = am.IdAgent)
	      ) As t
	WHERE 1 = 1
	AND Flag = 1
	
	CREATE UNIQUE CLUSTERED INDEX TMPK_pivotagent ON #pivotAgent (idAgent)
	CREATE UNIQUE CLUSTERED INDEX IX_TMP_AgentMirror_IdAgent ON #AgentMirror (idAgent)
	
		 UPDATE p
		 SET  RetainMoneyCommission = CASE WHEN year(@BeginDate) = year(getdate()) AND month(@BeginDate) = month(getdate()) THEN a.RetainMoneyCommission ELSE
		 isnull
		 (
			 /*(
			 	SELECT TOP 1 
			 	am.RetainMoneyCommission
			 	FROM AgentMirror am WITH (NOLOCK)
			  	WHERE 
			  	am.InsertDate > @EndDate 
			  	AND   am.IdAgent = p.idagent 
			  	ORDER BY ID ASC
			  )*/ am.RetainMoneyCommission, a.RetainMoneyCommission 
		 ) 	END 	
		  
		 ,	 
		 
		 IdAgentStatus = CASE WHEN year(@BeginDate) = year(getdate()) AND month(@BeginDate) = month(getdate()) THEN a.IdAgentStatus ELSE
		 isnull
		 (
			 /*(
			 	SELECT TOP 1 
			 	am.IdAgentStatus 
			 	FROM AgentMirror am WITH (NOLOCK)
			  	WHERE 
			  		am.InsertDate > @EndDate 
			  	AND   am.IdAgent = p.idagent 
			  	ORDER BY ID ASC
			  )*/ am.IdAgentStatus, a.IdAgentStatus 
		 ) 	END 		 
		 
		 ,
		 IdAgentCommissionPay = CASE WHEN year(@BeginDate) = year(getdate()) AND month(@BeginDate) = month(getdate()) THEN a.IdAgentCommissionPay ELSE
		 isnull
		 (
			 /*(
			 	SELECT TOP 1 
			 	am.IdAgentCommissionPay 
			 	FROM AgentMirror am WITH (NOLOCK)
			  	WHERE 
			  		am.InsertDate > @EndDate
			  	AND   am.IdAgent = p.idagent 
			  	ORDER BY ID ASC 
			  )*/ am.IdAgentCommissionPay, a.IdAgentCommissionPay 
		 ) 	END 
		  ,
		 	 IdAgentPaymentSchema = CASE WHEN year(@BeginDate) = year(getdate()) AND month(@BeginDate) = month(getdate()) THEN a.IdAgentPaymentSchema ELSE
		 isnull
		 (
			 /*(
			 	SELECT TOP 1 
			 	am.IdAgentPaymentSchema 
			 	FROM AgentMirror am WITH (NOLOCK)
			  	WHERE 
			  	am.InsertDate > @EndDate 
			  	AND   am.IdAgent = p.idagent 
			  	ORDER BY ID ASC 
			  )*/ am.IdAgentPaymentSchema , a.IdAgentPaymentSchema 
		 ) 	END 
		 FROM #pivotAgent p 
		INNER JOIN Agent a ON a.IdAgent = p.idagent
		 LEFT JOIN #AgentMirror AS am ON am.IdAgent = p.IdAgent
		
		DELETE FROM #pivotAgent WHERE IdAgentStatus IS NULL 

	SELECT
		[IdAgent]
		, [AgentClass]
		, [AgentCode]
		, [AgentName]
		, RetainMoneyCommission [RetainMoneyCommission]
		, ROUND([Commission],2) [Commission]
		, ROUND([SpecialCommission],2) [SpecialCommission]
		, ROUND([CommissionRetain],2) [CommissionRetain]
		, [Debit]
		, ROUND([SpecialCommApplied],2) [SpecialCommApplied]
		, [BonusDebit]
		INTO #temporalTable
	FROM (
		  SELECT 
				A.[IdAgent]
				, CL.[Name] [AgentClass]
				, [AgentCode]
				, [AgentName]
				, PA.[RetainMoneyCommission]
				, CASE WHEN (ISNULL([AgentCommission],0) + ISNULL([SpecialCommission],0)) > 0 THEN (ISNULL([AgentCommission],0) + ISNULL([SpecialCommission],0)) ELSE 0 END [Commission]
				, CASE WHEN ISNULL([SpecialCommission],0) > 0 THEN ISNULL([SpecialCommission],0) ELSE 0 END [SpecialCommission]
				, CASE WHEN ISNULL([CommissionRetain],0)>0 THEN ISNULL([CommissionRetain],0) ELSE 0 END [CommissionRetain]
				, ROUND(ISNULL((SELECT TOP 1 [Balance] FROM [dbo].[AgentBalance] WITH (NOLOCK) WHERE [DateOfMovement]<@EndDate AND [IdAgent]=A.[IdAgent] AND [Description] <> 'Bonus' ORDER BY [DateOfMovement] DESC),0),2) [Debit]
				, CASE WHEN ISNULL([SpecialCommApplied],0)>0 THEN ISNULL([SpecialCommApplied],0) ELSE 0 END [SpecialCommApplied]
				, ROUND(ISNULL([SpecialCommission],0) - ISNULL([SpecialCommApplied],0),2) [BonusDebit]
			FROM [dbo].[Agent] A WITH (NOLOCK)
			JOIN [dbo].[AgentClass] CL WITH (NOLOCK) ON A.[IdAgentClass]=CL.[IdAgentClass]
			JOIN [dbo].[AgentStatus] S WITH (NOLOCK) ON A.[IdagentStatus]=S.[IdAgentStatus]
			LEFT JOIN #pivotAgent pa ON pa.IdAgent = a.IdAgent
		    LEFT JOIN (        
						SELECT [IdAgent] ,SUM([Commission]+[FxFee]) [AgentCommission] FROM [AgentBalance] WITH (NOLOCK) WHERE [DateOfMovement]>=@BeginDate AND [DateOfMovement] <= @EndDate GROUP BY [IdAgent]
					  )COM ON A.[IdAgent]=COM.[IdAgent]
			LEFT JOIN (
						SELECT [IdAgent], SUM([Commission]) [SpecialCommission] FROM [dbo].[SpecialCommissionBalance] WITH (NOLOCK) WHERE [DateOfApplication]>= @BeginDate AND [DateOfApplication]<@EndDate GROUP BY [IdAgent]
					  )[specialComm] ON A.[IdAgent]=[specialComm].[IdAgent]
			LEFT JOIN (
						SELECT [IdAgent], SUM(ISNULL([Commission],0)) [CommissionRetain] FROM [dbo].[AgentCommisionCollection] WITH (NOLOCK) WHERE [DateOfCollection]>=@BeginDate AND [DateOfCollection]<@EndDate GROUP BY [IdAgent]
					  )COMR ON A.[IdAgent]=COMR.[IdAgent]
			LEFT JOIN [dbo].[AgentFinalStatusHistory] H WITH (NOLOCK) ON A.[IdAgent]=H.[IdAgent] AND H.[DateOfAgentStatus]=@EndDate-1
			LEFT JOIN (
						SELECT [IdAgent], SUM([SpecialCommission]) [SpecialCommApplied] FROM [dbo].[AgentSpecialCommCollection] WITH (NOLOCK) WHERE [DateOfCollection]>= @BeginDate AND [DateOfCollection]<@EndDate AND [SpecialCommissionConceptId] = 1 GROUP BY [IdAgent]
					  )SCA ON A.[IdAgent] = SCA.[IdAgent]
		
		 	WHERE 
		 		H.[IdAgentCommissionPay] = ISNULL(@CollectTypeId,H.[IdAgentCommissionPay])
		   	AND ((PA.[IdAgentPaymentSchema]=1 AND ISNULL(H.[IdAgentStatus],0) IN (3,7) )
		  		OR (PA.[RetainMoneyCommission]=1 AND ISNULL(H.[IdAgentStatus],0) IN (1,4))
		  	OR (H.[IdAgentCommissionPay] = 4 AND A.[RetainMoneyCommission]=1 AND ISNULL(H.[IdAgentStatus],0) IN (2)))
		  	AND A.[AgentCode] NOT LIKE '%-B' AND A.[AgentCode] NOT LIKE '%-P'
			 		
		) T
		   
   	WHERE ROUND([Commission],2)>0
	ORDER BY [AgentCode]
	
	--SELECT * FROM #temporalTable

	IF @CommissionFilter <= 0
		SELECT [IdAgent], [AgentClass], [AgentCode], [AgentName], [RetainMoneyCommission], [Commission], [SpecialCommission], [CommissionRetain], [Debit], [BonusDebit], [SpecialCommApplied] FROM #temporalTable
	IF @CommissionFilter = 1
		SELECT [IdAgent], [AgentClass], [AgentCode], [AgentName], [RetainMoneyCommission], [Commission], [SpecialCommission], [CommissionRetain], [Debit], [BonusDebit], [SpecialCommApplied] FROM #temporalTable 
		WHERE ([Commission] - [CommissionRetain] - [SpecialCommission]) <= 0
	IF @CommissionFilter = 2
		SELECT [IdAgent], [AgentClass], [AgentCode], [AgentName], [RetainMoneyCommission], [Commission], [SpecialCommission], [CommissionRetain], [Debit], [BonusDebit], [SpecialCommApplied] FROM #temporalTable 
		WHERE ([Commission] - [CommissionRetain] - [SpecialCommission]) > 0


DROP TABLE #pivotAgent
DROP TABLE #temporalTable
DROP TABLE #AgentMirror
