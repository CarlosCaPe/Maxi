/********************************************************************
<Author>jresendiz</Author>
<app>Corporate </app>
<Description></Description>

<ChangeLog>
<log Date="10/12/2018" Author="jresendiz"> Creado </log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_GetBillPayment] 
	@IdBillPayment int,
	@HasError BIT OUT,
	@Message NVARCHAR(MAX) OUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET @HasError = 1
	SET @Message = 'OK'
	BEGIN TRY
	SELECT 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN '1X' ELSE '1X0X' END AS [C1], 
    BPT.[IdBillPayment] AS [IdBillPayment], 
    BPT.[IdUser] AS [IdUser], 
    BPT.[IdAgent] AS [IdAgent], 
    BPT.[BillerPaymentProviderVendorId] AS [BillerPaymentProviderVendorId], 
    BPT.[MerchId] AS [MerchId], 
    BPT.[TrackingNumber] AS [TrackingNumber], 
    BPT.[ReferenceNumber] AS [ReferenceNumber], 
    BPT.[BatchNumber] AS [BatchNumber], 
    BPT.[PostingMessage] AS [PostingMessage], 
    BPT.[ReturnMessage] AS [ReturnMessage], 
    BPT.[ReceiptMessage] AS [ReceiptMessage], 
    BPT.[BillPaymentProviderResponse] AS [BillPaymentProviderResponse], 
    BPT.[AccountNumber] AS [AccountNumber], 
    BPT.[PaymentDate] AS [PaymentDate], 
    BPT.[ReceiptAmount] AS [ReceiptAmount], 
    BPT.[Status] AS [Status], 
    BPT.[AltAccountNumber] AS [AltAccountNumber], 
    BPT.[CustomField1] AS [CustomField1], 
    BPT.[CustomField2] AS [CustomField2], 
    BPT.[LastReturnMessage] AS [LastReturnMessage], 
    BPT.[LastReturnCode] AS [LastReturnCode], 
    BPT.[IdBiller] AS [IdBiller], 
    BPT.[CustomerLastName] AS [CustomerLastName], 
    BPT.[CustomerMiddleName] AS [CustomerMiddleName], 
    BPT.[CustomerFirstName] AS [CustomerFirstName], 
    BPT.[CustomerOccupation] AS [CustomerOccupation], 
    BPT.[CustomerAddress] AS [CustomerAddress], 
    BPT.[CustomerCity] AS [CustomerCity], 
    BPT.[CustomerState] AS [CustomerState], 
    BPT.[CustomerZip] AS [CustomerZip], 
    BPT.[CustomerTelephone] AS [CustomerTelephone], 
    BPT.[CustomerIdType] AS [CustomerIdType], 
    BPT.[CustomerIdIssuer] AS [CustomerIdIssuer], 
    BPT.[CustomerIdNumber] AS [CustomerIdNumber], 
    BPT.[CustomerSsn] AS [CustomerSsn], 
    BPT.[OnBehalf] AS [OnBehalf], 
    BPT.[BehalfLastName] AS [BehalfLastName], 
    BPT.[BehalfMiddleName] AS [BehalfMiddleName], 
    BPT.[BehalfFirstName] AS [BehalfFirstName], 
    BPT.[BehalfOccupation] AS [BehalfOccupation], 
    BPT.[BehalfAddress] AS [BehalfAddress], 
    BPT.[BehalfCity] AS [BehalfCity], 
    BPT.[BehalfState] AS [BehalfState], 
    BPT.[BehalfZip] AS [BehalfZip], 
    BPT.[BehalfTelephone] AS [BehalfTelephone], 
    BPT.[BehalfIdType] AS [BehalfIdType], 
    BPT.[BehalfIdIssuer] AS [BehalfIdIssuer], 
    BPT.[BehalfIdNumber] AS [BehalfIdNumber], 
    BPT.[BehalfSsn] AS [BehalfSsn], 
    BPT.[CustomerDob] AS [CustomerDob], 
    BPT.[BehalfDob] AS [BehalfDob], 
    BPT.[Fee] AS [Fee], 
    BPT.[BillPaymentProviderFee] AS [BillPaymentProviderFee], 
    BPT.[AgentCommission] AS [AgentCommission], 
    BPT.[CorpCommission] AS [CorpCommission], 
    BPT.[CancelUser] AS [CancelUser], 
    BPT.[CancelDate] AS [CancelDate], 
    BPT.[LastChange_LastUserChange] AS [LastChange_LastUserChange], 
    BPT.[LastChange_LastDateChange] AS [LastChange_LastDateChange], 
    BPT.[LastChange_LastIpChange] AS [LastChange_LastIpChange], 
    BPT.[LastChange_LastNoteChange] AS [LastChange_LastNoteChange], 
    BPT.[BillAccountId] AS [BillAccountId], 
    BPT.[CustomerId] AS [CustomerId], 
    BPT.[CellularNumber] AS [CellularNumber], 
    BPT.[IdCarrier] AS [IdCarrier], 
    BPT.[UpdatedFee] AS [UpdatedFee], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS varchar(1)) ELSE [Project1].[Description] END AS [C2], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[BillerGroupId] END AS [C3], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[BillerPaymentProviderId] END AS [C4], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS bit) ELSE [Project1].[DuplicateEntryFlag] END AS [C5], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[VendorAccountLengthMin] END AS [C6], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[VendorAccountLengthMax] END AS [C7], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS decimal(18,2)) ELSE [Project1].[VendorTranAmtMin] END AS [C8], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS decimal(18,2)) ELSE [Project1].[VendorTranAmtMax] END AS [C9], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS bit) ELSE [Project1].[CustomerNameRequired] END AS [C10], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS bit) ELSE [Project1].[SenderNameRequired] END AS [C11], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS decimal(18,2)) ELSE [Project1].[SenderRequiredAmountMin] END AS [C12], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS varchar(1)) ELSE [Project1].[PostingTimeMessage] END AS [C13], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS bit) ELSE [Project1].[PresentmentFlag] END AS [C14], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS bit) ELSE [Project1].[AcctNumOptional] END AS [C15], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS varchar(1)) ELSE [Project1].[AltLookupLabel] END AS [C16], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[AltLookupVisibleLen] END AS [C17], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[AltLookupMaxLen] END AS [C18], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS varchar(1)) ELSE [Project1].[AddInfoLabel1] END AS [C19], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS bit) ELSE [Project1].[AddInfoReqFlag1] END AS [C20], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS varchar(1)) ELSE [Project1].[AddInfoValType1] END AS [C21], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[AddInfoVisibleLen1] END AS [C22], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[AddInfoMaxLen1] END AS [C23], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS varchar(1)) ELSE [Project1].[AddInfoLabel2] END AS [C24], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS bit) ELSE [Project1].[AddInfoReqFlag2] END AS [C25], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS varchar(1)) ELSE [Project1].[AddInfoValType2] END AS [C26], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[AddInfoVisibleLen2] END AS [C27], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS int) ELSE [Project1].[AddInfoMaxLen2] END AS [C28], 
    CASE WHEN ( NOT (([Project1].[C1] = 1) AND ([Project1].[C1] IS NOT NULL))) THEN CAST(NULL AS bit) ELSE [Project1].[MaskAccountOnReceipt] END AS [C29]
    FROM  [dbo].[BillPaymentTransactions] AS BPT WITH(NOLOCK)
    LEFT OUTER JOIN  (SELECT 
        SBPT.[IdBillPayment] AS [IdBillPayment], 
        SBPT.[Description] AS [Description], 
        SBPT.[BillerGroupId] AS [BillerGroupId], 
        SBPT.[BillerPaymentProviderId] AS [BillerPaymentProviderId], 
        SBPT.[DuplicateEntryFlag] AS [DuplicateEntryFlag], 
        SBPT.[VendorAccountLengthMin] AS [VendorAccountLengthMin], 
        SBPT.[VendorAccountLengthMax] AS [VendorAccountLengthMax], 
        SBPT.[VendorTranAmtMin] AS [VendorTranAmtMin], 
        SBPT.[VendorTranAmtMax] AS [VendorTranAmtMax], 
        SBPT.[CustomerNameRequired] AS [CustomerNameRequired], 
        SBPT.[SenderNameRequired] AS [SenderNameRequired], 
        SBPT.[SenderRequiredAmountMin] AS [SenderRequiredAmountMin], 
        SBPT.[PostingTimeMessage] AS [PostingTimeMessage], 
        SBPT.[PresentmentFlag] AS [PresentmentFlag], 
        SBPT.[AcctNumOptional] AS [AcctNumOptional], 
        SBPT.[AltLookupLabel] AS [AltLookupLabel], 
        SBPT.[AltLookupVisibleLen] AS [AltLookupVisibleLen], 
        SBPT.[AltLookupMaxLen] AS [AltLookupMaxLen], 
        SBPT.[AddInfoLabel1] AS [AddInfoLabel1], 
        SBPT.[AddInfoReqFlag1] AS [AddInfoReqFlag1], 
        SBPT.[AddInfoValType1] AS [AddInfoValType1], 
        SBPT.[AddInfoVisibleLen1] AS [AddInfoVisibleLen1], 
        SBPT.[AddInfoMaxLen1] AS [AddInfoMaxLen1], 
        SBPT.[AddInfoLabel2] AS [AddInfoLabel2], 
        SBPT.[AddInfoReqFlag2] AS [AddInfoReqFlag2], 
        SBPT.[AddInfoValType2] AS [AddInfoValType2], 
        SBPT.[AddInfoVisibleLen2] AS [AddInfoVisibleLen2], 
        SBPT.[AddInfoMaxLen2] AS [AddInfoMaxLen2], 
        SBPT.[MaskAccountOnReceipt] AS [MaskAccountOnReceipt], 
        cast(1 as bit) AS [C1]
        FROM [dbo].[SoftgateBillPaymentTransactions] AS SBPT WITH(NOLOCK) ) AS [Project1] ON BPT.[IdBillPayment] = [Project1].[IdBillPayment]
		WHERE BPT.IdBillPayment = @IdBillPayment
	END TRY
	BEGIN CATCH
		SET @HasError = 1
		SET @Message = ERROR_MESSAGE()
	END CATCH
END

