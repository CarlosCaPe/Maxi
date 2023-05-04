CREATE PROCEDURE [msg].[st_GetStatefulMessages]
(
    --@idMessageProvider int,
    @idUser int,
    @userSession nvarchar(max),
	@isSpanish bit
)
as

/********************************************************************
<Author>--</Author>
<app>MaxiAgente</app>
<Description>This stored is used in agent for get message</Description>

<ChangeLog>
<log Date="16/01/2018" Author="jmolina">Se agrega try catch y eliminacion de temporal</log>
<log Date="30/04/2018" Author="msalinas" Name="#1">Se agrega filtro de fecha para delimiatar la cantidad de registros, considerando 2017 y 2018.</log>
<log Date="10/06/2022" Author="jdarellano" Name="#2">Se agrega filtro de fecha para delimitar la cantidad de registros, considerando hasta 60 días atrás.</log>
<log Date="2023/05/03" Author="jdarellano">Se agrega filtro de fecha para delimitar la cantidad de registros, considerando hasta 10 días atrás.</log>
</ChangeLog>
*********************************************************************/

BEGIN TRY

	--DECLARE @IdValue int
	--INSERT INTO Soporte.InfoLogForStoreProcedure(StoreProcedure, InfoDate, InfoMessage, ExtraData)
	--VALUES('st_GetStatefulMessages', GETDATE(), 'INICIO', '@idUser = ' + CONVERT(VARCHAR, @idUser) + ', @userSession = ' + CONVERT(VARCHAR, @userSession) + ', @isSpanish = ' + CONVERT(VARCHAR, @isSpanish))
	--SET @IdValue = SCOPE_IDENTITY()

	--IF OBJECT_ID('tempdb..#Messages') IS NOT NULL DROP TABLE #Messages
	CREATE TABLE #Messages(IdMessageSubscriber int,IdMessageStatus int, IdMessageProvider int, RawMessage nvarchar(max), DateOfLastChange datetime, MessageIsRead Bit)
	
	INSERT INTO #Messages
	SELECT MS.IdMessageSubscriber, MS.IdMessageStatus,M.IdMessageProvider, M.RawMessage,m.DateOfLastChange,ms.MessageIsRead
	  FROM msg.[Messages] AS M WITH(NOLOCK)
	 INNER JOIN msg.MessageSubcribers AS MS WITH(NOLOCK) on /*M.IdMessageProvider=@IdMessageProvider and */M.IdMessage = MS.IdMessage 
	 WHERE MS.IdMessageStatus <> 5 
	   AND MS.IdUser = @idUser 
	   --AND YEAR(m.DateOfLastChange)>2017--#1
	   AND m.DateOfLastChange >= DATEADD(DAY,-10,CAST(GETDATE() AS date))--#2
	   AND NOT EXISTS(SELECT 1 
	                    FROM msg.MessageSubscriberDetails WITH(NOLOCK)
					   WHERE IdMessageSubscriber=MS.IdMessageSubscriber 
						 AND UserSession = @userSession 
						 AND IdMessageStatus = MS.IdMessageStatus
					    );
	
	
	--Actualizar IdMessageStatus de los nuevos a enviados
	/*UPDATE msg.MessageSubcribers 
	   SET IdMessageStatus = 2, 
	       DateOfLastChange= GetDate()
	 WHERE IdMessageSubscriber IN (SELECT IdMessageSubscriber FROM #Messages WHERE IdMessageStatus = 1)*/

	UPDATE ms
	   SET IdMessageStatus = 2, 
	       DateOfLastChange= GetDate()
	  FROM msg.MessageSubcribers AS ms
	 WHERE EXISTS (SELECT 1 FROM #Messages AS m WHERE IdMessageStatus = 1 AND ms.IdMessageSubscriber = m.IdMessageSubscriber);
	
	UPDATE #Messages 
	   SET IdMessageStatus = 2 
	 WHERE IdMessageStatus=1;
	
	--Insertar detalle
	INSERT INTO msg.MessageSubscriberDetails
	SELECT IdMessageSubscriber, IdMessageStatus, @userSession, GetDate() 
	  FROM #Messages WITH(NOLOCK);

	--UPDATE Soporte.InfoLogForStoreProcedure SET InfoMessage = CONVERT(VARCHAR, GETDATE(), 121) WHERE IdInfoLogForStoreProcedure = @IdValue
	
	SELECT IdMessageSubscriber,IdMessageStatus,IdMessageProvider,RawMessage,DateOfLastChange,MessageIsRead
	  FROM #Messages WITH(NOLOCK);

	--DROP TABLE #Messages
	--IF OBJECT_ID('tempdb..#Messages') IS NOT NULL DROP TABLE #Messages
END TRY
BEGIN CATCH
	DECLARE @ErrorMessage varchar(max)
    SELECT @ErrorMessage=ERROR_MESSAGE()

	SELECT IdMessageSubscriber,IdMessageStatus,IdMessageProvider,RawMessage,DateOfLastChange,MessageIsRead 
	  FROM #Messages WITH(NOLOCK)

	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
	     VALUES ('[msg].[st_GetStatefulMessages]', GETDATE(), 'Parameters: idUser=' + CONVERT(VARCHAR,@idUser) + ', userSession=' + @userSession + ', isSpanish=' + CONVERT(VARCHAR, @isSpanish) + '. Error: ' + @ErrorMessage)

	DROP TABLE #Messages
	--IF OBJECT_ID('tempdb..#Messages') IS NOT NULL DROP TABLE #Messages
END CATCH