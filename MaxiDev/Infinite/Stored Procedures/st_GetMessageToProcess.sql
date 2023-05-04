
CREATE PROCEDURE [Infinite].[st_GetMessageToProcess]
	-- Add the parameters for the stored procedure here
	@HasError BIT OUTPUT,
	@OperationMessage NVARCHAR(MAX) OUTPUT

AS

/********************************************************************
<Author>Francisco Lara</Author>
<app>WinServices Maxi Host Manager 3</app>
<CreateDate>2015-12-14</CreateDate>
<Description>Get a sms row for be processed by windows service</Description>

<ChangeLog>
<log Date="04/07/2018" Author="jmolina">se agrego nombre de agencia en cuerpo de mensaje para las agencias de Casa de Dinero #1</log>
<log Date="27/07/2018" Author="jmolina">se agrego telefono y aclaraciones en cuerpo de mensaje para las agencias de Casa de Dinero #2</log>
<log Date="31/10/2019" Author="jhornedo">Optimizacion de consulta #3</log>
<log Date="17/06/2022" Author="jdarellano" Name="#4">Performance: se agregan with(nolock) y se mejora método de búsqueda.</log>
</ChangeLog>
********************************************************************/
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here

	DECLARE @Enviroment NVARCHAR(MAX)
			, @SmsMaxAttempts INT
			, @SmsMinutesForNextAttempt INT
			, @Date DATETIME = GETDATE()
			, @BeginTime TIME = CONVERT(TIME,[dbo].[GetGlobalAttributeByName]('BeginTimeForSendSms'))
			, @EndTime TIME = CONVERT(TIME,[dbo].[GetGlobalAttributeByName]('EndTimeForSendSms'));

	SELECT @SmsMaxAttempts = CONVERT(INT,[dbo].[GetGlobalAttributeByName]('SmsMaxAttempts'));
	SELECT @SmsMinutesForNextAttempt = CONVERT(INT,[dbo].[GetGlobalAttributeByName]('SmsMinutesForNextAttempt'));
	
	-- Reject messages from recipients who do not wish to receive messages
	UPDATE TMI SET
		TMI.[IdTextMessageStatus] = 8 -- Cancelled
		, TMI.[LastDateChange] = @Date
	FROM [Infinite].[CellularNumber] CN
	JOIN [Infinite].[TextMessageInfinite] TMI ON CN.[IdCellularNumber] = TMI.[IdCellularNumber]
	WHERE CN.[AllowSentMessages] = 0
		AND TMI.[IdTextMessageStatus] IN (1,2)
		AND [IdMessageType] NOT IN (2,3,4,5); -- ConfirmationCode, BeneficiaryInvitation, CustomerInvitation, ReceiveMaxi

	-- Filter only allow numbers for testing environments
	SET @Enviroment = [dbo].[GetGlobalAttributeByName]('Enviroment');

	IF @Enviroment <> 'Production'
	BEGIN
		DECLARE @AllowedNumbersForTesting NVARCHAR(MAX) = ISNULL([dbo].[GetGlobalAttributeByName]('SmsNumberAllowedForTesting'),'');
		--DECLARE @AllowedNumbers TABLE ([Number] NVARCHAR(MAX));
		CREATE TABLE #AllowedNumbers ([Number] NVARCHAR(MAX));--#4

		INSERT INTO #AllowedNumbers ([Number]) (SELECT [item] FROM [dbo].[fnSplit] (@AllowedNumbersForTesting,','))--#4

		UPDATE TMI SET
		TMI.[IdTextMessageStatus] = 7 -- NoSend
		, TMI.[LastDateChange] = @Date
		FROM [Infinite].[CellularNumber] CN
		JOIN [Infinite].[TextMessageInfinite] TMI ON CN.[IdCellularNumber] = TMI.[IdCellularNumber]
		WHERE TMI.[IdTextMessageStatus] IN (1,2)
			AND CN.[InterCode] + [dbo].[fn_GetNumeric](CN.[NumberWithFormat]) NOT IN (SELECT [Number] FROM #AllowedNumbers);
	END;

	/*Declaracion de tabla para excepcion de casa de dinero #2*/
	--DECLARE @CasaDinero TABLE (IdAgent int, AgentName varchar(Max), ThankYou varchar(max), ThankYou2 varchar(max), Clarifications varchar(max), Clarifications2 varchar(max), DiscardInBody varchar(max))
	CREATE TABLE #CasaDinero (IdAgent int, AgentName varchar(Max), ThankYou varchar(max), ThankYou2 varchar(max), Clarifications varchar(max), Clarifications2 varchar(max), DiscardInBody varchar(max));--#4

	/*Datos para casa de dinero #2*/
	INSERT INTO #CasaDinero (IdAgent, AgentName, ThankYou, ThankYou2, Clarifications, Clarifications2, DiscardInBody)
	SELECT a.IdAgent, a.AgentName, ThankYou = 'Gracias por hacer su envio en ',
			ThankYou2 = 'Gracias por su envio en ',
			Clarifications = 'cualquier duda contactarnos al ' + 
			CASE (IdAgent) 
				WHEN 7861 THEN '(479) 899-6851' 
				WHEN 7859 THEN '(479) 419-9912' 
				WHEN 7860 THEN '(479) 419-9826' 
				WHEN 7862 THEN '(479) 899-6436' 
			END,
			Clarifications2 = 'contacto ' + 
			CASE (IdAgent) 
				WHEN 7861 THEN '(479) 899-6851' 
				WHEN 7859 THEN '(479) 419-9912' 
				WHEN 7860 THEN '(479) 419-9826' 
				WHEN 7862 THEN '(479) 899-6436' 
			END,
			DiscardInBody = 'Si requiere ayuda marque al 8663676294'
	FROM dbo.Agent AS a WITH(NOLOCK)
	WHERE AgentName LIKE '%casa%dinero%';

/* begin #3 */ 
	--;WITH cte_Datos AS (
	SELECT 
		TMI.[IdTextMessageInfinite]
		, TMI.[IdMessageType]
		, TMI.[IdPriority]
		, CN.[InterCode] + [dbo].[fn_GetNumeric](CN.[NumberWithFormat]) [Number]
		--, [Message] = IIF(cd.IdAgent IS NOT NULL AND TMI.[IdMessageType] <> 9, IIF([Message] LIKE '%MAXI NO%', cd.ThankYou2, cd.ThankYou) + cd.AgentName + '. ' + IIF([Message] LIKE '%MAXI NO%', cd.Clarifications2, cd.Clarifications) + ', ' + REPLACE([Message], cd.DiscardInBody, ''), [Message]) --#1, #2
			,[Message] 
		, [IdTextMessageStatus]
		--, AgentName = ISNULL(CASE WHEN A.IdAgent IN (7859, 7860, 7861, 7862) THEN A.AgentName ELSE '' END, '') --#1
		, cd.IdAgent
		, cd.ThankYou2
		, cd.ThankYou
		, cd.AgentName
		, cd.Clarifications2
		, cd.Clarifications
		, cd.DiscardInBody
		, cn.InterCode
		, cn.NumberWithFormat
	INTO #cte_Datos
	FROM [Infinite].[CellularNumber] CN WITH (NOLOCK)
	JOIN [Infinite].[TextMessageInfinite] TMI WITH (NOLOCK) ON CN.[IdCellularNumber] = TMI.[IdCellularNumber]
	JOIN [Infinite].[Priority] P WITH (NOLOCK) ON TMI.[IdPriority] = P.[IdPriority]
	LEFT JOIN [dbo].[Gateway] G WITH (NOLOCK) ON TMI.[GatewayId] = G.[IdGateway]
	LEFT JOIN [dbo].[Agent] A WITH (NOLOCK) ON TMI.[AgentId] = A.[IdAgent]
	LEFT JOIN #CasaDinero As cd ON A.IdAgent = cd.IdAgent
	LEFT JOIN [dbo].[TimeZone] T WITH (NOLOCK) ON A.[IdTimeZone] = T.[IdTimeZone]
	WHERE ([IdTextMessageStatus] = 1 OR ([IdTextMessageStatus] = 5 AND [Attempts] < @SmsMaxAttempts AND DATEDIFF(ss,[LastDateChange], @Date) / 60 > @SmsMinutesForNextAttempt))--#4
	AND (
			(TMI.[IdMessageType] IN (5,6,7) -- ReceiveMaxi, StopMaxi, Paid
			AND CONVERT(TIME,DATEADD(HOUR,ISNULL(T.[HoursForLocalTime],0),@Date)) >= @BeginTime
			AND CONVERT(TIME,DATEADD(HOUR,ISNULL(T.[HoursForLocalTime],0),@Date)) <= @EndTime)
		OR
			(TMI.[IdMessageType] = 1 -- PaymentReady, 
			AND (G.[ImmediateResponse] = 1
				OR
				(CONVERT(TIME,DATEADD(HOUR,ISNULL(T.[HoursForLocalTime],0),@Date)) >= @BeginTime
				AND CONVERT(TIME,DATEADD(HOUR,ISNULL(T.[HoursForLocalTime],0),@Date)) <= @EndTime)))
		OR
			TMI.[IdMessageType] IN (2,3,4,9,10,11) -- ConfirmationCode, BeneficiaryInvitation, CustomerInvitation, WelcomeSms
	);

	SELECT 
		[IdTextMessageInfinite], 
		[IdMessageType],
		[IdPriority],
		[InterCode] + [dbo].[fn_GetNumeric]([NumberWithFormat]) [Number],
		[Message] = IIF(IdAgent IS NOT NULL AND [IdMessageType] <> 9, IIF([Message] LIKE '%MAXI NO%', ThankYou2, ThankYou) + AgentName + '. ' + IIF([Message] LIKE '%MAXI NO%', Clarifications2, Clarifications) + ', ' + REPLACE([Message], DiscardInBody, ''), [Message]), --#1, #2 
		[IdTextMessageStatus]
	INTO #TempTable
	FROM #cte_Datos;
	/* end #3 */ 
	
--	SELECT * 
--	INTO #tmpNewMessages
--	FROM Infinite.TextMessageInfinite WITH(NOLOCK) WHERE IdTextMessageStatus = 1
--	
--	
--	/*Cambiar de estatus (8 - Canceled by MaxiSystem) los mensajes Hold para transacciones que salieron de Hold y ya pasó el tiempo del delay*/
--	UPDATE  Infinite.TextMessageInfinite SET IdTextMessageStatus = 8
--	WHERE IdTextMessageInfinite IN (SELECT TMI.IdTextMessageInfinite		
--									FROM #tmpNewMessages TMI
--									INNER JOIN Transfer T ON T.IdTransfer = TMI.IdTransfer
--									WHERE TMI.IdMessageType = 11
--										AND T.IdStatus NOT IN (41, 29) 
--										AND getdate() > TMI.DelayedDateTime)
--	
--	
--	INSERT INTO #TempTable
--	SELECT TMI.IdTextMessageInfinite,
--		TMI.IdMessageType,
--		TMI.IdPriority,
--		CN.[InterCode] + [dbo].[fn_GetNumeric](CN.[NumberWithFormat]),
--		TMI.Message,
--		TMI.IdTextMessageStatus 
--	FROM #tmpNewMessages TMI
--	INNER JOIN Transfer T ON T.IdTransfer = TMI.IdTransfer
--	INNER JOIN Infinite.CellularNumber  CN ON CN.IdCellularNumber = TMI.IdCellularNumber
--	WHERE TMI.IdMessageType = 11
--		AND T.IdStatus IN (41, 29) 
--		AND getdate() > TMI.DelayedDateTime		
	
	UPDATE [Infinite].[TextMessageInfinite] SET
		[IdTextMessageStatus] = 2 -- Processing
		, [LastDateChange] = @Date
	WHERE [IdTextMessageInfinite] IN (SELECT [IdTextMessageInfinite] FROM #TempTable);

	SET @HasError = 0;
	SET @OperationMessage = 'Operation was successful';
	
	--DECLARE @TotalMessages INT
	
	--SELECT @TotalMessages = count(1) FROM #TempTable
	
	--INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_GetMessageToProcess', GETDATE(), 'Total messages: ' + convert(NVARCHAR(10),@TotalMessages))

	SELECT
		DISTINCT [IdTextMessageInfinite]
		, [IdMessageType]
		, [IdPriority]
		, [Number]
		, [Message] --= IIF(AgentName = '', [Message], LEFT(AgentName, 14) + '. ' + [Message]) --#1
		, [IdTextMessageStatus]
	FROM #TempTable
	ORDER BY [IdPriority] DESC;

	--DROP TABLE #TempTable
	--DROP TABLE #tmpNewMessages

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX);
	SELECT @ErrorMessage=ERROR_MESSAGE();
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('st_GetMessageToProcess', GETDATE(), @ErrorMessage);
	INSERT INTO [Soporte].[InfoLogForStoreProcedure] ([StoreProcedure], [InfoDate], [InfoMessage],[ExtraData],[XML]) VALUES ('Infinite.st_GetMessageToProcess', GETDATE(),'Line: '+CAST(ERROR_LINE() as nvarchar(15))+'. '+@ErrorMessage,CAST(ERROR_LINE() as nvarchar(15))+'.',NULL);
	SET @HasError = 1;
	SET @OperationMessage = 'Error trying return value';
END CATCH


