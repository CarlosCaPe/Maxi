CREATE PROCEDURE [Soporte].[st_NotificationErrorInServicesCheks]
AS
/********************************************************************
<Author>jmmolina</Author>
<app>MaxiSupport</app>
<Description>Proceso de notificacion para fallas en cheques </Description>

<ChangeLog>
</ChangeLog>
********************************************************************/   
BEGIN

	DECLARE @Schedule TABLE (Code varchar(150), IsProcess Bit)
	DECLARE @Result TABLE (ProcessSource VARCHAR(150), machineName VARCHAR(100), severity VARCHAR(50), logdate DATETIME, win32ThreadId VARCHAR(50), [message] VARCHAR(MAX), ErrorTime int)
	DECLARE @CurrentTime varchar(5), @LastTime varchar(5), @BanK varchar(150), @Filter varchar(25), @tableHTML nvarchar(max)
	DECLARE @WeekDate smallint
	DECLARE @CurrentDate Datetime, @LastDate Datetime
	DECLARE @Time Int
	DECLARE @EmailProfile nvarchar(max)
        
	SET @CurrentTime = LEFT(CONVERT(VARCHAR(5), DATEADD(MINUTE, -10, GETDATE()), 108), 5)
	SET @LastTime = LEFT(CONVERT(VARCHAR(5), DATEADD(MINUTE, -20, GETDATE()), 108), 5)
	SET @WeekDate = DATEPART(WEEKDAY, getdate())
	SET @CurrentDate = DATEADD(MINUTE, -11, GETDATE())
	SET @LastDate = DATEADD(MINUTE, -21, GETDATE())
	SET @EmailProfile = (SELECT Value FROM GLOBALATTRIBUTES WITH(NOLOCK) WHERE Name='EmailProfiler')
    
    INSERT INTO @Schedule
    SELECT Code, IsProcess = 0
      FROM Services.ServiceSchedules WITH(NOLOCK)
     WHERE 1 = 1
       AND Code IN ('SOUTHSIDENVSEND', 'SOUTHSIDESEND', 'FIRSTMIDWESTSEND', 'BANKOFTEXASNVSEND', 'BANKOFTEXASSEND')
       AND ([Time] = @CurrentTime OR [Time] = @LastTime)
       AND [DayOfWeek] = @WeekDate 
     ORDER BY [Time], Code, [DayOfWeek]
        
    SET @tableHTML = ''
    WHILE EXISTS(SELECT 1 FROM @Schedule WHERE 1 = 1 AND IsProcess = 0)
    BEGIN
         SET @BanK = (SELECT TOP 1 Code FROM @Schedule WHERE 1 = 1 AND IsProcess = 0)
    
    	 INSERT INTO @Result
         SELECT @BanK, machineName, severity, logdate, win32ThreadId, [message], ErrorTime = CONVERT(INT, REPLACE(LEFT(CONVERT(VARCHAR(5), logdate, 108), 5), ':', ''))
          FROM Services.LogServices AS ls WITH(NOLOCK)
          WHERE 1 = 1
          AND (logdate >= @CurrentDate OR logdate >= @LastDate)
          AND severity = 'Error'
          AND [message] Like '%' + LEFT(@BanK, 4) + '%'
    	  AND NOT EXISTS(SELECT 1 FROM @Result AS R WHERE 1 = 1 AND R.machineName = ls.machineName AND R.win32ThreadId = ls.win32ThreadId AND R.logdate = ls.logdate)
    
         UPDATE @Schedule SET IsProcess = 1 WHERE 1 = 1 AND Code = @BanK
    	 
    	 SET @Time = CONVERT(INT, REPLACE(@CurrentTime, ':', ''	))
    
    	 DELETE FROM @Result WHERE 1 = 1 AND ErrorTime < @Time
    
    END
        
    IF EXISTS(SELECT 1 FROM @Result WHERE 1 = 1)
    BEGIN
		 SELECT @tableHTML = N'
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
				</style>
				<table><thead><tr><th>Machine Name</th><th>Severity</th><th>Log Date</th><th>Win32 Thread Id</th><th>Message</th><thead><tbody>
				' + CAST((
							SELECT machineName AS 'td', '', severity AS 'td', '', logdate AS 'td', '', win32ThreadId AS 'td', '', [message] AS 'td'
							 FROM @Result
							 WHERE 1 = 1
     						 FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)) + '</tbody></table>'
     
          --SET @tableHTML = '<table><thead><tr><th>Machine Name</th><th>Severity</th><th>Log Date</th><th>Win32 Thread Id</th><th>Message</th><thead><tbody>' + @tableHTML + '</tbody></table>'
     
          EXEC msdb.dbo.sp_send_dbmail 
			   @profile_name=@EmailProfile,
               @recipients='jmolina@boz.mx;soportemaxi@boz.mx;msalinas@boz.mx',
               @subject='Fail process of Checks',
               @body=@TableHTML,
               @body_format = 'HTML'
     END

END