--EXEC Soporte.st_MonitoringSessionByApplication
CREATE PROCEDURE [Soporte].[st_MonitoringSessionByApplication]
AS
BEGIN
SET NOCOUNT ON;
	DECLARE @SpidValue varchar(50);
	DECLARE @ProgramName VARCHAR(1000);
	DECLARE @DBName NVARCHAR(50);
	DECLARE @XmlFormat nvarchar(max)
	DECLARE @XmlFormatTemp nvarchar(max)
	DECLARE @Subject varchar(150)
	DECLARE @EmailProfile nvarchar(max)
	SELECT @EmailProfile = Value FROM GLOBALATTRIBUTES WITH(NOLOCK) WHERE Name='EmailProfiler'  

		SELECT @XmlFormat = N'
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
			</style>'

	IF OBJECT_ID('tempdb..#temp_sp_who2') IS NOT NULL DROP TABLE #temp_sp_who2;
	CREATE TABLE #temp_sp_who2
		(
		  SPID INT,
		  [Status] VARCHAR(1000) NULL,
		  [Login] SYSNAME NULL,
		  HostName SYSNAME NULL,
		  BlkBy SYSNAME NULL,
		  DBName SYSNAME NULL,
		  Command VARCHAR(1000) NULL,
		  CPUTime INT NULL,
		  DiskIO INT NULL,
		  LastBatch VARCHAR(1000) NULL,
		  ProgramName VARCHAR(1000) NULL,
		  SPID2 INT
		  , rEQUESTID INT NULL --comment out for SQL 2000 databases
		);

	IF OBJECT_ID('tempdb..#Inputbuffer') IS NOT NULL DROP TABLE #Inputbuffer;
	CREATE TABLE #Inputbuffer(
	EventType NVARCHAR(30) NULL,
	[Parameters] INT NULL,
	EventInfo NVARCHAR(max) NULL
	);

	IF OBJECT_ID('tempdb..#InputbufferDetail') IS NOT NULL DROP TABLE #InputbufferDetail;
	CREATE TABLE #InputbufferDetail(
	DBName NVARCHAR(50),
	EventType NVARCHAR(30) NULL,
	[Parameters] INT NULL,
	EventInfo NVARCHAR(max) NULL,
	ProgramName VARCHAR(1000) NULL
	);

	INSERT  INTO #temp_sp_who2
	EXEC sp_who2;

	DELETE
	FROM    #temp_sp_who2
	WHERE   (DBName != 'MAXI'
	  AND   DBName != 'MAXILOG')

	WHILE EXISTS(SELECT 1 FROM #temp_sp_who2)
	BEGIN
		SELECT top 1 
			   @SpidValue = CONVERT(VARCHAR(10), SPID), 
			   @ProgramName = ProgramName 
		  FROM #temp_sp_who2;

		BEGIN TRY
			TRUNCATE TABLE #Inputbuffer
			INSERT #Inputbuffer
			EXEC('DBCC INPUTBUFFER(' + @SpidValue + ')');
	
			INSERT INTO #InputbufferDetail(DBName, EventType, [Parameters], EventInfo, ProgramName)
			SELECT @DBName, ib.*, @ProgramName 
			FROM #Inputbuffer as ib
		END TRY
		BEGIN CATCH
			PRINT 'ERROR YA NO EXISTE EL SPID. Erro: ' + CONVERT(VARCHAR(max), ERROR_MESSAGE())
		END CATCH
		DELETE FROM #temp_sp_who2 WHERE SPID = CONVERT(INT, @SpidValue);
	END

	IF EXISTS(
	SELECT ProgramName, COUNT(1)
	FROM #InputbufferDetail
	GROUP BY ProgramName
	HAVING COUNT(1) > 199
	)
	BEGIN
		SELECT @XmlFormatTemp = N' <h3>Conexiones existente por aplicación</h3>
			<table><theader><tr><th>Aplicación</th><th>Total</th></tr></theader><tbody>' +
		CAST((
		SELECT DBName AS 'td', '', ProgramName AS 'td', '', COUNT(1) AS 'td'
		FROM #InputbufferDetail
		GROUP BY DBName, ProgramName
		FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX))
		+ '</tbody></table>';

		SELECT @XmlFormatTemp += N' <h3>Detalle de conexiones existente por aplicación</h3>
			<table><theader><tr><th>Aplicación</th><th>Script</th><th>Total</th></tr></theader><tbody>' +
		CAST((
		SELECT DBName AS 'td', '', ProgramName AS 'td', '', EventInfo AS 'td', '', COUNT(1) AS 'td'
		FROM #InputbufferDetail
		GROUP BY DBName, ProgramName, EventInfo
		FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX))
		+ '</tbody></table>';

		IF LEN(CONVERT(VARCHAR, @XmlFormatTemp)) > 0
		BEGIN
			SET @XmlFormat += @XmlFormatTemp;
			SET @Subject = 'Conexiones por aplicación del servidor ' + @@SERVERNAME

			EXEC msdb.dbo.sp_send_dbmail 
			@profile_name=@EmailProfile,
			@recipients='jmolina@boz.mx;jhornedo@boz.mx',
			@subject=@Subject,
			@body=@XmlFormat,
			@body_format = 'HTML'
		END
	END
END