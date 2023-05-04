-- =============================================
-- Author:		Francisco Lara
-- Create date: 2015-10-11
-- Description:	BillPayments search with filters
-- =============================================
CREATE PROCEDURE [Operation].[st_SearchBillPaymentsAgent]
	-- Add the parameters for the stored procedure here
	@FromDate DATETIME,
	@ToDate DATETIME,
	@BillPaymentId BIGINT = NULL,
	@Account NVARCHAR(MAX) = NULL,
	@AgentId INT = NULL,
	@ProviderStatusXml XML = NULL,
	@TrackingNumber NVARCHAR(MAX) = NULL,
	@CustomerLastName NVARCHAR(MAX) = NULL,
	@FullResult BIT = 0,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT

AS
BEGIN

	declare @Countrows int -- almacenar el numero de resultados

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF @BillPaymentId <= 0 SET @BillPaymentId = NULL
	IF @Account = '' SET @Account = NULL
	IF @AgentId <= 0 SET @AgentId = NULL
	IF @TrackingNumber = '' SET @TrackingNumber = NULL
	IF @CustomerLastName = '' SET @CustomerLastName = NULL

	SET @HasError = 0
	SELECT @Message = dbo.GetMessageFromLenguajeResorces (0,35) -- Search was performed successfully

	Select @FromDate=dbo.RemoveTimeFromDatetime(@FromDate)
	Select @ToDate=dbo.RemoveTimeFromDatetime(@ToDate + 1)

	DECLARE @ProviderStatusTable AS TABLE(
		[ProviderId] INT,
		[StatusId] INT
	)

	DECLARE @DocHandle INT
	EXEC sp_xml_preparedocument @DocHandle OUTPUT, @ProviderStatusXml

	INSERT INTO @ProviderStatusTable ([ProviderId],[StatusId])
		SELECT Id, Name FROM OPENXML(@DocHandle, '/Catalogs/Catalog', 2)
		WITH (Id INT, Name INT)

	EXEC sp_xml_removedocument @DocHandle

	CREATE TABLE #BillPaymentsProducts(
	AccountNumber NVARCHAR(MAX),
	BillerPaymentProviderVendorId NVARCHAR(MAX),
	Fee MONEY,
	IdBillPayment BIGINT,
	PaymentDate DATETIME,
	ReferenceNumber NVARCHAR(MAX),
	TrackingNumber NVARCHAR(MAX),
	TotalAmount MONEY,
	MerchId INT,
	StatusId INT,
	StatusName NVARCHAR(MAX),
	IdAgent INT,
	AgentName NVARCHAR(MAX),
	AgentCode NVARCHAR(MAX),
	ProviderId INT,
	ProviderName NVARCHAR(MAX)
	)
	
	--DECLARE @ProviderId INT
	--DECLARE @StatusId INT

	--WHILE EXISTS(SELECT TOP 1 1 FROM @ProviderStatusTable)
	--BEGIN
	--	SELECT TOP 1 @ProviderId = [ProviderId], @StatusId = [StatusId] FROM @ProviderStatusTable
	--	DELETE FROM @ProviderStatusTable WHERE [ProviderId] = @ProviderId AND [StatusId] = @StatusId
		

	--IF @ProviderId = -1 OR @ProviderId = 1 -- Any provider or Softgate
	--BEGIN

	DECLARE @RegaliiBiller NVARCHAR(MAX)
	EXEC [dbo].[st_GetGlobalAttributeValueByName] 'RegaliiBillerTypeCell', @RegaliiBiller OUTPUT

	INSERT INTO #BillPaymentsProducts
		SELECT
			[BT].[AccountNumber]
			,[BT].[BillerPaymentProviderVendorId]
			,[BT].[Fee]
			,[BT].[IdBillPayment]
			,[BT].[PaymentDate]
			,[BT].[ReferenceNumber]
			,[BT].[TrackingNumber]
			,[BT].[ReceiptAmount] + [BT].[Fee] [TotalAmount]
			,[BT].[MerchId]
			,[BT].[Status] [StatusId]
			,CASE [BT].[Status] WHEN 1 THEN 'Active' ELSE 'Cancelled' END [StatusName]
			,[A].[IdAgent]
			,[A].[AgentName]
			,[A].[AgentCode]
			,1 'ProviderId'
			,'Softgate' 'ProviderName'
		FROM [dbo].[BillPaymentTransactions] [BT] WITH (NOLOCK)
		JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [BT].[IdAgent] = [A].[IdAgent]
		JOIN @ProviderStatusTable [P] ON [BT].[Status] = [P].[StatusId] AND [P].[ProviderId] = 1
		WHERE
			[BT].[IdBillPayment] = ISNULL(@BillPaymentId, [BT].[IdBillPayment])
			AND [BT].[AccountNumber] = ISNULL(@Account, [BT].[AccountNumber])
			AND [BT].[IdAgent] = ISNULL(@AgentId, [BT].[IdAgent])
			AND [BT].[Status] != -1
			AND [BT].[PaymentDate] >= @FromDate
			AND [BT].[PaymentDate] < @ToDate
			AND [BT].[TrackingNumber] = ISNULL(@TrackingNumber, [BT].[TrackingNumber])
			AND [BT].[CustomerLastName] = ISNULL(@CustomerLastName, [BT].[CustomerLastName])
	--END

		UNION ALL

	--IF @ProviderId = -1 OR @ProviderId = 14 -- Any provider or Regalii
	--BEGIN
	--INSERT INTO #BillPaymentsProducts
		SELECT
			[TR].[Account_Number]
			, [B].[Name]
			, [TR].[Fee]
			, [TR].[IdProductTransfer]
			, [TR].[DateOfCreation]
			, '' 'ReferenceNumber'
			, [TR].[ProviderId] 'TrackingNumber'
			, [TR].[Amount] + TR.[Fee] 'TotalAmount'
			, '' 'MerchId'
			, [TR].[IdStatus]
			, [S].[StatusName]
			, [A].[IdAgent]
			, [A].[AgentName]
			, [A].[AgentCode]
			,14 'ProviderId'
			,'Regalii' 'ProviderName'
		FROM [Regalii].[TransferR] [TR] WITH (NOLOCK)
		JOIN @ProviderStatusTable [P] ON [TR].[IdStatus] = [P].[StatusId] AND [P].[ProviderId] = 14
		JOIN [Regalii].[Billers] [B] WITH (NOLOCK) ON [TR].[IdBiller] = [B].[IdBiller]
		JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [TR].[IdAgent] = [A].[IdAgent]
		JOIN [dbo].[Status] [S] WITH (NOLOCK) ON [TR].[IdStatus] = [S].[IdStatus]
		WHERE
			[TR].[IdProductTransfer] = ISNULL(@BillPaymentId, [TR].[IdProductTransfer])
			AND [TR].[Account_Number] = ISNULL(@Account, [TR].[Account_Number])
			AND [A].[IdAgent] = ISNULL(@AgentId, [A].[IdAgent])
			AND [TR].[IdStatus] != -1
			AND [TR].[DateOfCreation] >= @FromDate
			AND [TR].[DateOfCreation] < @ToDate
			AND [TR].[ProviderId] = ISNULL(@TrackingNumber, [TR].[ProviderId])
			AND [TR].[CustomerFirstLastName] = ISNULL(@CustomerLastName, [TR].[CustomerFirstLastName])
			AND [tr].[BillerType] != @RegaliiBiller

	--END

	SELECT @Countrows = COUNT(1) FROM #BillPaymentsProducts

	if @FullResult = 0  -- se revisa si se deben de regresar sin importa el numero de resultados
		BEGIN
			IF @Countrows <= 3000
			SELECT
				[AccountNumber]
				,[BillerPaymentProviderVendorId]
				,[Fee]
				,[IdBillPayment]
				,[PaymentDate]
				,[ReferenceNumber]
				,[TrackingNumber]
				,[TotalAmount]
				,[MerchId]
				,[StatusId]
				,[StatusName]
				,[IdAgent]
				,[AgentName]
				,[AgentCode]
				,[ProviderId]
				,[ProviderName]
			FROM #BillPaymentsProducts ORDER BY [PaymentDate] DESC
			ELSE
			BEGIN
				SET @HasError = 1
				SELECT @Message = dbo.GetMessageFromLenguajeResorces (0,34) -- Error, Increase your filters, Result is too big to be displayed
			END
		END
	ELSE
		BEGIN
			SELECT
					[AccountNumber]
					,[BillerPaymentProviderVendorId]
					,[Fee]
					,[IdBillPayment]
					,[PaymentDate]
					,[ReferenceNumber]
					,[TrackingNumber]
					,[TotalAmount]
					,[MerchId]
					,[StatusId]
					,[StatusName]
					,[IdAgent]
					,[AgentName]
					,[AgentCode]
					,[ProviderId]
					,[ProviderName]
				FROM #BillPaymentsProducts ORDER BY [PaymentDate] DESC
		END
END
