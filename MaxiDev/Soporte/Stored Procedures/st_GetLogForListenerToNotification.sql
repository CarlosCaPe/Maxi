CREATE PROCEDURE [Soporte].[st_GetLogForListenerToNotification]

AS
/********************************************************************
<Author>jmmolina</Author>
<app>MaxiSupport</app>
<Description>Proceso de notificaciones de Errores en procedimientos alanecenado</Description>

<ChangeLog>
</ChangeLog>
********************************************************************/                                                                        
BEGIN

	IF (SELECT CONVERT(BIT, Value) FROM dbo.GlobalAttributes WITH(NOLOCK) WHERE 1 = 1 AND Name = 'SendErrorReportDB') = 0 --#1
		RETURN

	DECLARE @XmlFormat nvarchar(max)
	DECLARE @Subject varchar(150)
	DECLARE @FilterDate datetime = DATEADD(MINUTE, -20, GETDATE()) --DATEADD(MINUTE, -20, DATEADD(DAY, -0, GETDATE()) )
	DECLARE @EmailProfile nvarchar(max)
	SELECT @EmailProfile = Value FROM GLOBALATTRIBUTES WITH(NOLOCK) WHERE Name='EmailProfiler'  

	SELECT @XmlFormat = --N' <h3>Resumen de errores en ErrorLogForStoredProcedure y LogForListener</h3>
		N'
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
		<br/><br/> <h3>Resumen de los ultimos 20 minutos de errores en las aplicaciones</h3>' +
		N'<br/><br/> <table id="logforlistener"><theader><tr><th>Proyect</th><th>ServerDatetime</th><th>[Message]</th><th>StackTrace</th><th>ExceptionMessage</th><th>MethodsParams</th></tr></theader><tbody>' + 
		CAST((
			SELECT Proyect AS 'td', '', ServerDatetime AS 'td', '', [Message] AS 'td', '', StackTrace AS 'td', '', ExceptionMessage AS 'td', '', ISNULL(MethodsParams, '') AS 'td'
			  FROM dbo.LogForListener As lfl WITH(NOLOCK)
			 WHERE 1 = 1
			   AND [Type] = 'Error'
			   AND ServerDatetime >= @FilterDate --CONVERT(DATETIME, CAST(GETDATE() AS DATE))
			   AND [Message] != 'Error in Authentication.ValidateUserSession'
			 ORDER BY IdLog DESC
					FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
			) + '</tbody></table>'

		/*<table><theader><tr><th>Log</th><th>Total Error</th></tr></theader><tbody>' +
		CAST((
			SELECT Label AS 'td', '', TotalError AS 'td'
			FROM (
			SELECT Label = 'Total Error Log', TotalError = COUNT(1)
			FROM dbo.ErrorLogForStoreProcedure with(nolock)
			WHERE 1 = 1
			AND ErrorDate >= CONVERT(DATETIME, CAST(DATEADD(DAY, -0, GETDATE()) AS DATE))
			UNION
			SELECT Label = 'Total Log For Listener', TotalError = COUNT(1)
			FROM dbo.LogForListener with(nolock)
			WHERE 1 = 1
			AND ServerDatetime >= CONVERT(DATETIME, CAST(DATEADD(DAY, -0, GETDATE()) AS DATE))
			AND [Type] = 'Error'
			) As t
			FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
		) + '</tbody></table>'*/

/*
      SELECT @XmlFormat = @XmlFormat + N' <h3>Resumen de los ultimos 7 dias de GetMessage y SaveChecks</h3>'+
	  '<table><theader><tr><th>Message</th><th>ServerTime</th><th>TotalError</th></tr></theader><tbody>' +
		 CAST((
		 SELECT [Message] AS 'td', '', ServerTime AS 'td', '', TotalError AS 'td'
		 FROM (
			SElECT [Message] = 'GetMessage', ServerTime = CAST(ServerDatetime AS date), TotalError = COUNT(1)
			  FROM dbo.LogForListener with(nolock)
			 WHERE 1 = 1
			   AND ServerDatetime >= CONVERT(DATETIME, CAST(DATEADD(DAY, -7, GETDATE()) AS DATE))
			   AND [Type] = 'Error'
			   AND [Message] like '%getmess%'
			 GROUP BY CAST(ServerDatetime AS date)
			UNION
			SELECT [Message] = 'SaveChecks', ServerTime = CAST(ServerDatetime AS date), TotalError = COUNT(1)
			  FROM dbo.LogForListener with(nolock)
			 WHERE 1 = 1
			   AND ServerDatetime >= CONVERT(DATETIME, CAST(DATEADD(DAY, -7, GETDATE()) AS DATE))
			   AND [Type] = 'Error'
			   AND [Message] like '%saveche%'
		     GROUP BY CAST(ServerDatetime AS date)
		--order by CAST(ServerDatetime AS date) desc
		) As t
		ORDER BY [Message] ASC, ServerTime DESC
						FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
		) + '</tbody></table>'
		*/

		/*SELECT @XmlFormat = @XmlFormat + N'<br/><br/> <h3>Resumen de los ultimos 20 minutos de errores en las aplicaciones</h3>' +
		N'<br/><br/> <table id="logforlistener"><theader><tr><th>Proyect</th><th>ServerDatetime</th><th>[Message]</th><th>StackTrace</th><th>ExceptionMessage</th><th>MethodsParams</th></tr></theader><tbody>' + 
		CAST((
			SELECT Proyect AS 'td', '', ServerDatetime AS 'td', '', [Message] AS 'td', '', StackTrace AS 'td', '', ExceptionMessage AS 'td', '', ISNULL(MethodsParams, '') AS 'td'
			  FROM dbo.LogForListener As lfl WITH(NOLOCK)
			 WHERE 1 = 1
			   AND [Type] = 'Error'
			   AND ServerDatetime >= @FilterDate --CONVERT(DATETIME, CAST(GETDATE() AS DATE))
			   AND [Message] != 'Error in Authentication.ValidateUserSession'
			 ORDER BY IdLog DESC
					FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
			) + '</tbody></table>'*/

	IF LEN(CONVERT(VARCHAR, @XmlFormat)) > 0
	BEGIN
		SET @Subject = 'Log For Listener ' + @@SERVERNAME
		EXEC msdb.dbo.sp_send_dbmail 
		@profile_name=@EmailProfile,
		@recipients='jmolina@boz.mx;soportemaxi@boz.mx;msalinas@boz.mx',
		@subject=@Subject,
		@body=@XmlFormat,
		@body_format = 'HTML'
	END
END