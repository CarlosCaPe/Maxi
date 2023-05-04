
CREATE procedure [Operation].[st_SearchBillPayments]

(              
   
	@FromDate DATETIME,
	@ToDate DATETIME,
	@BillPaymentId BIGINT = NULL,
	@Account NVARCHAR(MAX) = NULL,
	@AgentId INT = NULL,
	@StatusId INT = NULL,
	@TrackingNumber NVARCHAR(MAX) = NULL,
	@CustomerLastName NVARCHAR(MAX) = NULL,
	@Biller NVARCHAR(MAX) = NULL,
	@FullResult BIT = 0,
	@ProviderId INT = -1,
	@HasError BIT OUTPUT,
	@Message NVARCHAR(MAX) OUTPUT,
	@ReferenceNumber NVARCHAR(MAX)= null

)

/********************************************************************
<Author> ??? </Author>
<app> Corporative </app>
<Description>Get TRansfer Other Products</Description>

<ChangeLog>
<log Date="01/02/2018" Author="snevarez"> Fix:Ticket 611: Excluir Bonus de la seccion Deposits, Credits and Charges en el reporte AgentBlance (no aplicado a produccion) </log>
<log Date="08/05/2018" Author="jmmolina">Se agrega validacion para los cheques de tipo CHNFS, para que no presnte amount #1 (Aplicado en Stage)</log>
<log Date="30/05/2018" Author="azavala,">Merge entre cambio Sergio y Molina </log>
<log Date="05/08/2018" Author="amoreno,">se agrega la consulta para los nuevos billers</log>>
<log Date="26/10/2018" Author="jdarellano" Name="#4">Ticket 1571.- Se agrega filtro por Trace Number (Tracking Number) para Fidelity.</log>>
<log Date="01/02/2018" Author="jdarellano" Name="#5">Se comenta linea para visualizar envios en "Origin" de Regalii.</log>
<log Date="08/02/2019" Author="Amoreno" Name="#6">Add FiServ Funcionality</log>>
<log Date="11/02/2019" Author="Amoreno" Name="#7">Update Fidelity Funcionality</log>>
<log Date="29/04/2019" Author="jdarellano" Name="#8">Fix de filtro por Tracking Number para Regalii.</log>>
<log Date="09/09/2019" Author="jdarellano" Name="#9">Se aplica cambio para muestra de pagos de bill con estatus "Origin" (Ticket 2005).</log>>
<log Date="15/10/2019" Author="jdarellano" Name="#10">Se aplica cambio para muestra de pagos de bill con estatus "Origin" para Regalii.</log>>
<log Date="07/01/2020" Author="jdarellano" Name="#11">Se aplica cambio para muestra de pagos de bill con estatus "Origin" para Fiserv.</log>>
</ChangeLog>
*********************************************************************/ 
AS
BEGIN

	DECLARE @Countrows INT -- almacenar el numero de resultados

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	-- SET NOCOUNT ON;

    -- Insert statements for procedure here

	IF @BillPaymentId <= 0 SET @BillPaymentId = NULL
	IF @Account = '' SET @Account = NULL
  IF @ReferenceNumber = '' SET @ReferenceNumber = NULL
	IF @AgentId <= 0 SET @AgentId = NULL
	IF @StatusId <= 0 SET @StatusId = NULL
	IF @TrackingNumber = '' SET @TrackingNumber = NULL
	IF @CustomerLastName = '' SET @CustomerLastName = NULL
	IF @Biller = '' SET @Biller = NULL

	IF @ProviderId = -1 SET @StatusId = NULL

	SET @HasError = 0
	SELECT @Message = dbo.GetMessageFromLenguajeResorces (0,35) -- Search was performed successfully

	SELECT @FromDate=dbo.RemoveTimeFromDatetime(@FromDate)
	SELECT @ToDate=dbo.RemoveTimeFromDatetime(@ToDate + 1)


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
		ProviderName NVARCHAR(MAX),
		UserName NVARCHAR(MAX),
		AgentState NVARCHAR(MAX),
	)
	
	IF @ProviderId = -1 OR @ProviderId = 1 -- Any provider or Softgate
	BEGIN
	--select @ReferenceNumber

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
                ,isnull(u.UserName,'') UserName
				, [A].[AgentState] 
			FROM [dbo].[BillPaymentTransactions] [BT] WITH (NOLOCK)
			JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [BT].[IdAgent] = [A].[IdAgent]
            LEFT JOIN users u (NOLOCK) ON bt.IdUser=u.IdUser
			WHERE
				[BT].[IdBillPayment] = ISNULL(@BillPaymentId, [BT].[IdBillPayment])
				AND [BT].[AccountNumber] = ISNULL(@Account, [BT].[AccountNumber])
		     	AND ( [BT].[ReferenceNumber] = ISNULL(@ReferenceNumber, [BT].[ReferenceNumber])  or
				 [BT].[MerchId] = ISNULL(@ReferenceNumber, [BT].[MerchId])  )
				AND [BT].[IdAgent] = ISNULL(@AgentId, [BT].[IdAgent])
				AND [BT].[Status] = ISNULL(@StatusId, [BT].[Status])
				AND [BT].[Status] != -1
				AND [BT].[PaymentDate] >= @FromDate
				AND [BT].[PaymentDate] < @ToDate
				AND [BT].[TrackingNumber] = ISNULL(@TrackingNumber, [BT].[TrackingNumber])
				AND [BT].[CustomerLastName] = ISNULL(@CustomerLastName, [BT].[CustomerLastName])
				AND [BT].[BillerPaymentProviderVendorId] like '%' + ISNULL(@Biller, [BT].[BillerPaymentProviderVendorId]) + '%'
	END

	IF @ProviderId = -1 OR @ProviderId = 14 -- Any provider or Regalii
	BEGIN

		DECLARE @RegaliiBiller NVARCHAR(MAX)
		EXEC [dbo].[st_GetGlobalAttributeValueByName] 'RegaliiBillerTypeCell', @RegaliiBiller OUTPUT


 IF @ReferenceNumber is null 
  BEGIN 
		--set @Biller = isnull(@Biller, '')--#04

		if (@TrackingNumber is NULL)--#10
		begin
			INSERT INTO #BillPaymentsProducts
				SELECT
					[TR].[Account_Number]
					, [TR].[Name]
					, [TR].[Fee]
					, [TR].[IdProductTransfer]
					, [TR].[DateOfCreation]
					, '' [ReferenceNumber]
					, [TR].[ProviderId] [TrackingNumber]
					, [TR].[Amount] + TR.[Fee] [TotalAmount]
					, '' [MerchId]
					, [TR].[IdStatus]
					, [S].[StatusName]
					, [A].[IdAgent]
					, [A].[AgentName]
					, [A].[AgentCode]
					,14 [ProviderId]
					,'Regalii' [ProviderName]
					,isnull(u.UserName,'') UserName
					, [A].[AgentState] 
				FROM [Regalii].[TransferR] [TR] WITH (NOLOCK)
				JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [TR].[IdAgent] = [A].[IdAgent]
				JOIN [dbo].[Status] [S] WITH (NOLOCK) ON [TR].[IdStatus] = [S].[IdStatus]
				LEFT JOIN [dbo].[Users] [U] (NOLOCK) ON tr.EnterByIdUser=u.IdUser
				WHERE
					[TR].[IdProductTransfer] = ISNULL(@BillPaymentId, [TR].[IdProductTransfer])
					AND [TR].[Account_Number] = ISNULL(@Account, [TR].[Account_Number])				
					AND [A].[IdAgent] = ISNULL(@AgentId, [A].[IdAgent])
					AND [TR].[IdStatus] = ISNULL(@StatusId, [TR].[IdStatus])
					AND [TR].[IdStatus] != -1
					AND [TR].[DateOfCreation] >= @FromDate
					AND [TR].[DateOfCreation] < @ToDate
					--AND [TR].[ProviderId] = ISNULL(@TrackingNumber, [TR].[ProviderId])--#5
					--AND [TR].[ProviderId] = ISNULL(@TrackingNumber, [TR].[ProviderId])--#5--#8--#10
					AND [TR].[CustomerFirstLastName] = ISNULL(@CustomerLastName, [TR].[CustomerFirstLastName])
					AND [TR].[Name] like '%[' + ISNULL(@Biller,[TR].[Name]) + ']%'--#04
					--AND [TR].[Name] like '%' + ISNULL(@Biller,LTRIM(RTRIM([TR].[Name]))) + '%'--#04
					--AND [TR].[Name] like '%' + @Biller + '%'--#04
					AND [tr].[BillerType] != @RegaliiBiller
		end
		else--#10
		begin
			INSERT INTO #BillPaymentsProducts
				SELECT
					[TR].[Account_Number]
					, [TR].[Name]
					, [TR].[Fee]
					, [TR].[IdProductTransfer]
					, [TR].[DateOfCreation]
					, '' [ReferenceNumber]
					, [TR].[ProviderId] [TrackingNumber]
					, [TR].[Amount] + TR.[Fee] [TotalAmount]
					, '' [MerchId]
					, [TR].[IdStatus]
					, [S].[StatusName]
					, [A].[IdAgent]
					, [A].[AgentName]
					, [A].[AgentCode]
					,14 [ProviderId]
					,'Regalii' [ProviderName]
					,isnull(u.UserName,'') UserName
					, [A].[AgentState] 
				FROM [Regalii].[TransferR] [TR] WITH (NOLOCK)
				JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [TR].[IdAgent] = [A].[IdAgent]
				JOIN [dbo].[Status] [S] WITH (NOLOCK) ON [TR].[IdStatus] = [S].[IdStatus]
				LEFT JOIN [dbo].[Users] [U] (NOLOCK) ON tr.EnterByIdUser=u.IdUser
				WHERE
					[TR].[IdProductTransfer] = ISNULL(@BillPaymentId, [TR].[IdProductTransfer])
					AND [TR].[Account_Number] = ISNULL(@Account, [TR].[Account_Number])				
					AND [A].[IdAgent] = ISNULL(@AgentId, [A].[IdAgent])
					AND [TR].[IdStatus] = ISNULL(@StatusId, [TR].[IdStatus])
					AND [TR].[IdStatus] != -1
					AND [TR].[DateOfCreation] >= @FromDate
					AND [TR].[DateOfCreation] < @ToDate
					--AND [TR].[ProviderId] = ISNULL(@TrackingNumber, [TR].[ProviderId])--#5
					AND [TR].[ProviderId] = @TrackingNumber--#10
					AND [TR].[CustomerFirstLastName] = ISNULL(@CustomerLastName, [TR].[CustomerFirstLastName])
					AND [TR].[Name] like '%[' + ISNULL(@Biller,[TR].[Name]) + ']%'--#04
					--AND [TR].[Name] like '%' + ISNULL(@Biller,LTRIM(RTRIM([TR].[Name]))) + '%'--#04
					--AND [TR].[Name] like '%' + @Biller + '%'--#04
					AND [tr].[BillerType] != @RegaliiBiller
		end
      END 
	END

	IF @ProviderId = -1 OR @ProviderId = 18 -- Any provider or Fidelity
	BEGIN

		 
		--set @Biller = isnull(@Biller, '')--#04
		--select @BillPaymentId as BillPaymentId,@ProviderId as ProviderId, @Account as Account,@AgentId as AgentId,@StatusId as StatusId, @ReferenceNumber as ReferenceNumber,@FromDate as FromDate,@ToDate as ToDate,@TrackingNumber as TrackingNumber,@CustomerLastName as CustomerLastName, @Biller as Biller

   		INSERT INTO #BillPaymentsProducts
			SELECT
				[TR].[Account_Number]
				, [TR].[Name]
				, [TR].[Fee]
				, [TR].[IdProductTransfer]
				, [TR].[DateOfCreation]
				, '' [ReferenceNumber]
				, [TR].[TraceNumber] [TrackingNumber]
				, [TR].[Amount] + TR.[Fee] [TotalAmount]
				, '' [MerchId]
				, [TR].[IdStatus]
				, [S].[StatusName]
				, [A].[IdAgent]
				, [A].[AgentName]
				, [A].[AgentCode]
				, [ProviderId] = 18
				, [ProviderName] = (select Description from OtherProducts where IdOtherProducts= 18  )
                ,isnull(u.UserName,'') UserName
				, [A].[AgentState] 
			FROM [BillPayment].[TransferR] [TR] WITH (NOLOCK)
			JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [TR].[IdAgent] = [A].[IdAgent]
			JOIN [dbo].[Status] [S] WITH (NOLOCK) ON [TR].[IdStatus] = [S].[IdStatus]
            LEFT JOIN [dbo].[Users] [U] (NOLOCK) ON tr.EnterByIdUser=u.IdUser
      inner join  --#7 {
           BillPayment.Billers B with (nolock) 
       on 
          B.idbiller= [TR].Idbiller
      and B.idAggregator = (select A.IdAggregator from BillPayment.Aggregator A with (nolock) where A.IdAggregator = B.IdAggregator and A.IdOtherProducts=18)  --#7 }
			WHERE
				[TR].[IdProductTransfer] = ISNULL(@BillPaymentId, [TR].[IdProductTransfer])
				AND [TR].[Account_Number] = ISNULL(@Account, [TR].[Account_Number])				
				AND [A].[IdAgent] = ISNULL(@AgentId, [A].[IdAgent])
				AND [TR].[IdStatus] = ISNULL(@StatusId, [TR].[IdStatus])
				AND [TR].[IdStatus] != -1
				AND [TR].[DateOfCreation] >= @FromDate
				AND [TR].[DateOfCreation] < @ToDate
				AND [TR].[TraceNumber] = ISNULL(@TrackingNumber, [TR].[TraceNumber])--#4
				AND [TR].[CustomerFirstLastName] = ISNULL(@CustomerLastName, [TR].[CustomerFirstLastName])
				--and [TR].IdStatus <> 1--#9
      END 



 IF @ProviderId = -1 OR @ProviderId = 19 -- Any provider or FiServ #6 {
	BEGIN


   		INSERT INTO #BillPaymentsProducts
			SELECT
				[TR].[Account_Number]
				, [TR].[Name]
				, [TR].[Fee]
				, [TR].[IdProductTransfer]
				, [TR].[DateOfCreation]
				, [ReferenceNumber] ='' 
				, [TR].[TraceNumber] [TrackingNumber]
				, [TR].[Amount] + TR.[Fee] [TotalAmount]
				, [MerchId] = '' 
				, [TR].[IdStatus]
				, [S].[StatusName]
				, [A].[IdAgent]
				, [A].[AgentName]
				, [A].[AgentCode]
				, [ProviderId] = 19
				, [ProviderName] = (select Description from OtherProducts where IdOtherProducts= 19)
         ,UserName = isnull(u.UserName,'') 
				, [A].[AgentState] 
			FROM [BillPayment].[TransferR] [TR] WITH (NOLOCK)
			JOIN [dbo].[Agent] [A] WITH (NOLOCK) ON [TR].[IdAgent] = [A].[IdAgent]
			JOIN [dbo].[Status] [S] WITH (NOLOCK) ON [TR].[IdStatus] = [S].[IdStatus]
            LEFT JOIN [dbo].[Users] [U] (NOLOCK) ON tr.EnterByIdUser=u.IdUser
      inner join 
           BillPayment.Billers B with (nolock) 
       on 
          B.idbiller= [TR].Idbiller
      and B.idAggregator = (select A.IdAggregator from BillPayment.Aggregator A with (nolock) where A.IdAggregator = B.IdAggregator and A.IdOtherProducts=19) 
                       
			WHERE
				[TR].[IdProductTransfer] = ISNULL(@BillPaymentId, [TR].[IdProductTransfer])
				AND [TR].[Account_Number] = ISNULL(@Account, [TR].[Account_Number])				
				AND [A].[IdAgent] = ISNULL(@AgentId, [A].[IdAgent])
				AND [TR].[IdStatus] = ISNULL(@StatusId, [TR].[IdStatus])
				AND [TR].[IdStatus] != -1
				AND [TR].[DateOfCreation] >= @FromDate
				AND [TR].[DateOfCreation] < @ToDate
				AND [TR].[TraceNumber] = ISNULL(@TrackingNumber, [TR].[TraceNumber])
				AND [TR].[CustomerFirstLastName] = ISNULL(@CustomerLastName, [TR].[CustomerFirstLastName])
				--and [TR].IdStatus <> 1--#11
      END 
  --}#6

  

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
                ,UserName
				,[AgentState]
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
                    ,UserName
				    ,[AgentState]
				FROM #BillPaymentsProducts ORDER BY [PaymentDate] DESC
		END


end