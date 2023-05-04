CREATE PROCEDURE Soporte.GetBillPaymentErrorNotifications
AS
BEGIN
	DECLARE @Recipients		NVARCHAR(500),
			@ProfileName	NVARCHAR(100)

	DECLARE @CurrentDate	DATETIME,
			@FromDate		DATETIME

	DECLARE @AgregatorErrorTexts TABLE
	(
		Id					INT IDENTITY,
		IdAgregator			INT,
		Name				VARCHAR(200),
		ErrorMessageLike	NVARCHAR(500)
	)

	-- Config Section

	-- Only for Dev
	SELECT 
		@CurrentDate = '2020-02-05 17:35',
		@Recipients = 'jcsierra@maxi-ms.com',
		@ProfileName = 'Stage'

	SET @FromDate = DATEADD(MINUTE, -3000, @CurrentDate)

	INSERT INTO @AgregatorErrorTexts
	VALUES
	(1, 'Authentication Error', '<Authentication Error><response_code>99%'),
	(5, NULL, '{"Bulletin":""%')

	;WITH LogErrors AS
	(
		SELECT
			aet.Id,
			MIN(R.IdLogBillPayment) LogBillPayment
		FROM MAXILOG.BillPayment.LogBillPaymentResponse R WITH (NOLOCK)
			JOIN @AgregatorErrorTexts aet ON aet.IdAgregator = R.IdAggregator
		WHERE 
			R.Response LIKE aet.ErrorMessageLike
			AND R.DateLastChange BETWEEN @FromDate AND @CurrentDate
		GROUP BY aet.Id
	)
	SELECT
		le.Id,
		aet.Name ErrorName,
		le.LogBillPayment,
		L.Response,
		L.DateLastChange,
		L.TypeMovent,
		A.Name AggregatorName
	INTO #Result
	FROM LogErrors le
		JOIN @AgregatorErrorTexts aet ON aet.id = le.id
		JOIN MAXILOG.BillPayment.LogBillPaymentResponse L WITH (NOLOCK) ON L.IdLogBillPayment = le.LogBillPayment
		JOIN BillPayment.Aggregator a WITH(NOLOCK) ON a.IdAggregator = L.IdAggregator
			
	DECLARE @CurrentId	INT,
			@Subject	VARCHAR(200),
			@Message	VARCHAR(2000)

	WHILE EXISTS(SELECT 1 FROM #Result r)
	BEGIN
		SELECT TOP 1 
			@CurrentId = r.Id,
			@Subject = CONCAT('BillPayment Error Notification ', r.AggregatorName),
			@Message = CONCAT('Test', r.Id)
		FROM #Result r

		SELECT @subject, @Message
		
		--EXEC msdb.dbo.sp_send_dbmail
		--	@profile_name = @ProfileName,
		--	@recipients = @Recipients,
		--	@body_format = 'HTML',
		--	@subject = @Subject,
		--	@body = @Message

		DELETE FROM #Result WHERE Id = @CurrentId
	END

	DROP TABLE #Result
END
