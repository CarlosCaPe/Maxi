CREATE PROCEDURE [msg].[st_GetAndCreateIntrusiveMessages]
AS
DECLARE @ErrorMessage VARCHAR(max)
BEGIN TRY
	DECLARE @Num AS INT = (SELECT TOP 1 Value FROM GlobalAttributes WHERE Name = 'TimeDelayKYCMessages')
  --NOTIFICACIONES RETRASADAS
	DECLARE @MessagesTemp AS TABLE
	(
		IdMessage INT, RawMessage NVARCHAR(MAX), DateOfLastChange DATETIME, 
		AgentCode NVARCHAR(20), IdTransfer INT
	)
	INSERT INTO @MessagesTemp
	SELECT DISTINCT 
	M.IdMessage, 
	M.RawMessage,
	m.DateOfLastChange,
	SUBSTRING(M.RawMessage,CHARINDEX('"AgentCode"', M.RawMessage) + LEN('"AgentCode"""'),CHARINDEX('"', M.RawMessage, CHARINDEX('"AgentCode"', M.RawMessage) + LEN('"AgentCode":"')) - CHARINDEX('"AgentCode"', M.RawMessage) - LEN('"AgentCode":"')) AS AgentCode,
	SUBSTRING(M.RawMessage,CHARINDEX('"IdTransfer"', M.RawMessage) + LEN('"IdTransfer""'),CHARINDEX('"', M.RawMessage, CHARINDEX('"IdTransfer"', M.RawMessage) + LEN('"IdTransfer":"')) - CHARINDEX('"IdTransfer"', M.RawMessage) - LEN('"IdTransfer":"')) AS IdTransfer
	FROM msg.Messages M WITH (NOLOCK)
	INNER JOIN msg.MessageSubcribers MS WITH (NOLOCK) on M.IdMessage = MS.IdMessage 
	WHERE 
	MS.IdMessageStatus NOT IN (4,5)
	AND M.IdMessageProvider = 2
	AND CHARINDEX('IdTransfer', M.RawMessage) > 0
	AND DATEDIFF(MINUTE, M.DateOfLastChange, GETDATE()) >= @Num
  --NOTIFICACIONES RETRASADAS X USUARIO
	DECLARE @MessagesxUser AS TABLE
	(
		IdMessage INT, RawMessage NVARCHAR(MAX), DateOfLastChange DATETIME, 
		IdAgent INT, 
		IdTransfer INT,
		IdUser INT
	)
	INSERT INTO @MessagesxUser
	SELECT MT.IdMessage, MT.RawMessage, MT.DateOfLastChange, A.IdAgent, MT.IdTransfer, AU.IdUser FROM @MessagesTemp MT INNER JOIN Agent A ON A.AgentCode = MT.AgentCode INNER JOIN AgentUser AU ON AU.IdAgent = A.IdAgent
  --NOTIFICACIONES INTRUSIVAS YA EXISTENTES X USUARIO
	DECLARE @IntrusivesxUser AS TABLE
	(
		IdMessageSource INT,
		IdMessage INT, 
		RawMessage NVARCHAR(MAX), 
		IdUser INT,
		DateOfLastChange DATETIME,
		IdMessageStatus INT,
		IdMessageSubscriber INT
	)
	INSERT INTO @IntrusivesxUser
	SELECT 
	CONVERT(INT,SUBSTRING(M.RawMessage,CHARINDEX('"IdMessageSource"', M.RawMessage) + LEN('"IdMessageSource""'),CHARINDEX('"', M.RawMessage, CHARINDEX('"IdMessageSource"', M.RawMessage) + LEN('"IdMessageSource":"')) - CHARINDEX('"IdMessageSource"', M.RawMessage) - LEN('"IdMessageSource":"'))) AS IdMessageSource,
	M.IdMessage, M.RawMessage, MS.IdUser, M.DateOfLastChange, MS.IdMessageStatus, MS.IdMessageSubscriber
	FROM msg.Messages M WITH (NOLOCK) INNER JOIN msg.MessageSubcribers MS WITH (NOLOCK) ON M.IdMessage = MS.IdMessage 
	WHERE M.IdMessageProvider = 5 
	AND CHARINDEX('"IdMessageSource":1,', M.RawMessage) <= 0 
	AND CHARINDEX('"IdMessageSource"', M.RawMessage) > 0 
  --NOTIFICACIONES RETRASADAS CON SU RESPECTIVA NOTIFICACION INTRUSIVA SI YA EXISTE
	DECLARE @Msgs AS TABLE
	(
		IdMessage INT, 
		RawMessage NVARCHAR(MAX), 
		DateOfLastChange DATETIME, 
		IdAgent INT, 
		IdTransfer INT,
		IdUser INT,
		IdMessageSource INT,
		IdMessageIntrusive INT, 
		RawMessageIntrusive NVARCHAR(MAX), 
		IdUserIntrusive INT,
		DateOfLastChangeIntrusive DATETIME,
		IdMessageStatus INT,
		IdMessageSubscriber INT
	)
	INSERT INTO @Msgs
	SELECT * FROM @MessagesxUser MU LEFT OUTER JOIN @IntrusivesxUser IU ON MU.IdMessage = IU.IdMessageSource AND MU.IdUser = IU.IdUser
	ORDER BY MU.IdAgent, MU.IdMessage, MU.IdUser
  --ELIMINA MessageSubscriberDetails QUE PERTENECEN A UNA INTRUSIVA PERO YA NO SE USARAN (PARA EVITAR SATURACION DE DATOS)
	DELETE FROM msg.MessageSubscriberDetails WHERE IdMessageSubscriber IN 
	(
		SELECT DISTINCT IdMessageSubscriber FROM @Msgs WHERE IdMessageIntrusive IS NOT NULL AND IdMessageStatus <> 1
	)
  --ACTUALIZA UNA INTRUSIVA SI YA EXISTE Y ESTA EN ESTATUS NEW O SENT Y LA PONE EN ESTATUS DE NEW PERO CON LA FECHA ACTUAL
	UPDATE msg.MessageSubcribers 
	SET IdMessageStatus = 1, DateOfLastChange = GETDATE()
	WHERE IdMessageSubscriber IN 
	(
		SELECT DISTINCT IdMessageSubscriber FROM @Msgs WHERE IdMessageIntrusive IS NOT NULL AND IdMessageStatus NOT IN (1,2)
	) AND DATEDIFF(MINUTE, DateOfLastChange, GETDATE()) >= @Num
  --INSERTA NOTIFICACIONES INTRUSIVAS NUEVAS
	DECLARE @IdMessageT table (idMessage int, idUser int)
	INSERT msg.Messages OUTPUT INSERTED.IdMessage, INSERTED.IdUserSender  INTO  @IdMessageT
	SELECT 
	5, 
	IdUser, 
	'{"IdMessageSource":' +  CONVERT(varchar, IdMessage) +',"IsIntrusive":true, "Message":"'+dbo.fn_searchItemStr(RawMessage,'Note') + '.", "MessageUS":"'+ dbo.fn_searchItemStr(RawMessage,'NameEn') + '. Folio: ' + CONVERT(varchar, T.Folio) + '", "MessageEs":"' + dbo.fn_searchItemStr(RawMessage,'NameEs') + '. Folio: ' + CONVERT(varchar, T.Folio) + '","CanClose":true}', GETDATE()
	FROM @Msgs M INNER JOIN Transfer T WITH(NOLOCK) ON T.IdTransfer = M.IdTransfer WHERE IdMessageIntrusive IS NULL
	INSERT INTO msg.MessageSubcribers (IdMessage,IdUser,IdMessageStatus,DateOfLastChange)
	SELECT idMessage, idUser, 1, GETDATE() 
	FROM @IdMessageT
  --ACTUALIZA ESTATUS A 5 (Dismissed) EN INTRUSIVAS QUE SIGUEN ACTIVAS PERO LA NOTIFICACION KYC YA NO
	UPDATE msg.MessageSubcribers 
	SET IdMessageStatus = 5
	WHERE IdMessageSubscriber IN (
	SELECT DISTINCT Intrusives.IdMessageSubscriber  
	FROM 
	(
		--Intrusivas Activas
		SELECT CONVERT(INT,SUBSTRING(M.RawMessage,CHARINDEX('"IdMessageSource"', M.RawMessage) + LEN('"IdMessageSource""'),CHARINDEX('"', M.RawMessage, CHARINDEX('"IdMessageSource"', M.RawMessage) + LEN('"IdMessageSource":"')) - CHARINDEX('"IdMessageSource"', M.RawMessage) - LEN('"IdMessageSource":"'))) AS IdMessageSource
		,M.IdMessage, 
		MS.IdMessageSubscriber
		FROM msg.Messages M WITH (NOLOCK) INNER JOIN msg.MessageSubcribers MS WITH (NOLOCK) ON MS.IdMessage = M.IdMessage
		WHERE M.IdMessageProvider = 5 AND CHARINDEX('"IdMessageSource":1', M.RawMessage) <= 0 AND CHARINDEX('"IdMessageSource"', M.RawMessage) > 0 AND MS.IdMessageStatus NOT IN (4,5)
	) AS Intrusives INNER JOIN 
	(
		--KYC Notifications DISMISS
		SELECT DISTINCT M.IdMessage AS IdMessageKYC FROM
		msg.Messages M WITH (NOLOCK) INNER JOIN msg.MessageSubcribers MS WITH (NOLOCK) ON MS.IdMessage = M.IdMessage WHERE M.IdMessageProvider = 2 AND MS.IdMessageStatus IN (4,5)
	) AS KYCNotes ON Intrusives.IdMessageSource = KYCNotes.IdMessageKYC 
)
END TRY  
BEGIN CATCH  
	SET  @ErrorMessage = ERROR_MESSAGE()
    INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetAndCreateIntrusiveMessages',Getdate(),@ErrorMessage)
END CATCH  