


CREATE PROCEDURE [Soporte].[st_NotificationElasticDown] --(@IdProcess int) --(@SendMessage bit out)
AS
BEGIN

	DECLARE @Cont int,
	@ModValue int,
	@SendMessage bit,
	@XmlFormat nvarchar(max),
	@LastExecute datetime,
	@LastExecutetmp varchar(30),
	@Latency bit,
	@LatencyTime int
	
	--PRINT OBJECT_NAME(@IdProcess)
	--SELECT @LastExecute = ISNULL(MAX(d.last_execution_time), GETDATE())
	--  FROM sys.dm_exec_procedure_stats AS d with(nolock)
	-- WHERE 1 = 1
	--   AND OBJECT_NAME(object_id, database_id) = OBJECT_NAME(@IdProcess)
	--   AND database_id = DB_ID()

	SELECT @Cont = CONVERT(INT, CASE WHEN [Value] = '' THEN 0 ELSE [Value] END)
	  FROM dbo.GlobalAttributes AS ga WITH(NOLOCK) 
	 WHERE 1 = 1 
	   AND [Name] = 'ElasticDown'

	SELECT @LastExecutetmp = [Value]
	  FROM dbo.GlobalAttributes AS ga WITH(NOLOCK) 
	 WHERE 1 = 1 
	   AND [Name] = 'LastExecuteCustomerLight'

	IF @LastExecutetmp != ''
	BEGIN
		SET @LastExecute = CONVERT(DATETIME, @LastExecutetmp)
			--PRINT CONVERT(VARCHAR, @LastExecute, 121)
		SET @LatencyTime = DATEDIFF(MINUTE, @LastExecute, GETDATE())
		IF (@LatencyTime >= 1 AND DATEDIFF(DAY, @LastExecute, GETDATE()) = 0)
		BEGIN
			SET @Cont = 0
			SET @Latency = 1
		END
		ELSE 
			SET @Cont = 0
	END

	SET @ModValue = (@Cont%30)

	IF (@Cont=0)
	BEGIN
		--PRINT 'PRIMERA VEZ: ' + CONVERT(VARCHAR(10), @Cont+1)
		SET @SendMessage = 1
		IF @Latency = 1
			SET @XmlFormat = 'Se están identificando consultas esporádicas de clientes en el proceso de base de datos, el tiempo de latencia es de ' + CONVERT(VARCHAR, @LatencyTime) + ' minuto(s) por consulta de cliente, revisar servicio de elasticsearch.'
		ELSE
			SET @XmlFormat = 'Se identificó una consulta de clientes por el proceso de base de datos, si llega un correo semejante a este en los proximos minutos, revisar servicio de elasticsearch.'

		UPDATE ga SET [Value] = CONVERT(VARCHAR(10), @Cont+1)
		  FROM dbo.GlobalAttributes AS ga
		 WHERE 1 = 1 
		   AND [Name] = 'ElasticDown'
	END
	ELSE IF (@ModValue = 0)
	BEGIN
		--PRINT 'MOD 0'
		SET @SendMessage = 1
		SET @XmlFormat = 'Se estan identificando 30 consultas de clientes por el proceso de base de datos, revisar servicio de elasticsearch.'
		UPDATE ga SET [Value] = '0'
		  FROM dbo.GlobalAttributes AS ga
		 WHERE 1 = 1 
		   AND [Name] = 'ElasticDown'
	END
	ELSE
	BEGIN
		--PRINT 'NORMAL'
		SET @SendMessage = 0
		UPDATE ga SET [Value] = CONVERT(VARCHAR(10), @Cont+1)
		  FROM dbo.GlobalAttributes AS ga 
		 WHERE 1 = 1 
		   AND [Name] = 'ElasticDown'
	END

	UPDATE ga SET [Value] = CONVERT(VARCHAR, CONVERT(VARCHAR, GETDATE(), 121))
		FROM dbo.GlobalAttributes AS ga
		WHERE 1 = 1 
		AND [Name] = 'LastExecuteCustomerLight'

IF @SendMessage=1
BEGIN
	DECLARE @Subject VARCHAR(250)
	DECLARE @EmailProfile nvarchar(max)

	SELECT @EmailProfile = [Value] FROM dbo.GlobalAttributes WITH(NOLOCK) WHERE Name='EmailProfiler'  
	SET @Subject = 'Consultas de clientes por base de datos ' + @@SERVERNAME
	
	EXEC msdb.dbo.sp_send_dbmail 
	@profile_name=@EmailProfile,
	@recipients='jmolina@boz.mx;soportemaxi@boz.mx',
	@subject=@Subject,
	@body=@XmlFormat,
	@body_format = 'HTML'
END
END

