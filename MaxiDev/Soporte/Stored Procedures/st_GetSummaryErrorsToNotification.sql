CREATE PROCEDURE [Soporte].[st_GetSummaryErrorsToNotification]

AS
/********************************************************************
<Author>jmmolina</Author>
<app>MaxiSupport</app>
<Description>Proceso de notificaciones de Errores en procedimientos alanecenado</Description>

<ChangeLog>
<log Date="08/10/2018" Author="jmolina">Validacion para ejecutar proceso de notificacion de errores #1</log>
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

		SELECT @XmlFormatTemp = N' <h3>Resumen de errores en ErrorLogForStoredProcedure, LogForListener, SMS(infinite) y Clientes sin Id ElasticSearch</h3>
		<table><theader><tr><th>Log</th><th>Total Error</th></tr></theader><tbody>' +
		CAST((
			SELECT Label AS 'td', '', TotalError AS 'td'
			FROM (
			SELECT Label = 'Total Error Log', TotalError = COUNT(1)
			  FROM dbo.ErrorLogForStoreProcedure with(nolock)
			 WHERE 1 = 1
			   AND ErrorDate >= CONVERT(DATETIME, CAST(DATEADD(DAY, -0, GETDATE()) AS DATE))
			   AND (ErrorMessage NOT LIKE ' Y el IdPayer%' AND StoreProcedure NOT LIKE 'st_UpdateAgentApplication%' AND StoreProcedure NOT LIKE 'Lunex.st_CreateTransferLN%' AND StoreProcedure NOT LIKE '%Soporte.CollectionReport%')
			UNION
			SELECT Label = 'Total Log For Listener', TotalError = COUNT(1)
			  FROM dbo.LogForListener with(nolock)
			 WHERE 1 = 1
			   AND ServerDatetime >= CONVERT(DATETIME, CAST(DATEADD(DAY, -0, GETDATE()) AS DATE))
			   AND [Type] = 'Error'
			UNION
			SELECT Label = 'Total Log For SMS', TotalError = COUNT(1)
			  FROM Infinite.ServiceLogInfinite WITH(NOLOCK)
			 WHERE 1 = 1
			   AND IsSuccess = 0
			   AND DateLastChange >= CONVERT(DATETIME, CAST(DATEADD(DAY, -0, GETDATE()) AS DATE))
			UNION
            SELECT Label = 'Total Clientes Sin Id ElasticSearch', TotalError = COUNT(1)
              FROM dbo.Customer with(nolock) 
             WHERE 1 = 1
               AND idElasticCustomer is null
               AND Name != ''
               AND DATEDIFF(MINUTE, CreationDate, GETDATE()) >= 5
			UNION
			SELECT Label ='Total Transferencias(Origin, StandBy, PendingGatewayResponse y TransferAcepted)', TotalError = COUNT(1)
			  FROM dbo.[Transfer] WITH(NOLOCK)
			 WHERE 1 = 1
			   AND IdStatus in (1, 20, 21, 40)
			   AND DATEDIFF(MINUTE, IIF(IdStatus = 1, DateOfTransfer, DateStatusChange), GETDATE()) > IIF(IdStatus = 1, 5, 60)
			UNION
			SELECT Label = 'Total Cheques en Pendig Gateway Response', TotalError = COUNT(1) 
			  FROM [dbo].[Checks] WITH(NOLOCK)
			 WHERE IdStatus = 21
			) As t
			FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
		) + '</tbody></table>'

	  IF (ISNULL(@XmlFormatTemp, '') != '')
		SET @XmlFormat += @XmlFormatTemp

      SELECT @XmlFormatTemp = N' <h3>Resumen de los ultimos 7 dias de GetMessage y SaveChecks</h3>'+
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

		IF (ISNULL(@XmlFormatTemp, '') != '')
			SET  @XmlFormat += @XmlFormatTemp

		SELECT @XmlFormatTemp = N'<h3>Resumen de totales por error en SMS(infinite)</h3>' +
		 '<table><theader><tr><th>Error</th><th>Totals</th></tr></theader><tbody>' +
		 CAST((
			SELECT Error AS 'td', '', TotalError AS 'td'
			FROM (
					SELECT Error = REPLACE(xmlData.item, '...', ''), TotalError = COUNT(1)
					  FROM Infinite.ServiceLogInfinite as sli WITH(NOLOCK)
					 CROSS APPLY dbo.fnSplit(REPLACE(sli.Request, '{', ''), ',') As r
					 CROSS APPLY dbo.fnSplit(r.item, '":"') As xmlData
					 WHERE 1 = 1
					   AND IsSuccess = 0
					   AND DateLastChange >= CONVERT(DATETIME, CAST(DATEADD(DAY, -0, GETDATE()) AS DATE))
					   AND r.item LIKE '%XmlData%'
					   AND xmlData.item != 'XmlData'
					   --AND LEN(xmlData.item) > 8
					 GROUP BY xmlData.item
			) As t
			FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
		 ) + '</tbody></table>'

		IF (ISNULL(@XmlFormatTemp, '') != '')
			SET  @XmlFormat += @XmlFormatTemp

		SELECT @XmlFormatTemp = N'<h3>Resumen de totales por error en LogForStoredProcedure</h3>' +
		 '<table><theader><tr><th>Error</th><th>Totals</th></tr></theader><tbody>' +
		 CAST((
			SELECT StoreProcedure AS 'td', '', TotalError AS 'td'
			FROM (
				SELECT StoreProcedure, TotalError = count(1)
				FROM dbo.ErrorLogForStoreProcedure with(nolock)
				WHERE 1 = 1
				AND ErrorDate >= CONVERT(DATETIME, CAST(DATEADD(DAY, -0, GETDATE()) AS DATE))
				AND (ErrorMessage NOT LIKE ' Y el IdPayer%' AND StoreProcedure NOT LIKE 'st_UpdateAgentApplication%' AND StoreProcedure NOT LIKE 'Lunex.st_CreateTransferLN%' AND StoreProcedure NOT LIKE '%Soporte.CollectionReport%')
				GROUP BY StoreProcedure
			) As t
			FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
		 ) + '</tbody></table>'

		IF (ISNULL(@XmlFormatTemp, '') != '')
			SET  @XmlFormat += @XmlFormatTemp

		SELECT @XmlFormatTemp = N'<h3>Resumen de totales por error en LogForListener</h3>' +
		 '<table><theader><tr><th>Error</th><th>Totals</th></tr></theader><tbody>' +
		 CAST((
			SELECT [Message] AS 'td', '', TotalError AS 'td'
			FROM (
				SELECT [Message], TotalError = count(1) 
				FROM dbo.LogForListener with(nolock)
				WHERE 1 = 1
				AND ServerDatetime >= CONVERT(DATETIME, CAST(DATEADD(DAY, -0, GETDATE()) AS DATE))
				AND [Type] = 'Error'
				AND ([Message] != 'Error in Authentication.ValidateUserSession' AND [Message] NOT LIKE '%MessageEngine.ConnectionClosed%' AND [Message] NOT LIKE '%Error al Tratar de Comprobar PC%')
				Group by [Message]
			) As t
			ORDER BY TotalError DESC
			FOR XML PATH('tr'), ELEMENTS) AS NVARCHAR(MAX)
		 ) + '</tbody></table>'

		IF (ISNULL(@XmlFormatTemp, '') != '')
			SET  @XmlFormat += @XmlFormatTemp


	IF LEN(CONVERT(VARCHAR, @XmlFormat)) > 0
	BEGIN
		SET @Subject = 'Resumen de errores ' + @@SERVERNAME
		EXEC msdb.dbo.sp_send_dbmail 
		@profile_name=@EmailProfile,
		@recipients='jmolina@boz.mx;soportemaxi@boz.mx;msalinas@boz.mx;fsuarez@boz.mx',
		@copy_recipients='azavala@boz.mx;snevarez@boz.mx',
		@subject=@Subject,
		@body=@XmlFormat,
		@body_format = 'HTML'
	END
END