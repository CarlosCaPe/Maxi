CREATE PROCEDURE [Soporte].[st_GetSummaryTransferPerWeek]
AS
BEGIN
	DECLARE @Query nvarchar(max);
	DECLARE @Status varchar(max);
	DECLARE @AgentState varchar(max);
	DECLARE @StatusH varchar(max);
	DECLARE @AgentStateH varchar(max);

	DECLARE @SumaryPerDayWeek varchar(max);
	DECLARE @SumaryPerDayWeekAndState varchar(max);

	DECLARE @SumaryPerDayWeekBody varchar(max);
	DECLARE @SumaryPerDayWeekAndStateBody varchar(max);

	DECLARE @XmlFormat nvarchar(max);

	DECLARE @StatusStuff TABLE (id int, StatusName varchar(255), AgentState varchar(255));
	DECLARE @TransferCancelRechazado TABLE ([Week] int, DateOfTransfer date, invalid int);

	DECLARE @today DATETIME,
            @EndDate DATETIME,
		    @LastDateTransfer DATE,
			@SumaryTransferPerDay nvarchar(max);

	IF OBJECT_ID('tempdb..#TransferPerAgentAndStatus') IS NOT NULL DROP TABLE #TransferPerAgentAndStatus;
	CREATE TABLE #TransferPerAgentAndStatus (DayYear int, DayWeek varchar(30), AgentState varchar(255), StatusName varchar(255), Transfers int);

	IF OBJECT_ID('tempdb..#TransfersPerDay') IS NOT NULL DROP TABLE #TransfersPerDay;
	CREATE TABLE #TransfersPerDay ([Week] int, [DayName] varchar(10), [Day] int, DateOfTransfer date, Total int);

	SET @today = DATEADD(DAY, -7, CONVERT(DATETIME, CAST(DATEADD(DD, -(DATEPART(DW, GETDATE() )-1), GETDATE()) AS DATE)))
    SET @EndDate = CONVERT(DATETIME, CAST(DATEADD(dd, 7-(DATEPART(dw, GETDATE())), GETDATE()) AS DATE))

	--Se obtienen las transferencias canceladas y rechazadas por dia
	INSERT INTO @TransferCancelRechazado([Week], DateOfTransfer, invalid)
	SELECT [WEEK] = DATEPART(WEEK, DateTransfer), DateTransfer, SUM(invalid) 
	  FROM (
	        SELECT DateTransfer = CAST(DateStatusChange AS DATE), invalid = count(1)
	        FROM [Transfer] WITH (NOLOCK) 
	        WHERE 1 = 1
	        AND DateStatusChange >= @today
	        AND IdStatus IN (22,31) 
	        GROUP BY CAST(DateStatusChange AS DATE)
	        UNION 
	        SELECT CAST(DateStatusChange AS DATE), invalid = count(1) 
	        FROM [TransferClosed] WITH (NOLOCK) 
	        WHERE 1 = 1
	        AND DateStatusChange >= @today
	        AND IdStatus IN (22,31) 
	        GROUP BY CAST(DateStatusChange AS DATE)
	) AS t
	GROUP BY DateTransfer, DATEPART(WEEK, DateTransfer);

	--Se obtienen todas las transferencias por dia
	INSERT INTO #TransfersPerDay([Week], [DayName], [Day], DateOfTransfer, Total)
	SELECT [WEEK] = DATEPART(WEEK, DayTransfer), DATENAME(WEEKDAY, DayTransfer), [DAY] = DATEPART(DAY, DateOfTransfer), DayTransfer, Total = SUM(total) - SUM(ISNULL(invalid, 0))
	  FROM (
	         SELECT DayTransfer = CAST(t.DateOfTransfer AS DATE),
	         total= count(1)
	         FROM [Transfer] AS t WITH (NOLOCK) 
	         WHERE 
	         t.DateOfTransfer >= @today
	         GROUP BY CAST(t.DateOfTransfer AS DATE)
	         UNION 
	         SELECT DayTransfer = CAST(t.DateOfTransfer AS DATE),
	         total= count(1)
	         FROM [TransferClosed] AS t WITH (NOLOCK) 
	         WHERE 
	         t.DateOfTransfer >= @today
	         GROUP BY CAST(t.DateOfTransfer AS DATE)
	) AS T
	LEFT OUTER JOIN @TransferCancelRechazado AS tcr ON T.DayTransfer = tcr.DateOfTransfer
	GROUP BY DayTransfer, DATEPART(WEEK, DayTransfer), DATEPART(DAY, DateOfTransfer)
	ORDER BY DayTransfer

	SET @LastDateTransfer = (SELECT DATEADD(DAY, 1, MAX(DateOfTransfer)) FROM #TransfersPerDay);
	WHILE (@LastDateTransfer <= @EndDate)
	BEGIN
		INSERT INTO #TransfersPerDay([Week], DateOfTransfer, Total) VALUES(DATEPART(WEEK, @LastDateTransfer), @LastDateTransfer, 0);
		SET @LastDateTransfer = DATEADD(DAY, 1, @LastDateTransfer);
	END

	INSERT INTO #TransferPerAgentAndStatus(DayYear, DayWeek, AgentState, StatusName, Transfers)
	SELECT DayYear, DayWeek, AgentState, StatusName, Transfers = SUM(Transfers)
	FROM (
			SELECT DayYear = DATEPART(DAYOFYEAR, ISNULL(DateStatusChange, DateOfTransfer)), DayWeek = DATENAME(DW, ISNULL(DateStatusChange, DateOfTransfer)), a.AgentState, s.StatusName, Transfers = COUNT(t.IdTransfer)
			  FROM dbo.[Transfer] as t WITH(NOLOCK)
			 INNER JOIN dbo.[Status] AS s WITH(NOLOCK) ON t.IdStatus = s.IdStatus
			 INNER JOIN dbo.Agent As a WITH(NOLOCK) ON t.IdAgent = a.IdAgent
			 WHERE 1 = 1
			   AND ((CAST(t.DateOfTransfer AS DATE) BETWEEN CAST(GETDATE()-8 AS DATE) AND CAST(GETDATE()-1 AS DATE))
				 OR (CAST(t.DateStatusChange AS DATE) BETWEEN CAST(GETDATE()-8 AS DATE) AND CAST(GETDATE()-1 AS DATE)))
			 GROUP BY DATEPART(DAYOFYEAR, ISNULL(DateStatusChange, DateOfTransfer)),  DATENAME(DW, ISNULL(DateStatusChange, DateOfTransfer)), a.AgentState, s.StatusName
			UNION
			SELECT DayYear = DATEPART(DAYOFYEAR, ISNULL(DateStatusChange, DateOfTransfer)), DayWeek = DATENAME(DW, ISNULL(DateStatusChange, DateOfTransfer)), a.AgentState, s.StatusName, Transfers = COUNT(t.IdTransferClosed)
			  FROM dbo.[TransferClosed] as t WITH(NOLOCK)
			 INNER JOIN dbo.[Status] AS s WITH(NOLOCK) ON t.IdStatus = s.IdStatus
			 INNER JOIN dbo.Agent As a WITH(NOLOCK) ON t.IdAgent = a.IdAgent
			 WHERE 1 = 1
			   --AND (CAST(t.DateOfTransfer AS DATE) >= CAST(GETDATE()-7 AS DATE) AND (CAST(t.DateOfTransfer AS DATE) < CAST(GETDATE()-1 AS DATE)))
			   AND ((CAST(t.DateOfTransfer AS DATE) BETWEEN CAST(GETDATE()-8 AS DATE) AND CAST(GETDATE()-1 AS DATE))
				 OR (CAST(t.DateStatusChange AS DATE) BETWEEN CAST(GETDATE()-8 AS DATE) AND CAST(GETDATE()-1 AS DATE)))
			 GROUP BY DATEPART(DAYOFYEAR, ISNULL(DateStatusChange, DateOfTransfer)), DATENAME(DW, ISNULL(DateStatusChange, DateOfTransfer)), a.AgentState, s.StatusName
	 ) AS t
	 GROUP BY DayYear, DayWeek, AgentState, StatusName;

	INSERT INTO @StatusStuff
	SELECT DISTINCT 1, StatusName, AgentState
	FROM #TransferPerAgentAndStatus AS a;

	SET @Status = (SELECT DISTINCT STUFF( (SELECT DISTINCT ',[' + StatusName + ']' FROM @StatusStuff As b where a.id = b.id FOR XML PATH('')), 1, 1, '' ) FROM @StatusStuff AS a);
	SET @AgentState = (SELECT DISTINCT STUFF( (SELECT DISTINCT ',[' + AgentState + ']' FROM @StatusStuff As b where a.id = b.id FOR XML PATH('')), 1, 1, '' ) FROM @StatusStuff AS a);

	SET @StatusH = (SELECT DISTINCT STUFF( (SELECT DISTINCT ',  FORMAT(ISNULL([' + StatusName + '], 0), ''##,###.####'') AS ''td'', '''''  FROM @StatusStuff As b where a.id = b.id FOR XML PATH('')), 1, 1, '' ) FROM @StatusStuff AS a);
	SET @AgentStateH = (SELECT DISTINCT STUFF( (SELECT DISTINCT ', FORMAT(ISNULL([' + AgentState + '], 0), ''##,###.####'') AS ''td'', ''''' FROM @StatusStuff As b where a.id = b.id FOR XML PATH('')), 1, 1, '' ) FROM @StatusStuff AS a);

	SET @Query = 'SELECT @SumaryPerDayWeek = CAST((
	SELECT DayWeek as ''td'', '''', FORMAT(ISNULL(Total, 0), ''##,###.####'') As ''td'', '''', ' + @StatusH + ' FROM (
	SELECT DayYear, DayWeek, Total, ' + @Status + '
	FROM (
			SELECT DayYear, DayWeek, StatusName, Transfers = SUM(Transfers), Total = SUM(SUM(Transfers)) over(PARTITION BY DayYear, DayWeek)
				FROM #TransferPerAgentAndStatus
			GROUP BY DayYear, DayWeek, StatusName
	) As t
	PIVOT (SUM(Transfers)
	FOR StatusName IN (' + @Status + ')) As PivotData
	UNION
	SELECT DayYear = 600, DayWeek = ''Total'', Total, ' + @Status + '
	FROM (
			SELECT StatusName, Transfers = SUM(Transfers), Total = SUM(SUM(Transfers)) over()
				FROM #TransferPerAgentAndStatus
			GROUP BY StatusName
	) As t
	PIVOT (SUM(Transfers)
	FOR StatusName IN (' + @Status + ')) As PivotData
	) AS t
	ORDER BY DayYear
	FOR XML PATH(''tr''))
	AS VARCHAR(MAX))';

	EXEC sp_executeSQL @Query, N'@SumaryPerDayWeek Varchar(max) OUTPUT', @SumaryPerDayWeek = @SumaryPerDayWeek OUTPUT;

	SET @Query = 'SELECT @SumaryPerDayWeekAndState = CAST((
	SELECT DayWeek As ''td'', '''', FORMAT(ISNULL(Total, 0), ''##,###.####'') AS ''td'', '''', ' + @AgentStateH + '
	  FROM (
			SELECT DayYear, DayWeek, Total, ' + @AgentState + '
			  FROM (
					 SELECT DayYear, DayWeek, AgentState, Transfers = SUM(Transfers), Total = SUM(SUM(Transfers)) over(PARTITION BY DayYear, DayWeek)
					   FROM #TransferPerAgentAndStatus
					  GROUP BY DayYear, DayWeek, AgentState
			  ) As t
			  PIVOT (SUM(Transfers)
			  FOR AgentState IN (' + @AgentState + ')) As PivotData
			UNION
			SELECT DayYear = 600, DayWeek = ''Total'', Total, ' + @AgentState + '
			  FROM (
					 SELECT AgentState, Transfers = SUM(Transfers), Total = SUM(SUM(Transfers)) over()
					   FROM #TransferPerAgentAndStatus
					  GROUP BY AgentState
			  ) As t
			PIVOT (SUM(Transfers) FOR  AgentState IN (' + @AgentState + ')) AS pivotData
		   ) AS t
	   ORDER BY DayYear ASC
		  FOR XML PATH(''tr''))
		  AS VARCHAR(MAX))';

	EXEC sp_executeSQL @Query, N'@SumaryPerDayWeekAndState Varchar(max) OUTPUT', @SumaryPerDayWeekAndState = @SumaryPerDayWeekAndState OUTPUT;

	IF (@SumaryPerDayWeek IS NOT NULL AND LEN(@SumaryPerDayWeek) > 1)
	BEGIN
		 SET @SumaryPerDayWeekBody = '<table><theader><tr><th>DayWeek</th><th>Total per week</th>' + REPLACE(REPLACE(REPLACE(@Status, '[', '<th>'), ']', '</th>'), ',', '') + '</tr></theader><tbody>' + @SumaryPerDayWeek + '</tbody></table>';
	END

	IF (@SumaryPerDayWeekAndState IS NOT NULL AND LEN(@SumaryPerDayWeekAndState) > 1)
	BEGIN
		 SET @SumaryPerDayWeekAndStateBody = '<table><theader><tr><th>DayWeek</th><th>Total per week</th>' +  REPLACE(REPLACE(REPLACE(@AgentState, '[', '<th>'), ']', '</th>'), ',', '') + '</tr></theader><tbody>' + @SumaryPerDayWeekAndState + '</tbody></table>';
	END

	SET @SumaryTransferPerDay = (
	SELECT '<table><theader><tr><th>[Week]</th><th>[Sunday]</th><th>[Monday]</th><th>[Tuesday]</th><th>[Wednesday]</th><th>[Thursday]</th><th>[Friday]</th><th>[Saturday]</th></tr></theader><tbody>' +
	       CAST((
	             SELECT [Week] AS 'td', '',   FORMAT(ISNULL([Sunday], 0), '##,###.####') AS 'td', '',  FORMAT(ISNULL([Monday], 0), '##,###.####') AS 'td', '',  FORMAT(ISNULL([Tuesday], 0), '##,###.####') AS 'td', '',  FORMAT(ISNULL([Wednesday], 0), '##,###.####') AS 'td', '',  FORMAT(ISNULL([Thursday], 0), '##,###.####') AS 'td', '',  FORMAT(ISNULL([Friday], 0), '##,###.####') AS 'td', '',  FORMAT(ISNULL([Saturday], 0), '##,###.####') AS 'td', ''
	               FROM (
	                     SELECT [Week], [DayName], Total
	                       FROM #TransfersPerDay
	                    ) AS t
	                PIVOT (SUM(Total) FOR [DayName] IN ([Sunday],[Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday])) as pivotData
	                ORDER BY [Week]
	                  FOR XML PATH('tr')
	             ) AS NVARCHAR(MAX)
	          ) + '</tbody></table>');

	SET @XmlFormat = N'
			<style>
			table {
				font-family: arial, sans-serif;
				border-collapse: collapse;
				border: 1px solid #0101DF;
				width: 100%;
			}

			th {
				background-color: #0101DF;
				color: #FFFFFF;
			}

			td, th {
				text-align: left;
				padding: 8px;
			}

			tr:nth-child(even) {
				background-color: #EFFBFB;
			}
			</style>' + 
			'<h3> Resumen de envíos por dia.</h3>' + @SumaryTransferPerDay +
			IIF(LEN(@SumaryPerDayWeekBody) > 1, '<h3>Resumen de moviemientos en envíos por estatus</h3>', '') + @SumaryPerDayWeekBody + 
			IIF(LEN(@SumaryPerDayWeekAndStateBody) > 1, '<h3>Resumen de movimientos en envíos por estado</h3>', '') + @SumaryPerDayWeekAndStateBody;

		IF LEN(CONVERT(VARCHAR, @XmlFormat)) > 0
		BEGIN
			DECLARE @EmailProfile nvarchar(max)
			SELECT @EmailProfile = Value FROM GLOBALATTRIBUTES WITH(NOLOCK) WHERE Name='EmailProfiler'  
			DECLARE @Subject varchar(max)
			SET @Subject = 'Resumen de envíos y movimientos: ' + @@SERVERNAME
			EXEC msdb.dbo.sp_send_dbmail 
			@profile_name=@EmailProfile,
			@recipients='jmolina@boz.mx;azavala@boz.mx;soportemaxi@boz.mx;jhornedo@boz.mx;josesoto@boz.mx;fsuarez@boz.mx',
			@subject=@Subject,
			@body=@XmlFormat,
			@body_format = 'HTML';
		END
	IF OBJECT_ID('tempdb..#TransferPerAgentAndStatus') IS NOT NULL DROP TABLE #TransferPerAgentAndStatus;
	IF OBJECT_ID('tempdb..#TransfersPerDay') IS NOT NULL DROP TABLE #TransfersPerDay;

END