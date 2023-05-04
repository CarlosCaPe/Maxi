
CREATE PROCEDURE [dbo].[st_DashboardWithFilter]
(
    @WeeksAgo int,
    @NowWithTime Datetime,
    @Increment numeric(8,2),
    @IdUserSeller int,
    @IdUserRequester int,
    --@OnlyActiveAgents bit
    @StatusesPreselected XML,
    @Type int = null,
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
<log Date="23/07/2019" Author="josesoto" Name="#1">Mejora para filtro en caso de usuario con estatus Disabled.</log>
<log Date="2023/03/31" Author="jdarellano">Optimización de sp.</log>
</ChangeLog>
*********************************************************************/
BEGIN
	BEGIN TRY
		SET ARITHABORT ON;
		--Set nocount on
		--SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

		SET @Type = ISNULL(@Type,1);

		DECLARE @Country nvarchar(max);
		DECLARE @Gateway nvarchar(max);
		DECLARE @Payer nvarchar(max);

		SELECT @Country = CountryName FROM dbo.Country WITH (NOLOCK) WHERE IdCountry = @IdCountry;
		SELECT @Gateway = GatewayName FROM dbo.Gateway WITH (NOLOCK) WHERE IdGateway = @IdGateway;
		SELECT @Payer = PayerName FROM dbo.Payer WITH (NOLOCK) WHERE IdPayer = @IdPayer;

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
    
		EXEC sp_xml_removedocument @DocHandle    

		Declare @Now Datetime,@EndDate Datetime, @StartDate Datetime, @NowStart Datetime
		Declare @OneMonthAgoSD DateTime,@OneMonthAgoED DateTime
		Declare @TwoMonthAgoSD DateTime,@TwoMonthAgoED DateTime
		Declare @ThreeMonthAgoSD DateTime,@ThreeMonthAgoED DateTime
		Declare @CurrentMonthSD DateTime,@CurrentMonthED DateTime
		Declare @DayOfMonth int,@TotalDaysOfCurrentMonth int

		SET @Now = @NowWithTime;
		SELECT @NowStart = dbo.RemoveTimeFromDatetime(@Now);
		SET @EndDate = DATEADD(WEEK,@WeeksAgo*-1,@Now);
		SELECT  @StartDate = dbo.RemoveTimeFromDatetime(@EndDate);

		SET @DayOfMonth = DAY(@Now);
		SET @TotalDaysOfCurrentMonth = DAY(DATEADD(d,-DAY(DATEADD(m,1,@Now)),DATEADD(m,1,@Now)));

		SELECT @OneMonthAgoSD = dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-1,@Now));
		SELECT @OneMonthAgoSD = DATEADD(DAY,(DATEPART(day,@OneMonthAgoSD))*-1+1 ,@OneMonthAgoSD);
		SELECT @OneMonthAgoED = DATEADD(MONTH,+1,@OneMonthAgoSD);


		SELECT @TwoMonthAgoSD = dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-2,@Now));
		SELECT @TwoMonthAgoSD = DATEADD(DAY,(DATEPART(day,@TwoMonthAgoSD))*-1+1 ,@TwoMonthAgoSD);
		SELECT @TwoMonthAgoED = DATEADD(MONTH,+1,@TwoMonthAgoSD);

		SELECT @ThreeMonthAgoSD= dbo.RemoveTimeFromDatetime(DATEADD(MONTH,-3,@Now));
		SELECT @ThreeMonthAgoSD = DATEADD(DAY,(DATEPART(day,@ThreeMonthAgoSD))*-1+1 ,@ThreeMonthAgoSD);
		SELECT @ThreeMonthAgoED = DATEADD(MONTH,+1,@ThreeMonthAgoSD);

		SELECT @CurrentMonthSD = dbo.RemoveTimeFromDatetime(@Now);
		SELECT @CurrentMonthSD = DATEADD(DAY,(DATEPART(day,@CurrentMonthSD))*-1+1 ,@CurrentMonthSD);
		SELECT @CurrentMonthED = dbo.RemoveTimeFromDatetime(@Now)+1;

		--Select @Now,@EndDate,@StartDate,@OneMonthAgoSD,@OneMonthAgoED,@TwoMonthAgoSD,@TwoMonthAgoED,@ThreeMonthAgoSD,@ThreeMonthAgoED,@CurrentMonthSD,@CurrentMonthED

		DECLARE @IsAllSeller bit; 
		--SET @IsAllSeller = (Select top 1 1 From [Users] where @IdUserSeller=0 and [IdUser] = @IdUserRequester and [IdUserType] = 1) 
		SET @IsAllSeller = (SELECT 1 From dbo.Users WITH (NOLOCK) WHERE @IdUserSeller = 0 AND [IdUser] = @IdUserRequester AND [IdUserType] = 1); 

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

		--SET @IdUserBaseText = '%/'+ISNULL(CONVERT(varchar,@IdUserRequester),'0')+'/%'
		SET @IdUserBaseText = CONCAT('%/',ISNULL(CONVERT(varchar,@IdUserRequester),'0'),'/%');

		--;WITH items AS (

		SELECT 
			U.IdUser,
			U.UserName,
			U.UserLogin,
			0 AS [Level],
			CAST(CONCAT('/',CONVERT(varchar,iduser),'/') as varchar(2000)) AS [Path]
		INTO #items
		FROM dbo.Users AS u WITH (NOLOCK)
		INNER JOIN dbo.Seller AS s WITH (NOLOCK) ON u.iduser = s.iduserseller 
		WHERE u.IdGenericStatus = 1 
		AND S.IdUserSellerParent IS NULL;

		SELECT
			iduser,
			username,
			userlogin,
			[Level],
			[Path]
		INTO #SellerTree
		FROM
		(
			SELECT 
				iduser,
				username,
				userlogin, 
				[Level], 
				[Path]
			FROM #items
    
			UNION ALL

			SELECT 
				u.iduser,
				u.username,
				u.userlogin, 
				[Level] + 1, 
				--CAST(itms.path+convert(varchar,isnull(u.iduser,''))+'/' as varchar(2000)) AS [Path]
				CAST(CONCAT(itms.[Path],CONVERT(varchar,ISNULL(u.iduser,'')),'/') AS varchar(2000)) AS [Path]
			FROM dbo.Users AS u WITH (NOLOCK)
			INNER JOIN dbo.Seller AS s WITH (NOLOCK) ON u.iduser = s.iduserseller 
			INNER JOIN #items AS itms ON itms.iduser = s.IdUserSellerParent
			WHERE U.idgenericstatus = 1
		) AS S;


		INSERT INTO #SellerSubordinates 
		SELECT iduser FROM #SellerTree WHERE [Path] LIKE @IdUserBaseText AND @IdUserSeller = 0;

		--------------------------------------------------------------------------

		------ Number of transaction Same hours weeks ago ------------------------
		--declare @type int  =2

		SELECT SUM(NumTran) AS TotalWeeksAgo, IdGeneric 
		INTO #T1
		FROM(
				SELECT SUM(1) as NumTran, CASE WHEN @type = 1 THEN S.IdState WHEN @type = 2 THEN t.idgateway WHEN @type = 3 THEN c.idcountry WHEN @type = 4 THEN a.iduserseller END AS IdGeneric 
				FROM dbo.[Transfer] AS T WITH (NOLOCK)
				INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON (T.IdAgent = A.IdAgent)
				INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON s.idcountry = 18 AND a.agentstate = s.statecode
				INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
				WHERE T.DateOfTransfer >= @StartDate AND T.DateOfTransfer < @EndDate
						AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
						--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
						AND a.idagentstatus IN (SELECT id FROM @tStatus)
						AND c.idcountry = ISNULL(@idcountry,c.idcountry)
						AND t.idgateway = ISNULL(@idgateway,t.idgateway)
						AND t.idpayer = ISNULL(@idpayer,t.idpayer)
				GROUP BY CASE WHEN @type = 1 THEN S.IdState WHEN @type = 2 THEN t.idgateway WHEN @type = 3 THEN c.idcountry WHEN @type = 4 THEN a.iduserseller END
			
				UNION ALL

				SELECT SUM(1) AS NumTran, CASE WHEN @type = 1 THEN S.IdState WHEN @type = 2 THEN t.idgateway WHEN @type = 3 THEN c.idcountry WHEN @type = 4 THEN a.iduserseller END AS IdGeneric 
				FROM dbo.TransferClosed AS T WITH (NOLOCK) --WITH(INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
				INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON (T.IdAgent = A.IdAgent)
				INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON s.idcountry = 18 AND a.agentstate = s.statecode
				INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
				where T.DateOfTransfer >= @StartDate AND T.DateOfTransfer < @EndDate
						AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
						--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
						AND a.idagentstatus IN (SELECT id FROM @tStatus)
						AND c.idcountry = ISNULL(@idcountry,c.idcountry)
						AND t.idgateway = ISNULL(@idgateway,t.idgateway)
						AND t.idpayer = ISNULL(@idpayer,t.idpayer)
				GROUP BY CASE WHEN @type = 1 THEN S.IdState WHEN @type = 2 THEN t.idgateway WHEN @type = 3 THEN c.idcountry WHEN @type = 4 THEN a.iduserseller END
			
				UNION ALL

				SELECT SUM(1)*-1 AS NumTran, CASE WHEN @type = 1 THEN S.IdState WHEN @type = 2 THEN t.idgateway WHEN @type = 3 THEN c.idcountry WHEN @type = 4 THEN a.iduserseller END AS IdGeneric 
				FROM dbo.[Transfer] AS T WITH (NOLOCK)
				INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON (T.IdAgent = A.IdAgent)
				INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON s.idcountry = 18 AND a.agentstate = s.statecode
				INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
				WHERE T.DateStatusChange >= @StartDate AND T.DateStatusChange<@EndDate AND T.IdStatus IN (22,31)
						AND (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
						--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
						AND a.idagentstatus IN (SELECT id FROM @tStatus)
						AND c.idcountry = ISNULL(@idcountry,c.idcountry)
						AND t.idgateway = ISNULL(@idgateway,t.idgateway)
						AND t.idpayer = ISNULL(@idpayer,t.idpayer)
				GROUP BY CASE WHEN @type = 1 THEN S.IdState WHEN @type = 2 THEN t.idgateway WHEN @type = 3 THEN c.idcountry WHEN @type = 4 THEN a.iduserseller END 
			
				UNION ALL

				SELECT SUM(1)*-1 AS NumTran, CASE WHEN @type = 1 THEN S.IdState WHEN @type = 2 THEN t.idgateway WHEN @type = 3 THEN c.idcountry WHEN @type = 4 THEN a.iduserseller END AS IdGeneric 
				FROM dbo.TransferClosed AS T WITH (NOLOCK) --WITH(INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
				INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON (T.IdAgent = A.IdAgent)
				INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON s.idcountry = 18 AND a.agentstate = s.statecode
				INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
				WHERE T.DateStatusChange >= @StartDate AND T.DateStatusChange < @EndDate AND T.IdStatus IN (22,31)
						AND (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
						--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
						AND a.idagentstatus IN (SELECT id FROM @tStatus)
						AND c.idcountry = ISNULL(@idcountry,c.idcountry)
						AND t.idgateway = ISNULL(@idgateway,t.idgateway)
						AND t.idpayer = ISNULL(@idpayer,t.idpayer)
				GROUP BY CASE WHEN @type = 1 THEN S.IdState WHEN @type = 2 THEN t.idgateway WHEN @type = 3 THEN c.idcountry WHEN @type = 4 THEN a.iduserseller END 
			) LT
		GROUP BY IdGeneric;

		------ Number of transaction Today   ------------------------

		--#tempT1
		SELECT t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL(((fee-agentcommission) + (((ReferenceExRate-ExRate) * AmountInDollars) / ReferenceExRate)),0),2) AS AmountInDollars, AmountInDollars AS AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) AS DateOfCommission 
		INTO #tempT1 
		FROM dbo.[Transfer] AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON (T.IdAgent=A.IdAgent)
		INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON s.idcountry = 18 AND a.agentstate = s.statecode
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		WHERE T.DateOfTransfer >= @NowStart AND T.DateOfTransfer < @Now
			AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
			--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
			AND a.idagentstatus IN (SELECT id FROM @tStatus)
			AND c.idcountry = ISNULL(@idcountry,c.idcountry)
			AND t.idgateway = ISNULL(@idgateway,t.idgateway)
			AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempT2
		SELECT t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AS AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) AS DateOfCommission 
		INTO #tempT2 
		FROM dbo.TransferClosed T WITH (NOLOCK) --with (nolock, INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON (T.IdAgent = A.IdAgent)
		INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON s.idcountry = 18 AND a.agentstate = s.statecode
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		WHERE T.DateOfTransfer >= @NowStart AND T.DateOfTransfer < @Now
			AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
			--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
			AND a.idagentstatus IN (SELECT id FROM @tStatus)
			AND c.idcountry = ISNULL(@idcountry,c.idcountry)
			AND t.idgateway = ISNULL(@idgateway,t.idgateway)
			AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempT3
		SELECT t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL((((CASE WHEN TA.IdTransfer IS NULL AND T.IdStatus=22 THEN 0 ELSE Fee END)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AS AmountInDollars, AmountInDollars AS AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) AS DateOfCommission 
		INTO #tempT3 
		FROM dbo.[Transfer] AS T WITH (NOLOCK)
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON (T.IdAgent = A.IdAgent)
		INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON s.idcountry = 18 AND a.agentstate = s.statecode
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		LEFT JOIN dbo.TransferNotAllowedResend AS TA WITH (NOLOCK) ON T.IdTransfer = TA.IdTransfer  
		WHERE T.DateStatusChange >= @NowStart AND T.DateStatusChange < @Now AND T.IdStatus IN (22,31)
			AND (@IsAllSeller = 1 OR (A.IdUserSeller = @IdUserSeller OR A.IdUserSeller IN (SELECT IdSeller FROM #SellerSubordinates)))
			--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
			AND a.idagentstatus IN (SELECT id FROM @tStatus)
			AND c.idcountry = ISNULL(@idcountry,c.idcountry)
			AND t.idgateway = ISNULL(@idgateway,t.idgateway)
			AND t.idpayer = ISNULL(@idpayer,t.idpayer);

		--#tempT4
		SELECT t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,ROUND(ISNULL((((CASE WHEN TA.IdTransfer IS NULL AND T.IdStatus = 22 THEN 0 ELSE Fee END)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AS AmountInDollars, AmountInDollars AS AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) AS DateOfCommission 
		INTO #tempT4 
		FROM dbo.TransferClosed AS T WITH (NOLOCK) --with (nolock, INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
		INNER JOIN dbo.Agent AS A WITH (NOLOCK) ON (T.IdAgent = A.IdAgent)
		INNER JOIN dbo.[State] AS s WITH (NOLOCK) ON s.idcountry = 18 AND a.agentstate = s.statecode
		INNER JOIN dbo.CountryCurrency AS c WITH (NOLOCK) ON t.idcountrycurrency = c.idcountrycurrency
		LEFT JOIN dbo.TransferNotAllowedResend AS TA WITH (NOLOCK) ON T.IdTransferClosed = TA.IdTransfer  
		WHERE T.DateStatusChange>= @NowStart and T.DateStatusChange<@Now and T.IdStatus in (22,31)
			AND (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
			--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
			AND a.idagentstatus in (select id from @tStatus)
			AND c.idcountry=isnull(@idcountry,c.idcountry)
			AND t.idgateway=isnull(@idgateway,t.idgateway)
			AND t.idpayer=isnull(@idpayer,t.idpayer);

		--acumulado
		Select SUM(NumTran) as TotalToday,sum(AmountInDollars) TotalAmountInDollarsToday, IdGeneric into #T2
			from(		
				select SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
				from #tempT1 T
				left join bankcommission b WITH (NOLOCK) on b.DateOfBankCommission=DateOfCommission and b.active=1
				left join payerconfig x WITH (NOLOCK) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
				left join payerconfigcommission p WITH (NOLOCK) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1 
				group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
				union all
		
				select SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
				from #tempT2 T
				left join bankcommission b WITH (NOLOCK) on b.DateOfBankCommission=DateOfCommission and b.active=1
				left join payerconfig x WITH (NOLOCK) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
				left join payerconfigcommission p WITH (NOLOCK) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
				group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
				union all
		
				select SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
				from #tempT3 T
				left join bankcommission b WITH (NOLOCK) on b.DateOfBankCommission=DateOfCommission and b.active=1
				left join payerconfig x WITH (NOLOCK) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
				left join payerconfigcommission p WITH (NOLOCK) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
				group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
				union all
		
				select SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
				from #tempT4 T
				left join bankcommission b WITH (NOLOCK) on b.DateOfBankCommission=DateOfCommission and b.active=1
				left join payerconfig x WITH (NOLOCK) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
				left join payerconfigcommission p WITH (NOLOCK) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
				group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			) LT
		group by IdGeneric;


		------ Number of transaction One Month ago ------------------------

		Select SUM(NumTran) as TotalOneMonthAgo,sum(AmountInDollars) TotalAmountInDollarsOneMonthAgo, IdGeneric  into #T3 
			from(
				select Numtran, AmountInDollars, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then t.idcountry when @type=4 then a.iduserseller end IdGeneric from DashboardForGatewayCountry T WITH (NOLOCK)
				Join Agent A WITH (NOLOCK) on (T.IdAgent=A.IdAgent)
				join  state s WITH (NOLOCK) on s.idcountry=18 and a.agentstate=s.statecode
				where T.Date>= @OneMonthAgoSD and T.Date<@OneMonthAgoED
						and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))		
						and a.idagentstatus in (select id from @tStatus)
						and t.idcountry=isnull(@idcountry,t.idcountry)
						and t.idgateway=isnull(@idgateway,t.idgateway)
						and t.idpayer=isnull(@idpayer,t.idpayer)	
			) LT
		group by IdGeneric;

		------ Number of transaction Two Month ago ------------------------

		Select SUM(NumTran) as TotalTwoMonthAgo,sum(AmountInDollars) TotalAmountInDollarsTwoMonthAgo, IdGeneric into #T4
			from(
				select Numtran, AmountInDollars, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then T.idcountry when @type=4 then a.iduserseller end IdGeneric from DashboardForGatewayCountry T WITH (NOLOCK)
				Join Agent A WITH (NOLOCK) on (T.IdAgent=A.IdAgent)
				join  state s WITH (NOLOCK) on s.idcountry=18 and a.agentstate=s.statecode
				where T.Date>= @TwoMonthAgoSD and T.Date<@TwoMonthAgoED
						and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))				
						and a.idagentstatus in (select id from @tStatus)		
						and t.idcountry=isnull(@idcountry,t.idcountry)
						and t.idgateway=isnull(@idgateway,t.idgateway)
						and t.idpayer=isnull(@idpayer,t.idpayer)
			) LT
		group by IdGeneric;


		------ Number of transaction Three Month ago ------------------------

		Select SUM(NumTran) as TotalThreeMonthAgo,sum(AmountInDollars) TotalAmountInDollarsThreeMonthAgo, IdGeneric into #T5
			from(
				select Numtran, AmountInDollars, case when @type=1 then S.IdState when @type=2 then t.idgateway when @type=3 then T.idcountry when @type=4 then a.iduserseller end IdGeneric from DashboardForGatewayCountry T WITH (NOLOCK)
				Join Agent A WITH (NOLOCK) on (T.IdAgent=A.IdAgent)
				join  [State] s WITH (NOLOCK) on s.idcountry=18 and a.agentstate=s.statecode
				where T.[Date]>= @ThreeMonthAgoSD and T.[Date]<@ThreeMonthAgoED
						and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))		
						and a.idagentstatus in (select id from @tStatus)		
						and t.idcountry=isnull(@idcountry,t.idcountry)
						and t.idgateway=isnull(@idgateway,t.idgateway)
						and t.idpayer=isnull(@idpayer,t.idpayer)
			) LT
		group by IdGeneric;


		------ Number of transaction Current Month ------------------------

		--#tempM1
		select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		into #tempM1 
		from [Transfer] T with (nolock)
				Join Agent A WITH (NOLOCK) on (T.IdAgent=A.IdAgent)
				join  [State] s WITH (NOLOCK) on s.idcountry=18 and a.agentstate=s.statecode
				join countrycurrency c WITH (NOLOCK) on t.idcountrycurrency=c.idcountrycurrency
				where T.DateOfTransfer>= @CurrentMonthSD and T.DateOfTransfer<@CurrentMonthED
						and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
						--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
						and a.idagentstatus in (select id from @tStatus)
						and c.idcountry=isnull(@idcountry,c.idcountry)
						and t.idgateway=isnull(@idgateway,t.idgateway)
						and t.idpayer=isnull(@idpayer,t.idpayer);
		--#tempM2
		select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull(((fee-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		into #tempM2 
		from TransferClosed T with (nolock)--with (nolock, INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
				Join Agent A WITH (NOLOCK) on (T.IdAgent=A.IdAgent)
				join  [State] s WITH (NOLOCK) on s.idcountry=18 and a.agentstate=s.statecode
				join countrycurrency c WITH (NOLOCK) on t.idcountrycurrency=c.idcountrycurrency
				where T.DateOfTransfer>= @CurrentMonthSD and T.DateOfTransfer<@CurrentMonthED
						and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
						--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
						and a.idagentstatus in (select id from @tStatus)
						and c.idcountry=isnull(@idcountry,c.idcountry)
						and t.idgateway=isnull(@idgateway,t.idgateway)
						and t.idpayer=isnull(@idpayer,t.idpayer);

		--#tempM3
		select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		into #tempM3 
		from [Transfer] T with (nolock)
				Join Agent A WITH (NOLOCK) on (T.IdAgent=A.IdAgent)
				join  state s WITH (NOLOCK) on s.idcountry=18 and a.agentstate=s.statecode
				join countrycurrency c WITH (NOLOCK) on t.idcountrycurrency=c.idcountrycurrency
				left join dbo.TransferNotAllowedResend TA WITH (NOLOCK) on T.IdTransfer=TA.IdTransfer  
				where T.DateStatusChange>= @CurrentMonthSD and T.DateStatusChange<@CurrentMonthED and T.IdStatus in (22,31)
						and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
						--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
						and a.idagentstatus in (select id from @tStatus)
						and c.idcountry=isnull(@idcountry,c.idcountry)
						and t.idgateway=isnull(@idgateway,t.idgateway)
						and t.idpayer=isnull(@idpayer,t.idpayer);

		--#tempM4
		select t.IdCountryCurrency, a.IdAgentCollectType,t.idgateway,t.idpayer,t.idpaymenttype,Round(isnull((((case when TA.IdTransfer is null and T.IdStatus=22 then 0 else Fee end)-agentcommission) + (((ReferenceExRate-ExRate)*AmountInDollars)/ReferenceExRate)),0),2) AmountInDollars, AmountInDollars AmountInDollarsForCommission, S.IdState,c.idcountry,a.iduserseller,[dbo].[RemoveTimeFromDatetime](DATEADD(dd,-(DAY(DateOfTransfer)-1),DateOfTransfer)) DateOfCommission 
		into #tempM4 
		from TransferClosed T WITH (NOLOCK)--with (nolock, INDEX(IX_TransferClosed_IdStatus_DateOfTransfer_DateStatusChange))
				Join Agent A WITH (NOLOCK) on (T.IdAgent=A.IdAgent)
				join  [State] s WITH (NOLOCK) on s.idcountry=18 and a.agentstate=s.statecode
				join countrycurrency c WITH (NOLOCK) on t.idcountrycurrency=c.idcountrycurrency
				left join dbo.TransferNotAllowedResend TA WITH (NOLOCK) on T.IdTransferClosed=TA.IdTransfer  
				where T.DateStatusChange>= @CurrentMonthSD and T.DateStatusChange<@CurrentMonthED and T.IdStatus in (22,31)
						and (@IsAllSeller=1 Or (A.IdUserSeller = @IdUserSeller or A.IdUserSeller in (select IdSeller from #SellerSubordinates)))
						--and (@OnlyActiveAgents=0 Or(A.IdAgentStatus in (1,4)))
						and a.idagentstatus in (select id from @tStatus)
						and c.idcountry=isnull(@idcountry,c.idcountry)
						and t.idgateway=isnull(@idgateway,t.idgateway)
						and t.idpayer=isnull(@idpayer,t.idpayer);



		--acumulado
		Select SUM(NumTran) as TotalCurrentMonth,sum(AmountInDollars) TotalAmountInDollarsCurrentMonth, IdGeneric into #T6
			from(
				select SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
				from #tempM1 T
				left join bankcommission b WITH (NOLOCK) on b.DateOfBankCommission=DateOfCommission and b.active=1
				left join payerconfig x WITH (NOLOCK) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
				left join payerconfigcommission p WITH (NOLOCK) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
				group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
				union all
		
				select SUM(1) as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0))) AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
				from #tempM2 T
				left join bankcommission b WITH (NOLOCK) on b.DateOfBankCommission=DateOfCommission and b.active=1
				left join payerconfig x WITH (NOLOCK) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
				left join payerconfigcommission p WITH (NOLOCK) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
				group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			
				union all
		
				select SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
				from #tempM3 T
				left join bankcommission b WITH (NOLOCK) on b.DateOfBankCommission=DateOfCommission and b.active=1
				left join payerconfig x WITH (NOLOCK) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
				left join payerconfigcommission p WITH (NOLOCK) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
				group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end
			
				union all
		
				select SUM(1)*-1 as NumTran,sum(AmountInDollars-(case when IdAgentCollectType=1 then 0 else isnull(AmountInDollarsForCommission*FactorNew,0) end)-(isnull(CommissionNew,0)))*-1 AmountInDollars, case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end IdGeneric
				from #tempM4 T
				left join bankcommission b WITH (NOLOCK) on b.DateOfBankCommission=DateOfCommission and b.active=1
				left join payerconfig x WITH (NOLOCK) on t.idgateway=x.idgateway and t.idpayer=x.idpayer and t.idpaymenttype=x.idpaymenttype and x.IdCountryCurrency=t.IdCountryCurrency and IdPayerConfig not in (711,807)
				left join payerconfigcommission p WITH (NOLOCK) on p.DateOfpayerconfigCommission=DateOfCommission and x.idpayerconfig=p.idpayerconfig and p.active=1
				group by case when @type=1 then IdState when @type=2 then t.idgateway when @type=3 then idcountry when @type=4 then iduserseller end 
			) LT
		group by IdGeneric;

		create table #T0
		(
			IdGeneric int 
		);

		if (@type=1)
		begin
			insert into #T0
			Select distinct s.IdState as IdGeneric 
			From Agent WITH (NOLOCK)
			join  [State] s WITH (NOLOCK) on s.idcountry=18 and agentstate=s.statecode
			where IdAgentStatus in (select id from @tStatus) And (@IsAllSeller = 1 Or (IdUserSeller = @IdUserSeller or IdUserSeller in (select IdSeller from #SellerSubordinates)));
		end

		if (@type=2)
		begin
			if (isnull(@IdGateway,0)=0)
			begin

				select distinct IdGeneric into #TMPGateway from
				(
					select distinct IdGeneric from #t1
					union all
					select distinct IdGeneric from #t2
					union all
					select distinct IdGeneric from #t3
					union all
					select distinct IdGeneric from #t4
					union all
					select distinct IdGeneric from #t5
					union all
					select distinct IdGeneric from #t6
				)t;

				insert into #T0
				select idgateway as IdGeneric from gateway WITH (NOLOCK) where /*status=1 and */idgateway in 
				(
					select IdGeneric from #TMPGateway
				);
			end
			else
			begin
				insert into #T0
				select idgateway as IdGeneric from gateway WITH (NOLOCK) where /*status=1 and */idgateway = @IdGateway;
			end
		end

		if (@type=3)
		begin
			if (isnull(@IdCountry,0)=0)
			begin

				select distinct IdGeneric into #TMPCountry from
				(
					select distinct IdGeneric from #t1
					union all
					select distinct IdGeneric from #t2
					union all
					select distinct IdGeneric from #t3
					union all
					select distinct IdGeneric from #t4
					union all
					select distinct IdGeneric from #t5
					union all
					select distinct IdGeneric from #t6
				)t;

				insert into #T0
				select idcountry as IdGeneric from country WITH (NOLOCK) where idcountry in
				(
					select IdGeneric from #TMPCountry
				);
			end
			else
			begin
				insert into #T0
				select idcountry as IdGeneric from country WITH (NOLOCK) where idcountry=@IdCountry;
			end
		end

		if (@type=4)
		begin
			if (isnull(@IdUserSeller,0)=0)
			begin
				if (isnull(@IsAllSeller,0)=0)
				begin
					insert into #T0
						select IdSeller from #SellerSubordinates a
						join users u WITH (NOLOCK) on a.IdSeller=u.iduser
						where  u.idgenericstatus in (1, 3);
						--where  u.idgenericstatus=1
				end
				else
				begin
					insert into #T0
					Select distinct a.iduserSeller as IdGeneric 
					From Agent a WITH (NOLOCK)
					join users u WITH (NOLOCK) on a.iduserSeller=u.iduser
					where  u.idgenericstatus in (1, 3) or iduserseller in (4271);
					--where  u.idgenericstatus=1 or iduserseller in (4271) 
				end
			end
			else
			begin    
				insert into #T0
				Select distinct a.iduserSeller as IdGeneric 
				From Agent a WITH (NOLOCK)
				join users u WITH (NOLOCK) on a.iduserSeller=u.iduser
				where  u.idgenericstatus in (1, 3) and iduserSeller=@IdUserSeller;
				--where  u.idgenericstatus=1 and iduserSeller=@IdUserSeller
			end
		end

		Create Table #T7
		(
		IdGeneric int,
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

		Insert #T7 (IdGeneric,TotalThreeMonthAgo,TotalAmountInDollarsThreeMonthAgo,TotalTwoMonthAgo,TotalAmountInDollarsTwoMonthAgo,TotalOneMonthAgo,TotalAmountInDollarsOneMonthAgo,
		TotalCurrentMonth,TotalAmountInDollarsCurrentMonth,TotalWeekAgo,TotalToday)
		Select isnull(A.IdGeneric,isnull(B.IdGeneric,isnull(C.IdGeneric,isnull(D.IdGeneric,isnull(E.IdGeneric,isnull(F.IdGeneric,isnull(G.IdGeneric,NULL))))))), --#1
		--Select A.IdGeneric,
		TotalThreeMonthAgo,TotalAmountInDollarsThreeMonthAgo,TotalTwoMonthAgo,TotalAmountInDollarsTwoMonthAgo,TotalOneMonthAgo,TotalAmountInDollarsOneMonthAgo,
		TotalCurrentMonth,TotalAmountInDollarsCurrentMonth,TotalWeeksAgo,TotalToday From #T0 A
		Full JOIN #T1 B on (A.IdGeneric=B.IdGeneric)
		Full join #T2 C on (A.IdGeneric=C.IdGeneric)
		Full Join #T3 D on (A.IdGeneric=D.IdGeneric)
		Full Join #T4 E on (A.IdGeneric=E.IdGeneric)
		Full Join #T5 F on (A.IdGeneric=F.IdGeneric)
		Full Join #T6 G on (A.IdGeneric=G.IdGeneric);

		Update #T7 set TotalThreeMonthAgo=0 where TotalThreeMonthAgo is null;
		Update #T7 set TotalTwoMonthAgo=0 where TotalTwoMonthAgo is null;
		Update #T7 set TotalOneMonthAgo=0 where TotalOneMonthAgo is null;
		Update #T7 set TotalCurrentMonth=0 where TotalCurrentMonth is null;
		Update #T7 set TotalWeekAgo=0 where TotalWeekAgo is null;
		Update #T7 set TotalToday=0 where TotalToday is null;
		--nuevo
		Update #T7 set TotalAmountInDollarsOneMonthAgo=0 where TotalAmountInDollarsOneMonthAgo is null;
		Update #T7 set TotalAmountInDollarsTwoMonthAgo=0 where TotalAmountInDollarsTwoMonthAgo is null;
		Update #T7 set TotalAmountInDollarsThreeMonthAgo=0 where TotalAmountInDollarsThreeMonthAgo is null;
		Update #T7 set TotalAmountInDollarsCurrentMonth=0 where TotalAmountInDollarsCurrentMonth is null;

		Update #T7 set TransferTarget=((TotalThreeMonthAgo+TotalTwoMonthAgo+TotalOneMonthAgo)/3)*(1+(@Increment/100));
		Update #T7 set TotalStatus=TotalToday-TotalWeekAgo;
		Update #T7 set TransfersStatusToTarget=TotalCurrentMonth-((@DayOfMonth*TransferTarget)/@TotalDaysOfCurrentMonth);
		Update #T7 set TargetColor=case  when TransfersStatusToTarget>0 then 1 When  TransfersStatusToTarget<0 then 2 When TransfersStatusToTarget=0 Then 0 End;
		Update #T7 set TotalColor=case  when TotalStatus>0 then 1 When  TotalStatus<0 then 2 When TotalStatus=0 Then 0 End;

		Select     
			IdGeneric,
			case when @type=1 then statecode when @type=2 then gatewayname when @type=3 then CountryName when @type=4 then UserName end GenricName,
    
			TotalThreeMonthAgo,
			round(case TotalThreeMonthAgo when 0 then 0 else TotalAmountInDollarsThreeMonthAgo/case when TotalThreeMonthAgo>0 then 1* TotalThreeMonthAgo else -1* TotalThreeMonthAgo end  end,2) AverageAmountInDollarsThreeMonthAgo,
        
			TotalTwoMonthAgo,
			round(case TotalTwoMonthAgo when 0 then 0 else TotalAmountInDollarsTwoMonthAgo/case when TotalTwoMonthAgo >0 then 1*  TotalTwoMonthAgo else -1*  TotalTwoMonthAgo end  end,2) AverageAmountInDollarsTwoMonthAgo,
        
			TotalOneMonthAgo,
			round(case TotalOneMonthAgo when 0 then 0 else TotalAmountInDollarsOneMonthAgo/case when TotalOneMonthAgo > 0 then 1* TotalOneMonthAgo else -1* TotalOneMonthAgo end  end,2) AverageAmountInDollarsOneMonthAgo,
        
			TotalCurrentMonth,
			round(case TotalCurrentMonth when 0 then 0 else TotalAmountInDollarsCurrentMonth/case when TotalCurrentMonth > 0 then 1* TotalCurrentMonth else -1* TotalCurrentMonth end  end,2) TotalAmountInDollarsCurrentMonth,
        
			TransfersStatusToTarget,
			ROUND(TransferTarget,0) TransferTarget,
			TargetColor,TotalWeekAgo,
			TotalToday,
			TotalColor,
			TotalStatus,
			isnull(@Country,'') Country, 
			isnull(@Gateway,'') Gateway, 
			isnull(@Payer,'') Payer
		from #T7 t
		left join [State] s WITH (NOLOCK) on s.idstate=t.IdGeneric
		left join gateway g WITH (NOLOCK) on g.IdGateway=t.IdGeneric
		left join country c WITH (NOLOCK) on c.IdCountry=t.IdGeneric
		left join users u WITH (NOLOCK) on u.iduser=t.IdGeneric
		--where   (TotalThreeMonthAgo>0 or TotalTwoMonthAgo>0 or TotalOneMonthAgo>0 or TotalCurrentMonth>0 or TotalWeekAgo>0 or TotalToday>0 )
		Order by  GenricName;
		;

		/*
		select distinct idgeneric from
		(
		select distinct idgeneric from #t1
		union all
		select distinct idgeneric from #t2
		union all
		select distinct idgeneric from #t3
		union all
		select distinct idgeneric from #t4
		union all
		select distinct idgeneric from #t5
		union all
		select distinct idgeneric from #t6
		) t

		select distinct idgeneric from #t0

		*/
	END TRY
	BEGIN CATCH
		DECLARE 
		   @ErrorLine nvarchar(50),
		   @ErrorMessage nvarchar(max);
	
		SELECT 
		   @ErrorLine = CONVERT(varchar(20), ERROR_LINE()), 
		   @ErrorMessage = ERROR_MESSAGE();
	
		INSERT INTO dbo.ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[dbo].[st_DashboardWithFilter]',Getdate(),'ErrorLine:'+@ErrorLine+',ErrorMessage:'+@ErrorMessage);

	END CATCH
END
