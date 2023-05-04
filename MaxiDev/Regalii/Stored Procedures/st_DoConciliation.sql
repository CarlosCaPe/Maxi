-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-10-15
-- Description:	Do conciliation for Regalii transactions
-- =============================================
CREATE PROCEDURE [Regalii].[st_DoConciliation]
	-- Add the parameters for the stored procedure here
	@XmlTransactions XML,
	@JsonResponse NVARCHAR(MAX),
	@BeginDate DATETIME,
	@EndDate DATETIME,
	@HasError BIT OUTPUT

AS
BEGIN TRY
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SET @HasError = 0

	CREATE TABLE #Transactions(
		Id BIGINT,
		ExternalId BIGINT, -- IdProductTransfer
		BillerId INT, -- BillerId
		AccountNumber NVARCHAR(3000) COLLATE SQL_Latin1_General_CP1_CI_AS, -- Account_number
		BillAmount MONEY, -- AmountInMN
		BillAmountCurrency NVARCHAR(500) COLLATE SQL_Latin1_General_CP1_CI_AS, -- LocalCurrency
		FxRate MONEY, -- TransactionExRate
		BillAmountUsd MONEY, -- AmountInMN/TransactionExRate
		BillAmountChainCurrency MONEY, -- Not Use
		PaymentTransactionFee MONEY, -- Not Use
		PaymentTotalUsd MONEY, -- Not Use
		PaymentTotalChainCurrency MONEY, -- Not Use
		ChainEarned MONEY, -- Not Use
		ChainPaid MONEY, -- round(@AmountInMN/@transactionexrate,2)+@transactionFee
		StartingBalance MONEY, -- Not Use
		EndingBalance MONEY, -- Not Use
		HoursToFulfill INT, -- Not Use
		Discount MONEY, -- Not Use
		SmsText NVARCHAR(MAX) COLLATE SQL_Latin1_General_CP1_CI_AS, -- Not Use
		CreatedAt DATETIME, -- ProviderDate
		StatusId INT
	)

	DECLARE @BeginDateForPrint DATETIME = @BeginDate, @EndDateForPrint DATETIME = @EndDate
	SET @EndDate = DATEADD(dd, 1, @EndDate)
	SELECT @EndDate = dbo.RemoveTimeFromDatetime(@EndDate)
	SELECT @BeginDate = dbo.RemoveTimeFromDatetime(@BeginDate)

	DECLARE @DocHandle INT
	DECLARE @Recipients NVARCHAR(MAX)
	DECLARE @EmailProfile NVARCHAR(MAX)
	DECLARE @MessageMail NVARCHAR(MAX) = 'Regalii Conciliation Report'

	DECLARE @NewLine NVARCHAR(MAX) = CHAR(13)+CHAR(10)
	DECLARE @Tab NVARCHAR(MAX) = CHAR(9)

	SELECT @recipients=[Value] FROM  [dbo].[GlobalAttributes] WHERE [Name]='ListEmailRegalliError'
	SELECT @EmailProfile=[Value] FROM [dbo].[GlobalAttributes] WHERE [Name]='EmailProfiler'

	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Conciliation: Begin Load', GETDATE(),ISNULL(@jsonResponse,'Json Null'))
	--INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Conciliation: XML', GETDATE(),ISNULL(CONVERT(NVARCHAR(MAX),@XmlTransactions),'XML Null'))

	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlTransactions

	INSERT INTO #Transactions
		SELECT
			id
			, external_id
			, biller_id
			, account_number
			, bill_amount
			, bill_amount_currency
			, fx_rate
			, bill_amount_usd
			, bill_amount_chain_currency
			, payment_transaction_fee
			, payment_total_usd
			, payment_total_chain_currency
			, chain_earned
			, chain_paid
			, starting_balance
			, ending_balance
			, hours_to_fulfill
			, discount
			, sms_text
			, created_at
			, CASE [status] WHEN 'paid' THEN 30 WHEN 'unpaid' THEN 30 WHEN 'refunded' THEN 22 ELSE 0 END
		FROM OPENXML (@DocHandle, '/transactions/transaction', 2)
		WITH(
			id BIGINT
			, external_id BIGINT
			, biller_id INT
			, account_number NVARCHAR(3000)
			, bill_amount MONEY
			, bill_amount_currency NVARCHAR(500)
			, fx_rate  MONEY
			, bill_amount_usd MONEY
			, bill_amount_chain_currency MONEY
			, payment_transaction_fee MONEY
			, payment_total_usd MONEY
			, payment_total_chain_currency MONEY
			, chain_earned MONEY
			, chain_paid MONEY
			, starting_balance MONEY
			, ending_balance MONEY
			, hours_to_fulfill INT
			, discount MONEY
			, sms_text NVARCHAR(MAX)
			, created_at DATETIME
			, [status] NVARCHAR(MAX))
	
	CREATE TABLE #TransactionsNotMatched(
		IdFromProvider BIGINT,
		IdLocalDataBase BIGINT,
		Note NVARCHAR(MAX)
	)

	INSERT INTO #TransactionsNotMatched
		SELECT
			T.ExternalId
			, TR.IdProductTransfer
			, CASE
				WHEN T.[ExternalId] IS NULL THEN CONVERT(NVARCHAR(MAX),TR.[IdProductTransfer]) + ' - Transaction not exist in Regalii database'
				WHEN TR.[IdProductTransfer] IS NULL THEN CONVERT(NVARCHAR(MAX),T.[ExternalId]) + ' - Transaction not exist in local database'
				ELSE
					CASE WHEN
						T.[BillerId] = TR.[IdBiller]
						AND LTRIM(T.[AccountNumber]) = LTRIM(TR.[Account_Number])
						AND T.[BillAmount] = TR.[AmountInMN]
						AND T.[BillAmountCurrency] = TR.[LocalCurrency]
						AND T.[FxRate] = TR.[TransactionExRate]
						AND T.[BillAmountUsd] = ROUND(TR.[AmountInMN]/TR.[TransactionExRate],2)
						AND T.[ChainPaid] = ROUND(TR.[AmountInMN]/TR.[TransactionExRate],2) + TR.[TransactionFee]
						AND T.[CreatedAt] = TR.[ProviderDate]
						AND T.[StatusId] = TR.[IdStatus]
						THEN CONVERT(NVARCHAR(MAX),TR.[IdProductTransfer]) + ' - MATCHED'
						ELSE 'NOT MATCHED.' + @NewLine +
							'Field' + @Tab + @Tab + @Tab + '-' + @Tab + 'Regalii info / Local info' + @NewLine + 
							'Id' + @Tab + @Tab + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[ExternalId]) + ' / ' + CONVERT(NVARCHAR(MAX),TR.[IdProductTransfer]) + @NewLine +
							'Biller Id' + @Tab + @Tab + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[BillerId]) + ' / ' + CONVERT(NVARCHAR(MAX),TR.[IdBiller]) + @NewLine +
							'Account Number' + @Tab + '-' + @Tab + ISNULL(LTRIM(T.[AccountNumber]),'NULL') + ' / ' + ISNULL(LTRIM(TR.[Account_Number]),'NULL') + @NewLine +
							'Bill Amount' + @Tab + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[BillAmount]) + ' / ' + CONVERT(NVARCHAR(MAX),TR.[AmountInMN]) + @NewLine +
							'Bill Amount Currency' + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[BillAmountCurrency]) + ' / ' + CONVERT(NVARCHAR(MAX),TR.[LocalCurrency]) + @NewLine +
							'Fx Rate' + @Tab + @Tab + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[FxRate]) + ' / ' + CONVERT(NVARCHAR(MAX),TR.[TransactionExRate]) + @NewLine +
							'Bill Amount Usd' + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[BillAmountUsd]) + ' / ' + CONVERT(NVARCHAR(MAX),ROUND(TR.[AmountInMN]/TR.[TransactionExRate],2)) + @NewLine +
							'Chain Paid' + @Tab + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[ChainPaid]) + ' / ' + CONVERT(NVARCHAR(MAX),ROUND(TR.[AmountInMN]/TR.[TransactionExRate],2) + TR.[TransactionFee]) + @NewLine +
							'Created At' + @Tab + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[CreatedAt]) + ' / ' + CONVERT(NVARCHAR(MAX),TR.[ProviderDate]) + @NewLine +
							'Status'  + @Tab + @Tab + @Tab + '-' + @Tab + CONVERT(NVARCHAR(MAX),T.[StatusId]) + ' / ' + CONVERT(NVARCHAR(MAX),TR.[IdStatus])
						END
				END
		FROM #Transactions T WITH (NOLOCK)
		FULL JOIN (SELECT
						[IdProductTransfer]
						, [IdBiller]
						, [Account_Number]
						, [AmountInMN]
						, [LocalCurrency]
						, [TransactionExRate]
						, [TransactionFee]
						, [ProviderDate]
						, [IdStatus]
					FROM [Regalii].[TransferR] WITH (NOLOCK)
					WHERE [IdStatus] != 1 AND [ProviderDate] >= ISNULL(@BeginDate, [ProviderDate]) AND [ProviderDate] < ISNULL(@EndDate, [ProviderDate])
					) TR ON T.[ExternalId] = TR.[IdProductTransfer] and Tr.[TransactionExRate]>0
	
	DECLARE @Header NVARCHAR(MAX) = 'From: ' + CONVERT(NVARCHAR(MAX),@BeginDateForPrint) + ' To: ' + CONVERT(NVARCHAR(MAX),@EndDateForPrint) + @NewLine + @NewLine

	DECLARE @Body NVARCHAR(MAX) = ''
	SELECT @Body = COALESCE(@Body + @NewLine + @NewLine, '') + (TNM.[Note]) FROM #TransactionsNotMatched TNM WITH (NOLOCK) ORDER BY [Note]

	IF LTRIM(ISNULL(@Body,'')) = '' SET @Body = 'Transactions for processing not found'

	DECLARE @Message NVARCHAR(MAX) = @Header + @Body

	EXEC msdb.dbo.sp_send_dbmail                          
                @profile_name=@EmailProfile,                                                     
                @recipients = @Recipients,                                                          
                @body = @Message,                                                           
                @subject = @MessageMail

	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Conciliation: End Load', GETDATE(),'')

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX) = ERROR_MESSAGE()
	SET @HasError = 1
	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Error in Conciliation', GETDATE(),ISNULL(@jsonResponse,'Json Null'))
	INSERT INTO [MAXILOG].[Regalii].[UpdateLog] ([Type],[CreationDate],[Detail]) VALUES ('Error in Conciliation', GETDATE(),ISNULL(CONVERT(NVARCHAR(MAX),@XmlTransactions),'XML Null'))
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES ('[Regalii].[st_DoConciliation]', GETDATE(), @ErrorMessage)
END CATCH
