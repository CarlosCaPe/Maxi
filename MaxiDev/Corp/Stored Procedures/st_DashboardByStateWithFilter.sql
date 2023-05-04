CREATE PROCEDURE [Corp].[st_DashboardByStateWithFilter]
(
    @WeeksAgo int,
    @NowWithTime Datetime,
    @Increment numeric(8,2),
    @IdUserSeller int,
    @State nvarchar(2) =  null,
    @IdUserRequester int,
    --@OnlyActiveAgents bit
    @StatusesPreselected XML,
    @IdCountry int = null,
    @IdGateway int = null,
    @IdPayer int = null
)
as
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="28/06/2022" Author="jdarellano" Name="#1">Performance: se agrega línea SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED.</log>
<log Date="2023/04/04" Author="jdarellano">Optimización de sp's.</log>
</ChangeLog>
*********************************************************************/
--------------------------------
--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;--#1
--------------------------------
BEGIN
	SET ARITHABORT ON;
	SET NOCOUNT ON;

	BEGIN TRY
		DECLARE @Country nvarchar(max);
		DECLARE @Gateway nvarchar(max);
		DECLARE @Payer nvarchar(max);
		DECLARE @Seller nvarchar(max);

		SELECT @Country = countryname FROM dbo.Country WITH (NOLOCK) WHERE idcountry = @IdCountry;
		SELECT @Gateway = gatewayname FROM dbo.Gateway WITH (NOLOCK) WHERE idgateway = @IdGateway;
		SELECT @Payer = payername FROM dbo.Payer WITH (NOLOCK) WHERE idpayer = @IdPayer;
		SELECT @Seller = UserName FROM dbo.Users WITH (NOLOCK) WHERE iduser = @IdUserSeller;

		DECLARE @tStatus TABLE
		(    
			id int    
		);    
    
		DECLARE @DocHandle int; 
		DECLARE @hasStatus bit;
		EXEC sp_xml_preparedocument @DocHandle OUTPUT, @StatusesPreselected;

		INSERT INTO @tStatus(id)
		SELECT id
		FROM OPENXML (@DocHandle, '/statuses/status',1)     
		WITH (id int);
    
		EXEC sp_xml_removedocument @DocHandle;

		DECLARE @Now Datetime,@EndDate Datetime, @StartDate Datetime, @NowStart Datetime
		DECLARE @OneMonthAgoSD DateTime,@OneMonthAgoED DateTime
		DECLARE @TwoMonthAgoSD DateTime,@TwoMonthAgoED DateTime
		DECLARE @ThreeMonthAgoSD DateTime,@ThreeMonthAgoED DateTime
		DECLARE @CurrentMonthSD DateTime,@CurrentMonthED DateTime
		DECLARE @DayOfMonth int,@TotalDaysOfCurrentMonth int;

		SET @Now = @NowWithTime;
		SELECT @NowStart = dbo.RemoveTimeFromDatetime(@Now);
		SET @EndDate = DATEADD(WEEK,@WeeksAgo*-1,@Now);
		SELECT @StartDate = dbo.RemoveTimeFromDatetime(@EndDate);

		SET @DayOfMonth = DAY(@Now);
		SET @TotalDaysOfCurrentMonth = DAY(DATEADD(d, -DAY(DATEADD(m,1,@Now)),DATEADD(m,1,@Now)));

		SELECT @OneMonthAgoSD = dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-1,@Now));
		SELECT @OneMonthAgoSD = DATEADD(DAY,(DATEPART(day,@OneMonthAgoSD))*-1+1 ,@OneMonthAgoSD);
		SELECT @OneMonthAgoED = DATEADD(MONTH,+1,@OneMonthAgoSD);


		SELECT @TwoMonthAgoSD = dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-2,@Now));
		SELECT @TwoMonthAgoSD = DATEADD(DAY,(DATEPART(day,@TwoMonthAgoSD))*-1+1 ,@TwoMonthAgoSD);
		SELECT @TwoMonthAgoED = DATEADD(MONTH,+1,@TwoMonthAgoSD);

		SELECT @ThreeMonthAgoSD = dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-3,@Now));
		SELECT @ThreeMonthAgoSD = DATEADD(DAY,(DATEPART(day,@ThreeMonthAgoSD))*-1 + 1 ,@ThreeMonthAgoSD);
		SELECT @ThreeMonthAgoED = DATEADD(MONTH,+1,@ThreeMonthAgoSD);

		SELECT @CurrentMonthSD = dbo.RemoveTimeFromDatetime(@Now);
		SELECT @CurrentMonthSD = DATEADD(DAY,(DATEPART(day,@CurrentMonthSD))*-1+1 ,@CurrentMonthSD);
		SELECT @CurrentMonthED = dbo.RemoveTimeFromDatetime(@Now) + 1;

		--Select @Now,@EndDate,@StartDate,@OneMonthAgoSD,@OneMonthAgoED,@TwoMonthAgoSD,@TwoMonthAgoED,@ThreeMonthAgoSD,@ThreeMonthAgoED,@CurrentMonthSD,@CurrentMonthED

		DECLARE @IsAllSeller bit;
		--SET @IsAllSeller = (Select top 1 1 From [Users] where @IdUserSeller=0 and [IdUser] = @IdUserRequester and [IdUserType] = 1);
		SET @IsAllSeller = (SELECT 1 FROM dbo.[Users] WITH (NOLOCK) WHERE @IdUserSeller = 0 AND [IdUser] = @IdUserRequester AND [IdUserType] = 1);

		CREATE TABLE #SellerSubordinates
		(
			IdSeller int
		);

		/*
		Insert into #SellerSubordinates 
		Select IdUserSeller From [Seller] Where @IdUserSeller=0 and ([IdUserSellerParent] = @IdUserRequester or [IdUserSeller] = @IdUserRequester)
		*/
		-------Nuevo proceso de busqueda recursiva de Sellers---------------------

		DECLARE @IdUserBaseText nvarchar(max);

		--set @IdUserBaseText='%/'+isnull(convert(varchar,@IdUserRequester),'0')+'/%'
		SET @IdUserBaseText = CONCAT('%/',ISNULL(CONVERT(varchar,@IdUserRequester),'0'),'/%');

		--;WITH items AS (
		SELECT 
			u.IdUser,
			u.UserName,
			u.UserLogin, 
			0 AS [Level],
			--CAST('/'+convert(varchar,iduser)+'/' as varchar(2000)) AS [Path]
			CAST(CONCAT('/',CONVERT(varchar,iduser),'/') AS varchar(2000)) AS [Path]
		INTO #items
		FROM dbo.Users AS u WITH (NOLOCK)
		INNER JOIN dbo.Seller AS s WITH (NOLOCK) ON u.iduser = s.iduserseller 
		WHERE u.IdGenericStatus = 1 
		AND s.IdUserSellerParent IS NULL;


		SELECT
			IdUser,
			UserName,
			UserLogin,
			[Level],
			[Path]
		INTO #SellerTree
		FROM 
		(
			SELECT
				IdUser,
				UserName,
				UserLogin,
				[Level],
				[Path]
			FROM #items
    
			UNION ALL

			SELECT 
				u.iduser,
				u.username,
				u.userlogin, 
				[Level] + 1, 
				--CAST(itms.path+convert(varchar,isnull(u.iduser,''))+'/' as varchar(2000))  AS Path
				CAST(CONCAT(itms.[Path],CONVERT(varchar,ISNULL(u.iduser,'')),'/') AS varchar(2000)) AS [Path]
			FROM dbo.Users AS u WITH (NOLOCK)
			INNER JOIN dbo.Seller AS s WITH (NOLOCK) ON u.iduser = s.iduserseller 
			INNER JOIN #items itms ON itms.iduser = s.IdUserSellerParent
			WHERE u.IdGenericStatus = 1
		) AS S;

		INSERT INTO #SellerSubordinates 
		SELECT iduser FROM #SellerTree WHERE [Path] LIKE @IdUserBaseText AND @IdUserSeller = 0;

		--------------------------------------------------------------------------

		------ Number of transaction Same hours weeks ago ------------------------
		SELECT SUM(NumTran) AS TotalWeeksAgo, IdAgent 
		INTO #T1
		FROM
		(
			SELECT SUM(1) AS NumTran, A.IdAgent 
			FROM dbo.[Transfer] AS T WITH (NOLOCK)
			INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
			INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
			WHERE T.DateOfTransfer >= @StartDate AND T.DateOfTransfer < @EndDate
					AND A.AgentState = ISNULL(@State,A.AgentState)
					AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
					--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
					AND a.idagentstatus IN (SELECT id FROM @tStatus)
					AND c.idcountry = ISNULL(@idcountry,c.idcountry)
					AND t.idgateway = ISNULL(@idgateway,t.idgateway)
					AND t.idpayer = ISNULL(@idpayer,t.idpayer)
			GROUP BY A.IdAgent
		
			UNION ALL

			SELECT SUM(1) AS NumTran, A.IdAgent 
			FROM dbo.TransferClosed AS T WITH (NOLOCK)
			INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
			INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
			WHERE T.DateOfTransfer >= @StartDate AND T.DateOfTransfer < @EndDate
					AND A.AgentState = ISNULL(@State,A.AgentState)
					AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
					--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
					AND a.idagentstatus IN (SELECT id FROM @tStatus)
					AND c.idcountry = ISNULL(@idcountry,c.idcountry)
					AND t.idgateway = ISNULL(@idgateway,t.idgateway)
					AND t.idpayer = ISNULL(@idpayer,t.idpayer)
			GROUP BY A.IdAgent
		
			UNION ALL

			SELECT SUM(1) * -1 AS NumTran, A.IdAgent 
			FROM dbo.[Transfer] AS T WITH (NOLOCK)
			INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
			INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
			WHERE T.DateStatusChange >= @StartDate AND T.DateStatusChange < @EndDate AND T.IdStatus IN (22,31)
					AND A.AgentState = ISNULL(@State,A.AgentState)
					AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
					--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
					AND a.idagentstatus IN (SELECT id FROM @tStatus)
					AND c.idcountry = ISNULL(@idcountry,c.idcountry)
					AND t.idgateway = ISNULL(@idgateway,t.idgateway)
					AND t.idpayer = ISNULL(@idpayer,t.idpayer)
			GROUP BY A.IdAgent
		
			UNION ALL

			SELECT SUM(1) * -1 AS NumTran, A.IdAgent 
			FROM dbo.TransferClosed AS T WITH (NOLOCK)
			INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
			INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
			WHERE T.DateStatusChange >= @StartDate AND T.DateStatusChange < @EndDate AND T.IdStatus IN (22,31)
					AND A.AgentState = ISNULL(@State,A.AgentState)
					AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
					--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
					AND a.idagentstatus IN (SELECT id FROM @tStatus)
					AND c.idcountry = ISNULL(@idcountry,c.idcountry)
					AND t.idgateway = ISNULL(@idgateway,t.idgateway)
					AND t.idpayer = ISNULL(@idpayer,t.idpayer)
			GROUP BY A.IdAgent
		) AS LT
		GROUP BY IdAgent;


		------ Number of transaction Today   ------------------------

		--#tempT1
		SELECT t.IdCountryCurrency, t.idagent,a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, A.AgentState,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		INTO #tempT1 
		FROM dbo.[Transfer] AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		WHERE T.DateOfTransfer >= @NowStart AND T.DateOfTransfer < @Now
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND c.idcountry = ISNULL(@idcountry,c.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempT2
		SELECT t.IdCountryCurrency, t.idagent,a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, A.AgentState,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		INTO #tempT2 
		FROM dbo.TransferClosed AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		WHERE T.DateOfTransfer >= @NowStart AND T.DateOfTransfer < @Now
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND c.idcountry = ISNULL(@idcountry,c.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempT3
		SELECT t.IdCountryCurrency, t.idagent,a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL((((CASE WHEN TA.IdTransfer IS NULL AND T.IdStatus = 22 THEN 0 ELSE Fee END) - agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, A.AgentState,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		INTO #tempT3 
		FROM dbo.[Transfer] AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		LEFT JOIN dbo.TransferNotAllowedResend AS TA WITH (NOLOCK) ON T.IdTransfer = TA.IdTransfer  
		WHERE T.DateStatusChange >= @NowStart AND T.DateStatusChange < @Now AND T.IdStatus IN (22,31)
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND c.idcountry = ISNULL(@idcountry,c.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempT4
		SELECT t.IdCountryCurrency, t.idagent,a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL((((CASE WHEN TA.IdTransfer IS NULL AND T.IdStatus = 22 THEN 0 ELSE Fee END)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, A.AgentState,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		INTO #tempT4 
		FROM dbo.TransferClosed AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		LEFT JOIN dbo.TransferNotAllowedResend AS TA WITH (NOLOCK) ON T.IdTransferClosed = TA.IdTransfer  
		WHERE T.DateStatusChange >= @NowStart AND T.DateStatusChange < @Now AND T.IdStatus IN (22,31)
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND c.idcountry = ISNULL(@idcountry,c.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--acumulado
		Select SUM(NumTran) AS TotalToday, SUM(AmountInDollars) TotalAmountInDollarsToday, IdAgent 
		INTO #T2
		FROM(
			SELECT SUM(1) AS NumTran,SUM(AmountInDollars - (CASE WHEN IdAgentCollectType = 1 THEN 0 ELSE ISNULL(AmountInDollarsForCommission * FactorNew,0) END) - (ISNULL(CommissionNew,0))) AmountInDollars, IdAgent 
			FROM #tempT1 AS T
			LEFT JOIN dbo.BankCommission AS b WITH (NOLOCK) ON b.DateOfBankCommission = DateOfCommission AND b.active = 1
			LEFT JOIN dbo.PayerConfig AS x WITH (NOLOCK) ON t.idgateway = x.idgateway AND t.idpayer = x.idpayer AND t.idpaymenttype = x.idpaymenttype AND x.IdCountryCurrency = t.IdCountryCurrency
			LEFT JOIN dbo.PayerConfigCommission AS p WITH (NOLOCK) ON p.DateOfpayerconfigCommission = DateOfCommission AND x.idpayerconfig = p.idpayerconfig AND p.active = 1
			GROUP BY IdAgent
    
			UNION ALL
		
			SELECT SUM(1) AS NumTran,SUM(AmountInDollars - (CASE WHEN IdAgentCollectType = 1 THEN 0 ELSE ISNULL(AmountInDollarsForCommission * FactorNew,0) END) - (ISNULL(CommissionNew,0))) AmountInDollars, IdAgent 
			FROM #tempT2 AS T
			LEFT JOIN dbo.BankCommission AS b WITH (NOLOCK) ON b.DateOfBankCommission = DateOfCommission AND b.active = 1
			LEFT JOIN dbo.PayerConfig AS x WITH (NOLOCK) ON t.idgateway = x.idgateway AND t.idpayer = x.idpayer AND t.idpaymenttype = x.idpaymenttype AND x.IdCountryCurrency = t.IdCountryCurrency
			LEFT JOIN dbo.PayerConfigCommission AS p WITH (NOLOCK) ON p.DateOfpayerconfigCommission = DateOfCommission AND x.idpayerconfig = p.idpayerconfig AND p.active = 1
			GROUP BY IdAgent
    
			UNION ALL
		
			SELECT SUM(1)* -1 AS NumTran,SUM(AmountInDollars - (CASE WHEN IdAgentCollectType = 1 THEN 0 ELSE ISNULL(AmountInDollarsForCommission * FactorNew,0) END) - (ISNULL(CommissionNew,0))) * -1 AmountInDollars, IdAgent 
			FROM #tempT3 AS T
			LEFT JOIN dbo.BankCommission AS b WITH (NOLOCK) ON b.DateOfBankCommission = DateOfCommission AND b.active = 1
			LEFT JOIN dbo.PayerConfig AS x WITH (NOLOCK) ON t.idgateway = x.idgateway AND t.idpayer = x.idpayer AND t.idpaymenttype = x.idpaymenttype AND x.IdCountryCurrency = t.IdCountryCurrency
			LEFT JOIN dbo.PayerConfigCommission AS p WITH (NOLOCK) ON p.DateOfpayerconfigCommission = DateOfCommission AND x.idpayerconfig = p.idpayerconfig AND p.active = 1
			GROUP BY IdAgent
    
			UNION ALL
		
			SELECT SUM(1) * -1 AS NumTran,SUM(AmountInDollars - (CASE WHEN IdAgentCollectType = 1 THEN 0 ELSE ISNULL(AmountInDollarsForCommission * FactorNew,0) END) - (ISNULL(CommissionNew,0))) * -1 AmountInDollars, IdAgent 
			FROM #tempT4 AS T
			LEFT JOIN dbo.BankCommission AS b WITH (NOLOCK) ON b.DateOfBankCommission = DateOfCommission AND b.active = 1
			LEFT JOIN dbo.PayerConfig AS x WITH (NOLOCK) ON t.idgateway = x.idgateway AND t.idpayer = x.idpayer AND t.idpaymenttype = x.idpaymenttype AND x.IdCountryCurrency = t.IdCountryCurrency
			LEFT JOIN dbo.PayerConfigCommission AS p WITH (NOLOCK) ON p.DateOfpayerconfigCommission = DateOfCommission AND x.idpayerconfig = p.idpayerconfig AND p.active = 1
			GROUP BY IdAgent
		) AS LT
		GROUP BY IdAgent;


		------ Number of transaction One Month Ago ------------------------
		SELECT SUM(Numtran) TotalOneMonthAgo, SUM(AmountInDollars) TotalAmountInDollarsOneMonthAgo, T.idagent 
		INTO #T3 
		FROM dbo.DashboardForGatewayCountry AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		WHERE T.[Date] >= @OneMonthAgoSD AND T.[Date] < @OneMonthAgoED
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))				
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND t.idcountry = ISNULL(@idcountry,t.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer)
		GROUP BY T.IdAgent;

		------ Number of transaction Two Month ago ------------------------
		SELECT SUM(Numtran) TotalTwoMonthAgo, SUM(AmountInDollars) TotalAmountInDollarsTwoMonthAgo, T.idagent 
		INTO #T4 
		FROM dbo.DashboardForGatewayCountry AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		WHERE T.[Date] >= @TwoMonthAgoSD AND T.[Date] < @TwoMonthAgoED
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))				
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND t.idcountry = ISNULL(@idcountry,t.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer)
		GROUP BY T.IdAgent;

		------ Number of transaction Three Month ago ------------------------
		SELECT SUM(Numtran) TotalThreeMonthAgo, SUM(AmountInDollars) TotalAmountInDollarsThreeMonthAgo, T.idagent 
		INTO #T5 
		FROM dbo.DashboardForGatewayCountry AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		WHERE T.[Date] >= @ThreeMonthAgoSD AND T.[Date] < @ThreeMonthAgoED
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))				
				AND a.idagentstatus IN (SELECT id FROM @tStatus)		
				AND t.idcountry = ISNULL(@idcountry,t.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer)
		GROUP BY T.IdAgent;

		------ Number of transaction Current Month ------------------------

		--#tempM1
		SELECT t.IdCountryCurrency, t.idagent,a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, A.AgentState,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		INTO #tempM1 
		FROM dbo.[Transfer] AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		WHERE T.DateOfTransfer >= @CurrentMonthSD AND T.DateOfTransfer < @CurrentMonthED
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND c.idcountry = ISNULL(@idcountry,c.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempM2
		SELECT t.IdCountryCurrency, t.idagent,a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, A.AgentState,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		INTO #tempM2 
		FROM dbo.TransferClosed AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		WHERE T.DateOfTransfer >= @CurrentMonthSD AND T.DateOfTransfer < @CurrentMonthED
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND c.idcountry = ISNULL(@idcountry,c.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempM3
		SELECT t.IdCountryCurrency, t.idagent,a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL((((CASE WHEN TA.IdTransfer IS NULL AND T.IdStatus = 22 THEN 0 ELSE Fee END) - agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, A.AgentState,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		INTO #tempM3 
		FROM dbo.[Transfer] AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		LEFT JOIN dbo.TransferNotAllowedResend AS TA WITH (NOLOCK) ON T.IdTransfer = TA.IdTransfer  
		WHERE T.DateStatusChange >= @CurrentMonthSD AND T.DateStatusChange < @CurrentMonthED AND T.IdStatus IN (22,31)
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND c.idcountry = ISNULL(@idcountry,c.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempM4
		SELECT t.IdCountryCurrency, t.idagent,a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL((((CASE WHEN TA.IdTransfer IS NULL AND T.IdStatus = 22 THEN 0 ELSE Fee END) - agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, A.AgentState,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		INTO #tempM4 
		FROM dbo.TransferClosed AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON T.IdAgent = A.IdAgent
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		LEFT JOIN dbo.TransferNotAllowedResend AS TA WITH (NOLOCK) ON T.IdTransferClosed = TA.IdTransfer  
		WHERE T.DateStatusChange >= @CurrentMonthSD AND T.DateStatusChange < @CurrentMonthED AND T.IdStatus IN (22,31)
				AND A.AgentState = ISNULL(@State,A.AgentState)
				AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
				--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
				AND a.idagentstatus IN (SELECT id FROM @tStatus)
				AND c.idcountry = ISNULL(@idcountry,c.idcountry)
				AND t.idgateway = ISNULL(@idgateway,t.idgateway)
				AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--acumulado
		SELECT SUM(NumTran) AS TotalCurrentMonth,SUM(AmountInDollars) TotalAmountInDollarsCurrentMonth, IdAgent 
		INTO #T6
		FROM
		(
			SELECT SUM(1) AS NumTran,SUM(AmountInDollars - (CASE WHEN IdAgentCollectType = 1 THEN 0 ELSE ISNULL(AmountInDollarsForCommission * FactorNew,0) END) - (ISNULL(CommissionNew,0))) AmountInDollars, IdAgent 
			FROM #tempM1 AS T
			LEFT JOIN dbo.BankCommission AS b WITH (NOLOCK) ON b.DateOfBankCommission = DateOfCommission AND b.active = 1
			LEFT JOIN dbo.PayerConfig AS x WITH (NOLOCK) ON t.idgateway = x.idgateway AND t.idpayer = x.idpayer AND t.idpaymenttype = x.idpaymenttype AND x.IdCountryCurrency = t.IdCountryCurrency
			LEFT JOIN dbo.PayerConfigCommission AS p WITH (NOLOCK) ON p.DateOfpayerconfigCommission = DateOfCommission AND x.idpayerconfig = p.idpayerconfig AND p.active = 1
			GROUP BY IdAgent
    
			UNION ALL
		
			SELECT SUM(1) AS NumTran,SUM(AmountInDollars - (CASE WHEN IdAgentCollectType = 1 THEN 0 ELSE ISNULL(AmountInDollarsForCommission * FactorNew,0) END) - (ISNULL(CommissionNew,0))) AmountInDollars, IdAgent 
			FROM #tempM2 AS T
			LEFT JOIN dbo.BankCommission AS b WITH (NOLOCK) ON b.DateOfBankCommission = DateOfCommission AND b.active = 1
			LEFT JOIN dbo.PayerConfig AS x WITH (NOLOCK) ON t.idgateway = x.idgateway AND t.idpayer = x.idpayer AND t.idpaymenttype = x.idpaymenttype AND x.IdCountryCurrency = t.IdCountryCurrency
			LEFT JOIN dbo.PayerConfigCommission AS p WITH (NOLOCK) ON p.DateOfpayerconfigCommission = DateOfCommission AND x.idpayerconfig = p.idpayerconfig AND p.active = 1
			GROUP BY IdAgent
    
			UNION ALL
		
			SELECT SUM(1) * -1 AS NumTran,SUM(AmountInDollars - (CASE WHEN IdAgentCollectType = 1 THEN 0 ELSE ISNULL(AmountInDollarsForCommission * FactorNew,0) END) - (ISNULL(CommissionNew,0))) * -1 AmountInDollars, IdAgent 
			FROM #tempM3 AS T
			LEFT JOIN dbo.BankCommission AS b WITH (NOLOCK) ON b.DateOfBankCommission = DateOfCommission AND b.active = 1
			LEFT JOIN dbo.PayerConfig AS x WITH (NOLOCK) ON t.idgateway = x.idgateway AND t.idpayer = x.idpayer AND t.idpaymenttype = x.idpaymenttype AND x.IdCountryCurrency = t.IdCountryCurrency
			LEFT JOIN dbo.PayerConfigCommission AS p WITH (NOLOCK) ON p.DateOfpayerconfigCommission = DateOfCommission AND x.idpayerconfig = p.idpayerconfig AND p.active = 1
			GROUP BY IdAgent
    
			UNION ALL
		
			SELECT SUM(1) * -1 AS NumTran,SUM(AmountInDollars - (CASE WHEN IdAgentCollectType = 1 THEN 0 ELSE ISNULL(AmountInDollarsForCommission * FactorNew,0) END) - (ISNULL(CommissionNew,0))) * -1 AmountInDollars, IdAgent 
			FROM #tempM4 AS T
			LEFT JOIN dbo.BankCommission AS b WITH (NOLOCK) ON b.DateOfBankCommission = DateOfCommission AND b.active = 1
			LEFT JOIN dbo.PayerConfig AS x WITH (NOLOCK) ON t.idgateway = x.idgateway AND t.idpayer = x.idpayer AND t.idpaymenttype = x.idpaymenttype AND x.IdCountryCurrency = t.IdCountryCurrency
			LEFT JOIN dbo.PayerConfigCommission AS p WITH (NOLOCK) ON p.DateOfpayerconfigCommission = DateOfCommission AND x.idpayerconfig = p.idpayerconfig AND p.active = 1
			GROUP BY IdAgent
		) AS LT
		GROUP BY IdAgent;

		SELECT DISTINCT IdAgent AS IdAgent 
		INTO #T0 
		FROM dbo.Agent WITH (NOLOCK) 
		WHERE AgentState = ISNULL(@State,AgentState) AND idagentstatus IN (SELECT id FROM @tStatus)
		AND (@IsAllSeller = 1 OR (IdUserSeller = @IdUserSeller OR IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)));

		CREATE TABLE #T7
		(
			IdAgent int,
			TotalThreeMonthAgo int,
			TotalAmountInDollarsThreeMonthAgo money,
			TotalTwoMonthAgo int,
			TotalAmountInDollarsTwoMonthAgo money,
			TotalOneMonthAgo int,
			TotalAmountInDollarsOneMonthAgo money,
			TotalCurrentMonth int,
			TotalAmountInDollarsCurrentMonth money,
			TransfersStatusToTarget int,
			TransferTarget Decimal(9,2),
			TargetColor int,
			TotalWeekAgo int,
			TotalToday int,
			TotalColor int,
			TotalStatus int
		);

		INSERT #T7 (IdAgent,TotalThreeMonthAgo,TotalAmountInDollarsThreeMonthAgo,TotalTwoMonthAgo,TotalAmountInDollarsTwoMonthAgo,TotalOneMonthAgo,TotalAmountInDollarsOneMonthAgo,
		TotalCurrentMonth,TotalAmountInDollarsCurrentMonth,TotalWeekAgo,TotalToday)
		SELECT A.IdAgent,TotalThreeMonthAgo,TotalAmountInDollarsThreeMonthAgo,TotalTwoMonthAgo,TotalAmountInDollarsTwoMonthAgo,TotalOneMonthAgo,TotalAmountInDollarsOneMonthAgo,
		TotalCurrentMonth,TotalAmountInDollarsCurrentMonth,TotalWeeksAgo,TotalToday 
		FROM #T0 AS A
		FULL JOIN #T1 AS B ON A.IdAgent = B.IdAgent
		FULL JOIN #T2 AS C ON A.IdAgent = C.IdAgent
		FULL JOIN #T3 AS D ON A.IdAgent = D.IdAgent
		FULL JOIN #T4 AS E ON A.IdAgent = E.IdAgent
		FULL JOIN #T5 AS F ON A.IdAgent = F.IdAgent
		FULL JOIN #T6 AS G ON A.IdAgent = G.IdAgent;


		UPDATE #T7 SET TotalThreeMonthAgo = 0 WHERE TotalThreeMonthAgo IS NULL;
		UPDATE #T7 SET TotalTwoMonthAgo = 0 WHERE TotalTwoMonthAgo IS NULL;
		UPDATE #T7 SET TotalOneMonthAgo = 0 WHERE TotalOneMonthAgo IS NULL;
		UPDATE #T7 SET TotalCurrentMonth = 0 WHERE TotalCurrentMonth IS NULL;
		UPDATE #T7 SET TotalWeekAgo = 0 WHERE TotalWeekAgo IS NULL;
		UPDATE #T7 SET TotalToday = 0 WHERE TotalToday IS NULL;

		--nuevo
		UPDATE #T7 SET TotalAmountInDollarsOneMonthAgo = 0 WHERE TotalAmountInDollarsOneMonthAgo IS NULL;
		UPDATE #T7 SET TotalAmountInDollarsTwoMonthAgo = 0 WHERE TotalAmountInDollarsTwoMonthAgo IS NULL;
		UPDATE #T7 SET TotalAmountInDollarsThreeMonthAgo = 0 WHERE TotalAmountInDollarsThreeMonthAgo IS NULL;
		UPDATE #T7 SET TotalAmountInDollarsCurrentMonth = 0 WHERE TotalAmountInDollarsCurrentMonth IS NULL;

		UPDATE #T7 SET TransferTarget = ((TotalThreeMonthAgo + TotalTwoMonthAgo + TotalOneMonthAgo) / 3) * (1 + (@Increment / 100))
		UPDATE #T7 SET TotalStatus = TotalToday - TotalWeekAgo;
		UPDATE #T7 SET TransfersStatusToTarget = TotalCurrentMonth - ((@DayOfMonth * TransferTarget) / @TotalDaysOfCurrentMonth);
		UPDATE #T7 SET TargetColor = CASE WHEN TransfersStatusToTarget > 0 THEN 1 WHEN TransfersStatusToTarget < 0 THEN 2 WHEN TransfersStatusToTarget = 0 THEN 0 END;
		UPDATE #T7 SET TotalColor = CASE WHEN TotalStatus > 0 THEN 1 WHEN TotalStatus < 0 THEN 2 WHEN TotalStatus = 0 THEN 0 END;

		SELECT 
			a.AgentCode, 
			a.AgentName, 
			s.AgentStatus, 
			a.IdAgentStatus IdStatus,
			TotalThreeMonthAgo,
			ROUND(CASE TotalThreeMonthAgo WHEN 0 THEN 0 ELSE TotalAmountInDollarsThreeMonthAgo / CASE WHEN TotalThreeMonthAgo > 0 THEN 1 * TotalThreeMonthAgo ELSE -1 * TotalThreeMonthAgo END END,2) AverageAmountInDollarsThreeMonthAgo,
			TotalTwoMonthAgo,
			ROUND(CASE TotalTwoMonthAgo WHEN 0 THEN 0 ELSE TotalAmountInDollarsTwoMonthAgo / CASE WHEN TotalTwoMonthAgo > 0 THEN 1 * TotalTwoMonthAgo ELSE -1 * TotalTwoMonthAgo END END,2) AverageAmountInDollarsTwoMonthAgo,
			TotalOneMonthAgo,
			ROUND(CASE TotalOneMonthAgo WHEN 0 THEN 0 ELSE TotalAmountInDollarsOneMonthAgo / CASE WHEN TotalOneMonthAgo > 0 THEN 1 * TotalOneMonthAgo ELSE -1 * TotalOneMonthAgo END END,2) AverageAmountInDollarsOneMonthAgo,
			TotalCurrentMonth,
			ROUND(CASE TotalCurrentMonth WHEN 0 THEN 0 ELSE TotalAmountInDollarsCurrentMonth / CASE WHEN TotalCurrentMonth > 0 THEN 1 * TotalCurrentMonth ELSE -1 * TotalCurrentMonth END END,2) TotalAmountInDollarsCurrentMonth,
			TransfersStatusToTarget,
			ROUND(TransferTarget,0) TransferTarget,
			TargetColor,
			TotalWeekAgo,
			TotalToday,
			TotalColor,
			TotalStatus,
			ISNULL(@Country,'') Country, 
			ISNULL(@Gateway,'') Gateway, 
			ISNULL(@Payer,'') Payer,
			ISNULL(@Seller,'') Seller
		FROM #T7 t
		INNER JOIN dbo.Agent AS a WITH (NOLOCK) ON a.IdAgent = t.IdAgent
		INNER JOIN dbo.AgentStatus AS s WITH (NOLOCK) on s.IdAgentStatus = a.IdAgentStatus
		WHERE NOT(a.IdAgentStatus = 2 AND TotalThreeMonthAgo = 0 AND TotalTwoMonthAgo = 0 AND TotalOneMonthAgo = 0 AND TotalCurrentMonth = 0 AND TotalWeekAgo = 0 AND TotalToday = 0)
		AND A.IdUserSeller = CASE WHEN @IdUserSeller > 0 THEN @IdUserSeller ELSE A.IdUserSeller END
		ORDER BY a.AgentCode;

	END TRY
	BEGIN CATCH
		DECLARE @Message varchar(max) = ERROR_MESSAGE()
		INSERT INTO dbo.ErrorLogForStoreProcedure(StoreProcedure, ErrorDate, ErrorMessage) VALUES('Corp.st_DashboardByStateWithFilter', GETDATE(), @Message)
	END CATCH
END
