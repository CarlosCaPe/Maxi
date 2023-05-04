CREATE PROCEDURE [Soporte].[NotificationErrorLogStoredProcedure]

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
	DECLARE @XmlFormatTemp nvarchar(max)
	DECLARE @Subject varchar(150)
	DECLARE @FilterDate datetime = DATEADD(MINUTE, -60, GETDATE()) --DATEADD(MINUTE, -20, DATEADD(DAY, -0, GETDATE()) )
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

		SELECT @XmlFormatTemp = N'<h3>Resumen de los ultimos 60 minutos de errores en Stored Procedures</h3>'
		  + '<table id="customers"><theader><tr><th>IdErrorLogForStoreProcedure</th><th>StoreProcedure</th><th>ErrorDate</th><th>ErrorMessage</th></tr></theader><tbody>' + 
		CAST((
				SELECT IdErrorLogForStoreProcedure AS 'td', '', StoreProcedure AS 'td', '', ErrorDate AS 'td', '', ErrorMessage AS 'td'
					FROM dbo.ErrorLogForStoreProcedure AS el WITH(NOLOCK)
					WHERE 1 = 1
					AND errorDate >= @FilterDate
					AND (ErrorMessage NOT LIKE ' Y el IdPayer%' AND StoreProcedure NOT LIKE 'st_UpdateAgentApplication%' AND StoreProcedure NOT LIKE 'Lunex.st_CreateTransferLN%' AND StoreProcedure NOT LIKE '%Soporte.CollectionReport%')
					FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
			) + '</tbody></table>'

		IF (ISNULL(@XmlFormatTemp, '') != '')
			SET @XmlFormat += @XmlFormatTemp

		SELECT @XmlFormatTemp = N'<br/><br/> <h3>Resumen de los ultimos 60 minutos de errores en las aplicaciones</h3>' +
		N'<table id="logforlistener"><theader><tr><th>Proyect</th><th>ServerDatetime</th><th>[Message]</th><th>StackTrace</th><th>ExceptionMessage</th><th>MethodsParams</th></tr></theader><tbody>' + 
		CAST((
			SELECT Proyect AS 'td', '', ServerDatetime AS 'td', '', [Message] AS 'td', '', StackTrace AS 'td', '', ExceptionMessage AS 'td', '', ISNULL(MethodsParams, '') AS 'td'
			  FROM dbo.LogForListener As lfl WITH(NOLOCK)
			 WHERE 1 = 1
			   AND [Type] = 'Error'
			   AND ServerDatetime >= @FilterDate --CONVERT(DATETIME, CAST(GETDATE() AS DATE))
			   AND ([Message] != 'Error in Authentication.ValidateUserSession' AND [Message] NOT LIKE '%MessageEngine.ConnectionClosed%' AND [Message] NOT LIKE '%Error al Tratar de Comprobar PC%')
			 ORDER BY IdLog DESC
					FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
			) + '</tbody></table>'

		IF (ISNULL(@XmlFormatTemp, '') != '')
			SET @XmlFormat += @XmlFormatTemp


	DECLARE @DuplicateTransfer Varchar(max)

	SET @DuplicateTransfer = (
							   CAST((
							   	    SELECT IdInfoLogForStoreProcedure AS 'td', '', StoreProcedure AS 'td', '', InfoDate AS 'td', '', InfoMessage AS 'td', '', ExtraData AS 'td'
							   	      FROM Soporte.InfoLogForStoreProcedure with(nolock)
							   	     WHERE 1 = 1
							   	  	   AND InfoDate >= @FilterDate
							   	  	   AND (InfoMessage like '%Error%transfer%not%created%'  or InfoMessage like '%Error%Pre-Receipt%not%created%')
							   	     ORDER BY IdInfoLogForStoreProcedure desc
							   	  	   FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
							   	     )
	                           )
	IF LEN(@DuplicateTransfer) > 0
	BEGIN
		SELECT @XmlFormatTemp = N'<h3>Resumen de los ultimos 60 minutos de posibles transferencias duplicadas</h3>'
		  + '<table id="customers"><theader><tr><th>IdInfoLogForStoreProcedure</th><th>StoreProcedure</th><th>InfoDate</th><th>InfoMessage</th><th>Parametros</th></tr></theader><tbody>' + 
		    ISNULL(@DuplicateTransfer, '') + '</tbody></table>'
	END

		IF (ISNULL(@XmlFormatTemp, '') != '')
			SET @XmlFormat += @XmlFormatTemp

	IF LEN(CONVERT(VARCHAR, @XmlFormat)) > 0
	BEGIN
		SET @Subject = 'Error Log For StoredProcedure y Log For Listner ' + @@SERVERNAME
		EXEC msdb.dbo.sp_send_dbmail 
		@profile_name=@EmailProfile,
		@recipients='bozservices@boz.mx;soportemaxi@boz.mx;',
		@copy_recipients='',
		@subject=@Subject,
		@body=@XmlFormat,
		@body_format = 'HTML'
	END
END