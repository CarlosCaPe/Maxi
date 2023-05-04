
CREATE PROCEDURE [dbo].[st_AMLPreventionMonitoring]
(
	@DefaultDate DATETIME = NULL
)
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @Date DATETIME 
	DECLARE @DateFrom DATETIME 
	DECLARE @TransactionsPerDay		INT, 
			@Minutes				INT, 
			@PercNewBeneficiaries	INT, 
			@NewAgent				INT, 
			@HighRiskState			INT, 
			@Cancelled				INT, 
			@SuspiciousAmount		INT, 
			@DifLocation			INT,
			@PayedBeforeN			INT,
			@MinAmount				MONEY, 
			@MaxAmount				MONEY,
			@DaysNewAgent			INT, 
			@LevelAlert				INT,
			@RequiredMinAmount		INT
	
	-- Monitor Settings
	SELECT 
		@TransactionsPerDay = Value
	FROM AMLP_MonitorSettings WITH(NOLOCK)
	WHERE IdMonitorSettings= 5

	SELECT 
		@DaysNewAgent = Value
	FROM AMLP_MonitorSettings WITH(NOLOCK)
	WHERE IdMonitorSettings= 4

	SELECT 
		@Minutes = Value
	FROM AMLP_MonitorSettings WITH(NOLOCK)
	WHERE IdMonitorSettings= 1

	SELECT 
		@MinAmount = MinValue, 
		@MaxAmount = MaxValue 
	FROM AMLP_MonitorSettings WITH(NOLOCK)
	WHERE IdMonitorSettings= 4

	SELECT
		@RequiredMinAmount = ms.Value
	FROM AMLP_MonitorSettings ms WITH(NOLOCK)
	WHERE ms.IdMonitorSettings = 7

	SELECT
		@LevelAlert = ISNULL(ms.Value, 40)
	FROM AMLP_MonitorSettings ms WITH(NOLOCK)
	WHERE ms.IdMonitorSettings = 8

	-- Parameter
	SELECT 
		@PercNewBeneficiaries = RiskValue
	FROM AMLP_Parameter WITH(NOLOCK)
	WHERE IdParameter=1

	SELECT 
		@NewAgent = RiskValue
	FROM AMLP_Parameter WITH(NOLOCK)
	WHERE IdParameter=2

	SELECT
		@HighRiskState = RiskValue
	FROM AMLP_Parameter WITH(NOLOCK)
	WHERE IdParameter=3

	SELECT
		@Cancelled = RiskValue
	FROM AMLP_Parameter WITH(NOLOCK)
	WHERE IdParameter=4

	SELECT 
		@SuspiciousAmount = RiskValue
	FROM AMLP_Parameter WITH(NOLOCK)
	WHERE IdParameter=5

	SELECT
		@DifLocation = RiskValue
	FROM AMLP_Parameter WITH(NOLOCK)
	WHERE IdParameter=6

	SELECT 
		@PayedBeforeN = RiskValue
	FROM AMLP_Parameter WITH(NOLOCK)
	WHERE IdParameter=7
	--

	IF @DefaultDate IS NULL
		SET @Date = GETDATE()
	ELSE
		SET @Date = @DefaultDate

	SET @DateFrom=DATEADD(MI,-@Minutes,@Date)

	-- Only for tests
	SELECT @Date, @DateFrom

	DECLARE @Agents TABLE
	(
		IdAgent INT,
		IdCountry INT,
		IdParameter INT,
		RiskValue INT,
		RiskLevel INT
	) 

	DECLARE @AllAgents TABLE 
	(
		IdAgent INT,
		IdCountry INT, 
		Transactions INT
	)

	DECLARE @AllTransfers TABLE
	(
		IdTransfer		INT,
		IdAgent			INT,
		IdCountry		INT,
		IdStatus		INT,
		DateOfTransfer	DATETIME,
		Folio			INT,
		Amount			MONEY,
		IdPayer			INT,
		IdPaymentType	INT
	)

	DECLARE @Skipped TABLE 
	(
		IdAgent INT,
		IdCountry INT
	)

	INSERT INTO @Skipped (IdAgent, IdCountry)
	SELECT 
		IdAgent, IdCountry
	FROM AMLP_SkippedSuspiciousAgent WITH(NOLOCK)
	WHERE DateStopped>= @DateFrom AND DateResume > @Date 

	INSERT INTO @AllTransfers(IdTransfer, IdAgent, IdCountry, DateOfTransfer, Folio, Amount, IdStatus, IdPayer, IdPaymentType)
	SELECT
		t.IdTransfer,
		t.IdAgent,
		CC.IdCountry,
		t.DateOfTransfer,
		t.Folio,
		t.AmountInDollars,
		t.IdStatus,
		t.IdPayer,
		t.IdPaymentType
	FROM Transfer t WITH (NOLOCK)
		JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency
		LEFT JOIN @Skipped AGSK ON T.IdAgent=AGSK.IdAgent AND CC.IdCountry = AGSK.IdCountry
	WHERE 
		DateOfTransfer BETWEEN @DateFrom AND @Date 
		AND AGSK.IdAgent IS NULL
		AND T.AmountInDollars >= @RequiredMinAmount

	-- All Transactions
	;WITH cte AS 
	(
		--SELECT 
		--	T.IdAgent, CC.IdCountry, COUNT(t.IdTransfer) CC
		--FROM Transfer t WITH (NOLOCK)
		--	JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency
		--	LEFT JOIN @Skipped AGSK ON T.IdAgent=AGSK.IdAgent
		--	AND CC.IdCountry=AGSK.IdCountry
		--WHERE 
		--	DateOfTransfer BETWEEN @DateFrom AND @Date 
		--	AND AGSK.IdAgent IS NULL
		--	AND T.AmountInDollars >= @RequiredMinAmount
		--GROUP BY t.IdAgent, CC.IdCountry
		--HAVING COUNT(t.IdTransfer)>=@TransactionsPerDay
		SELECT
			alt.IdAgent,
			alt.IdCountry,
			COUNT(alt.IdTransfer) CC
		FROM @AllTransfers alt
		GROUP BY alt.IdAgent, alt.IdCountry
		HAVING COUNT(alt.IdTransfer)>=@TransactionsPerDay
	)
	INSERT INTO @AllAgents
	SELECT IdAgent, IdCountry , CC
	FROM cte

	-- => Parameter 1
	--Get Transactions with new beneficiaries
	IF EXISTS (SELECT 1 FROM AMLP_Parameter p WITH(NOLOCK) WHERE p.IdParameter = 1 AND p.RiskValue > 0)
	BEGIN
		;WITH newBen AS (
			SELECT 
				IdAgent, CC.IdCountry, COUNT(t.IdTransfer) CC
			FROM Transfer t WITH (NOLOCK)
				JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency
				JOIN Beneficiary B WITH (NOLOCK) ON T.IdBeneficiary=B.IdBeneficiary
			WHERE 
				DateOfTransfer BETWEEN @DateFrom AND @Date 
				AND CONVERT(DATE, B.CREATEDATE) = CONVERT(DATE,@DATE)
				AND T.AmountInDollars >= @RequiredMinAmount
			GROUP BY IdAgent, CC.IdCountry
			HAVING COUNT(t.IdTransfer)>=@TransactionsPerDay
		), 
		Final AS (
			SELECT 
				B.IdAgent, A.IdCountry, A.Transactions, CC, ((B.CC*100)/A.Transactions) [Percentage]
			FROM newBen B
			JOIN @AllAgents A ON A.IdAgent=B.IdAgent AND A.IdCountry=B.IdCountry
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT 
			IdAgent, IdCountry, CONVERT(FLOAT,f.Percentage), (CONVERT(FLOAT,DET.ResultValue)* @PercNewBeneficiaries)/10 RiskLevel, 1
		FROM Final F
			JOIN [AMLP_ParameterDetail] Det WITH(NOLOCK) ON F.Percentage BETWEEN Det.MinValue AND Det.MaxValue AND Det.idParameter=1
	END

	-- => Parameter 3
	--240,259,267 Nayarit, Sonora y Baja Calif
	-- Transactions to Risk State
	IF EXISTS (SELECT 1 FROM AMLP_Parameter p WITH(NOLOCK) WHERE p.IdParameter = 3 AND p.RiskValue > 0)
	BEGIN
		;WITH HighRiskState AS
		(
			SELECT 
				IdAgent, CC.idcountry, COUNT(DISTINCT IdTransfer) CC
			FROM 
				Transfer t WITH (NOLOCK)
				JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency
				JOIN Branch br WITH (NOLOCK) ON br.IdBranch=t.IdBranch
				JOIN City cy WITH (NOLOCK) ON cy.IdCity=br.IdCity
			WHERE 
				DateOfTransfer BETWEEN @DateFrom AND @Date 
				AND CY.IdState IN (240, 259, 267, 253, 255, 257, 266)
				AND T.AmountInDollars >= @RequiredMinAmount
			GROUP BY T.IdAgent, CC.IdCountry
			HAVING COUNT(IdTransfer)>=@TransactionsPerDay
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT 
			IdAgent, IdCountry, CONVERT(float,f.CC), ( CONVERT(FLOAT,DET.ResultValue)*  @HighRiskState)/10 RiskLevel, 3
		FROM HighRiskState F
			JOIN [AMLP_ParameterDetail] Det WITH(NOLOCK) ON F.CC BETWEEN Det.MinValue AND Det.MaxValue AND Det.idParameter=3
	END

	-- => Parameter 4
	-- Cancelled Transactions
	IF EXISTS (SELECT 1 FROM AMLP_Parameter p WHERE p.IdParameter = 4 AND p.RiskValue > 0)
	BEGIN
		;WITH cancelled AS
		(
			SELECT
				IdAgent, CC.IdCountry, COUNT(DISTINCT t.IdTransfer) CC
			FROM Transfer t WITH (NOLOCK)
				JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency
			WHERE 
				DateOfTransfer BETWEEN @DateFrom AND @Date
				AND IdStatus IN (22,26)
				AND T.AmountInDollars >= @RequiredMinAmount
			GROUP BY t.IdAgent,cc.IdCountry
			HAVING COUNT(t.IdTransfer)>=@TransactionsPerDay
		),
		Final AS (
			SELECT 
				B.IdAgent, A.IdCountry, A.Transactions, CC, ((B.CC*100)/A.Transactions) [Percentage]
			FROM cancelled B
			JOIN @AllAgents A ON A.IdAgent=B.IdAgent AND A.IdCountry=B.IdCountry
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT 
			IdAgent, IdCountry, CONVERT(FLOAT, f.Percentage), (CONVERT(FLOAT, DET.ResultValue)* @Cancelled)/10 RiskLevel, 4
		FROM Final F
			JOIN [AMLP_ParameterDetail] Det WITH(NOLOCK) ON F.Percentage BETWEEN Det.MinValue AND Det.MaxValue AND Det.idParameter=4
	END

	-- => Parameter 5
	----Suspicious Amount
	IF EXISTS (SELECT 1 FROM AMLP_Parameter p WHERE p.IdParameter = 5 AND p.RiskValue > 0)
	BEGIN
		;WITH suspAmount AS
		(
			SELECT  
				IdAgent,
				cc.idCountry,
				COUNT(DISTINCT t.IdTransfer) CC
			FROM Transfer t WITH (NOLOCK)
				JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency 
			WHERE AmountInDollars BETWEEN @MinAmount AND @MaxAmount+1
				AND DateOfTransfer BETWEEN @DateFrom AND @Date
				AND T.AmountInDollars >= @RequiredMinAmount
			GROUP BY IdAgent, cc.IdCountry
			HAVING COUNT(t.IdTransfer)>=@TransactionsPerDay
		),
		Final AS (
			SELECT 
				B.IdAgent, A.IdCountry, A.Transactions, CC, ((B.CC*100)/A.Transactions) [Percentage]
			FROM suspAmount B
			JOIN @AllAgents A ON A.IdAgent=B.IdAgent AND A.IdCountry=B.IdCountry
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT 
			IdAgent, IdCountry, CONVERT(FLOAT, f.Percentage), (CONVERT(FLOAT, DET.ResultValue)* @SuspiciousAmount)/10 RiskLevel, 5
		FROM Final F
			JOIN [AMLP_ParameterDetail] Det WITH(NOLOCK) ON F.Percentage BETWEEN Det.MinValue AND Det.MaxValue AND Det.idParameter=5
	END

	-- => Parameter 6
	---- Cobradas en diferente estado 
	IF EXISTS (SELECT 1 FROM AMLP_Parameter p WHERE p.IdParameter = 6 AND p.RiskValue > 0)
	BEGIN
		;WITH PayedDifLocation AS
		(
			SELECT 
				T.IdAgent, 
				cc.IdCountry,
				COUNT(DISTINCT t.IdTransfer) CC
			FROM Transfer t WITH (NOLOCK)
				JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency
				LEFT JOIN 
						(SELECT IdTransfer, MAX(IdTransferPayInfo) IdTransferPayInfo 
						from TransferPayInfo WITH (NOLOCK)
						GROUP BY Idtransfer ) Pay ON Pay.Idtransfer=t.IdTransfer
				LEFT JOIN TransferPayInfo PayInfo WITH (NOLOCK) ON PAY.IdTransferPayInfo=PayInfo.IdTransferPayInfo
				LEFT JOIN Branch BR WITH (NOLOCK) ON BR.IdBranch=T.IdBranch
				LEFT JOIN City CT WITH (NOLOCK) ON CT.IdCity=BR.IdCity
				LEFT JOIN Branch BRP WITH (NOLOCK) ON BRP.IdBranch=PayInfo.IdBranch
				LEFT JOIN City CTP WITH (NOLOCK) ON CTP.IdCity=BRP.IdCity
			WHERE 
				T.IdPaymentType NOT IN (2,3) 
				AND IdStatus=30
				AND (CT.IdState <> CTP.IdState)
				AND DateOfTransfer BETWEEN @DateFrom AND @Date
				AND T.AmountInDollars >= @RequiredMinAmount
			GROUP BY T.IdAgent,CC.IdCountry
			HAVING COUNT(t.IdTransfer)>=@TransactionsPerDay
		), Final AS 
		(
			SELECT 
				B.IdAgent, A.IdCountry, A.Transactions, CC, ((B.CC*100)/A.Transactions) [Percentage]
			FROM PayedDifLocation B
			JOIN @AllAgents A ON A.IdAgent=B.IdAgent AND A.IdCountry=B.IdCountry
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT
			IdAgent, IdCountry, CONVERT(FLOAT, F.Percentage), ( CONVERT(FLOAT,DET.ResultValue) * @DifLocation)/10 RiskLevel, 6
		FROM Final F
			JOIN [AMLP_ParameterDetail] Det WITH(NOLOCK) ON F.Percentage BETWEEN Det.MinValue AND Det.MaxValue AND Det.idParameter=6
	END

	-- => Parameter 7
	-- Payed less than 10 min
	IF EXISTS (SELECT 1 FROM AMLP_Parameter p WHERE p.IdParameter = 7 AND p.RiskValue > 0)
	BEGIN
		;WITH tInfo AS
		(
			SELECT
				t.IdAgent,
				cc.IdCountry,
				COUNT(DISTINCT t.IdTransfer) CC
			FROM Transfer t WITH (NOLOCK)
				JOIN CountryCurrency CC WITH (NOLOCK) ON CC.IdCountryCurrency=T.IdCountryCurrency
				JOIN 
				(
					SELECT IdTransfer, MAX(IdTransferDetail) IdTransferDetail 
					FROM TransferDetail WITH (NOLOCK)
					WHERE IdStatus=30 AND DateOfMovement BETWEEN @DateFrom AND @Date
					GROUP BY IdTransfer
				) Pay ON Pay.IdTransfer=t.IdTransfer
				INNER JOIN TransferDetail P WITH (NOLOCK) ON p.IdTransferDetail=PAY.IdTransferDetail
			WHERE 
				t.DateOfTransfer BETWEEN @DateFrom AND @Date
				AND DATEDIFF(MI,T.DateOfTransfer, P.DateOfMovement)<=10
				AND IdPaymentType NOT IN (2) 
				AND T.AmountInDollars >= @RequiredMinAmount
			GROUP BY T.IdAgent, cc.IdCountry
			HAVING COUNT(t.IdTransfer)>=@TransactionsPerDay
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT 
			IdAgent, IdCountry, CONVERT(float,F.CC), ( CONVERT(FLOAT,DET.ResultValue)*  @PayedBeforeN)/10 RiskLevel, 7
		FROM tInfo F
		JOIN [AMLP_ParameterDetail] Det WITH(NOLOCK) ON F.CC BETWEEN Det.MinValue AND Det.MaxValue AND Det.idParameter=7
	END

	-- => Parameter 2
	-- New Agents
	IF EXISTS (SELECT 1 FROM AMLP_Parameter p WHERE p.IdParameter = 2 AND p.RiskValue > 0)
	BEGIN
		;WITH AgentCountryUQ AS 
		(
			SELECT DISTINCT 
				a.IdAgent,
				a.IdCountry,
				CASE WHEN DATEDIFF(DD, ag.OpenDate, GETDATE()) <= @DaysNewAgent 
					THEN 1
					ELSE 0
				END NewAgent
			FROM @Agents a
				JOIN Agent ag ON ag.IdAgent = a.IdAgent
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT
			auq.IdAgent,
			auq.IdCountry,
			auq.NewAgent,
			(pd.ResultValue * @NewAgent) / 10,
			pd.IdParameter
		FROM AgentCountryUQ auq
			JOIN AMLP_ParameterDetail pd WITH(NOLOCK) ON pd.IdParameter = 2 AND auq.NewAgent BETWEEN pd.MinValue AND pd.MaxValue
	END

	-- => Parameter 8
	-- Folios Consecutivos
	IF EXISTS (SELECT 1 FROM AMLP_Parameter p WHERE p.IdParameter = 8 AND p.RiskValue > 0)
	BEGIN
		;WITH cteFolios AS
		(
			SELECT
				alt.IdTransfer,
				alt.IdAgent,
				alt.IdCountry,
				alt.Folio,
				LAG(alt.IdTransfer) OVER (ORDER BY alt.IdAgent, alt.IdCountry) PreviusIdTransfer
			FROM @AllTransfers alt
			WHERE alt.IdStatus = 30
		), TotalConsecutiveFolios AS
		(
			SELECT
				cte.IdAgent,
				cte.IdCountry,
				SUM(
					CASE WHEN cte.IdAgent = prev.IdAgent AND cte.IdCountry = prev.IdCountry AND cte.Folio = (prev.Folio + 1)
						THEN 1
						ELSE 0
					END
				) ConsecutiveFolios
			FROM cteFolios cte
				JOIN cteFolios prev ON prev.IdTransfer = cte.PreviusIdTransfer
			GROUP BY cte.IdAgent, cte.IdCountry
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT 
			tcf.IdAgent,
			tcf.IdCountry,
			tcf.ConsecutiveFolios,
			((pd.ResultValue * p.RiskValue) / 10),
			p.IdParameter
		FROM TotalConsecutiveFolios tcf
			JOIN AMLP_Parameter p WITH(NOLOCK) ON p.IdParameter = 8
			JOIN AMLP_ParameterDetail pd WITH(NOLOCK) ON pd.IdParameter = p.IdParameter AND tcf.ConsecutiveFolios BETWEEN pd.MinValue AND pd.MaxValue
		WHERE pd.ResultValue > 0
	END

	-- => Parameter 9
	-- Agencia con envíos retenidos por KYC de fraudes
	IF EXISTS(SELECT 1 FROM AMLP_Parameter p WHERE p.IdParameter = 9)
	BEGIN
		;WITH KYCFraude AS
		(
			SELECT
				att.IdAgent,
				att.IdCountry,
				COUNT(att.IdTransfer) Total
			FROM @AllTransfers att
				JOIN BrokenRulesByTransfer brt WITH(NOLOCK) ON brt.IdTransfer = att.IdTransfer
				JOIN dbo.fnAMLPGetKYCAlerts() ra ON ra.IdRule = brt.IdRule
			GROUP BY att.IdAgent, att.IdCountry
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT
			kf.IdAgent,
			kf.IdCountry,
			kf.Total,
			((ISNULL(pd.ResultValue, 0) * p.RiskValue) / 10),
			p.IdParameter
		FROM KYCFraude kf
			JOIN AMLP_Parameter p WITH(NOLOCK) ON p.IdParameter = 9
			LEFT JOIN AMLP_ParameterDetail pd WITH(NOLOCK) ON pd.IdParameter = p.IdParameter AND kf.Total BETWEEN pd.MinValue AND pd.MaxValue
	END

	-- => Parameter 10
	-- Agencia con envíos hacia pagadores de riesgo
	IF EXISTS(SELECT 1 FROM AMLP_Parameter p WHERE p.IdParameter = 10)
	BEGIN

		;WITH RiskPayers AS
		(
			SELECT 
				att.IdAgent,
				att.IdCountry,
				MAX(rp.RiskValue) MaxRiskValue
			FROM @AllTransfers att
				JOIN AMLP_RiskPayer rp WITH(NOLOCK) ON rp.IdPayer = att.IdPayer AND rp.IdPaymentType = att.IdPaymentType
			GROUP BY att.IdAgent, att.IdCountry
		)
		INSERT INTO @Agents(IdAgent, IdCountry, RiskValue, RiskLevel, IdParameter)
		SELECT
			rp.IdAgent,
			rp.IdCountry,
			rp.MaxRiskValue,
			((ISNULL(pd.ResultValue, 0) * p.RiskValue) / 10),
			p.IdParameter
		FROM RiskPayers rp
			JOIN AMLP_Parameter p WITH(NOLOCK) ON p.IdParameter = 10
			LEFT JOIN AMLP_ParameterDetail pd WITH(NOLOCK) ON pd.IdParameter = p.IdParameter AND rp.MaxRiskValue BETWEEN pd.MinValue AND pd.MaxValue
	END

	-- => Insert Finals
	DECLARE @Finals TABLE 
	(IdAgent INT, IdCountry INT, RiskLevel INT)

	INSERT INTO @Finals
	SELECT 
		a.IdAgent, 
		IdCountry, 
		SUM(RiskLevel) RiskLevel 
	FROM @Agents a
	GROUP BY a.IdAgent, IdCountry

	DECLARE @Inserted TABLE (IdSuspiciousAgent INT, IdAgent INT, IdCountry INT) 
	
	INSERT INTO [dbo].[AMLP_SuspiciousAgent] 
	(
		IdAgent,
		IdCountry,
		RiskLevel,
		CreationDate,
		NumberOfTransactions,
		HoldTransactions
	)
	OUTPUT 
		INSERTED.IdSuspiciousAgent, 
		INSERTED.IdAgent, 
		INSERTED.IdCountry 
	INTO @Inserted 
	SELECT 
		F.IdAgent,
		F.IdCountry,
		RiskLevel,
		GETDATE(),
		A.Transactions,
		CASE WHEN RiskLevel >= 70 
			THEN 1 
			ELSE 0 
		END
	FROM @Finals F
		JOIN @AllAgents A ON A.IdAgent=F.IdAgent AND A.IdCountry=F.IdCountry
	WHERE RiskLevel>=@LevelAlert
	ORDER BY RiskLevel
		
	TRUNCATE TABLE [dbo].[AMLP_SuspiciousAgentCurrent]

	INSERT INTO [dbo].[AMLP_SuspiciousAgentCurrent] 
	(
		IdSuspiciousAgent,
		IdAgent,
		IdCountry
	)
	SELECT 
		IdSuspiciousAgent,
		IdAgent,
		IdCountry 
	FROM @Inserted

	INSERT INTO [dbo].[AMLP_SuspiciousAgentDetail] 
	(
		IdSuspiciousAgent,
		IdParameter,
		ParameterValue,
		RiskLevel,
		CreationDate
	)
	SELECT
		I.IdSuspiciousAgent,
		A.IdParameter,
		A.RiskValue,
		A.RiskLevel,
		GETDATE()
	FROM @Inserted I 
	JOIN @Agents A ON A.IdAgent=I.IdAgent AND A.IdCountry=I.IdCountry
END
