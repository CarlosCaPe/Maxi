-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-01-16
-- Description:	This stored is used in corporate, transaction rejected report
-- =============================================
CREATE PROCEDURE [dbo].[st_ReportTransferRejectedByHold]
(
    @BeginDate DATETIME,
    @EndDate DATETIME,
    @IdStatus INT = NULL,
    @IdLenguage INT = NULL,
    @HasError BIT OUTPUT,
    @Message NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	DECLARE @IdStatusKYC INT
	DECLARE @IdStatusDeny INT
	DECLARE @TransferRejected TABLE(
		[IdTransfer] INT
		, [RejectedUserId] INT
	)
	DECLARE @TransferCloseRejected TABLE(
		[IdTransfer] INT
		, [RejectedUserId] INT
	)

	DECLARE @TransferRejectedOut TABLE
	(
		[IdTransfer] INT,
		[DateOfTransfer] DATETIME,
		[ClaimCode] NVARCHAR(MAX),
		[Folio] INT,
		[IdAgent] INT,
		[AgentCode] NVARCHAR(MAX),
		[AgentName] NVARCHAR(MAX),
		[AmountInDollars] MONEY,
		[AmountInMN] MONEY,
		[IdPaymentType] INT,
		[PaymentTypeName] NVARCHAR(MAX),
		[Sender] NVARCHAR(MAX),
		[Beneficiary] NVARCHAR(MAX),
		[IdStatus] INT,
		[StatusName] NVARCHAR(MAX),
		[DateStatusChange] DATETIME,
		[IdPayer] INT,
		[PayerName] NVARCHAR(MAX),
		[IdGateway] INT,
		[GatewayName] NVARCHAR(MAX),
		[IdCountryCurrency] INT,
		[CountryName] NVARCHAR(MAX),
		[CurrencyName] NVARCHAR(MAX),
		[RejectedHold] NVARCHAR(MAX),
		[RejectedUser] NVARCHAR(MAX),
		[Note] NVARCHAR(MAX),
		[FromStandByToKYC] BIT
	)


	--Asignacion de valores
	SELECT @BeginDate = dbo.RemoveTimeFromDatetime(@BeginDate)
	SELECT @EndDate = dbo.RemoveTimeFromDatetime(@EndDate) + 1

	IF @IdLenguage IS NULL SET @IdLenguage = 1

	SELECT @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHOK'), @HasError = 0

	SET @IdStatusKYC = CASE
							WHEN @IdStatus IS NULL THEN 9 
							WHEN @IdStatus = 9 THEN @IdStatus
							ELSE -1
						END

	SET @IdStatusDeny = CASE 
							WHEN @IdStatus is null then 12 
							WHEN @IdStatus = 12 then @IdStatus
							ELSE -1
						END

	INSERT INTO @TransferRejected
		SELECT
			[IdTransfer]
			, [EnterByIdUser]
		FROM [dbo].[TransferHolds]
		WHERE [IdStatus] = @IdStatusKYC AND [IsReleased] = 0 AND [DateOfLastChange] >= @BeginDate AND [DateOfLastChange] < @EndDate
		UNION ALL
		SELECT
			[IdTransfer]
			, [EnterByIdUser]
		FROM [dbo].[TransferHolds]
		WHERE [IdStatus]=@IdStatusDeny AND [IsReleased] = 0 AND [DateOfLastChange] >= @BeginDate AND [DateOfLastChange] < @EndDate
	
	INSERT INTO @TransferCloseRejected
		SELECT
			[IdTransferclosed]
			, [EnterByIdUser]
		FROM [dbo].[TransferclosedHolds]
		WHERE [IdStatus] = @IdStatusKYC AND [IsReleased] = 0 AND [DateOfLastChange] >= @BeginDate AND [DateOfLastChange] < @EndDate
		UNION ALL
		SELECT
			[IdTransferclosed]
			, [EnterByIdUser]
		FROM [dbo].[TransferclosedHolds]
		WHERE [IdStatus] = @IdStatusDeny AND [IsReleased] = 0 AND [DateOfLastChange] >= @BeginDate AND [DateOfLastChange] < @EndDate

	IF ((SELECT COUNT(1) FROM @TransferRejected) + (SELECT COUNT(1) FROM @TransferCloseRejected))  < 3000
	BEGIN
		INSERT INTO @TransferRejectedOut(
			[IdTransfer]
			, [DateOfTransfer]
			, [ClaimCode]
			, [Folio]
			, [IdAgent]
			, [AgentCode]
			, [AgentName]
			, [AmountInDollars]
			, [AmountInMN]
			, [IdPaymentType]
			, [PaymentTypeName]
			, [Sender]
			, [Beneficiary]
			, [IdStatus]
			, [StatusName]
			, [DateStatusChange]
			, [IdPayer]
			, [PayerName]
			, [IdGateway]
			, [GatewayName]
			, [IdCountryCurrency]
			, [CountryName]
			, [CurrencyName]
			, [RejectedHold]
			, [RejectedUser]
			, [Note]
			, [FromStandByToKYC])
		SELECT 
			T.[IdTransfer],
			T.[DateOfTransfer],
			T.[ClaimCode],
			T.[Folio],
			T.[IdAgent],
			A.[AgentCode],
			A.[AgentName],
			T.[AmountInDollars],
			T.[AmountInMN],
			T.[IdPaymentType],
			P.[PaymentName] PaymentTypeName,
			T.[CustomerName] + ' ' + T.[CustomerFirstLastName] + ' ' + T.[CustomerSecondLastName] [Sender],
			T.[BeneficiaryName] + ' ' + T.[BeneficiaryFirstLastName] + ' ' + T.[BeneficiarySecondLastName] [Beneficiary],
			T.[IdStatus],
			S1.[StatusName],
			T.[DateStatusChange],
			T.[IdPayer],
			PA.[PayerName],
			T.[IdGateway],
			G.[GatewayName],
			T.[IdCountryCurrency],
			C.[CountryName],
			CU.[CurrencyName],
			CASE
				WHEN EXISTS (SELECT TOP 1 1 FROM [dbo].[TransferHolds] WHERE [IdStatus] = @IdStatusKYC AND [IdTransfer] = T.[IdTransfer] AND [IsReleased] = 0) THEN ISNULL(S2.[StatusName],'')
				WHEN EXISTS (SELECT TOP 1 1 FROM [dbo].[TransferHolds] WHERE [IdStatus] = @IdStatusDeny AND [IdTransfer] = T.[IdTransfer] AND [IsReleased] = 0) THEN ISNULL(S3.[StatusName],'')
				ELSE ''
			END [RejectedHold],
			U.[UserName],
			ISNULL(TN.[Note],''),
			T.[FromStandByToKYC]
		FROM [dbo].[transfer] T
		JOIN [dbo].[Agent] A ON T.[IdAgent] = A.[IdAgent]
		JOIN [dbo].[PaymentType] P ON T.[IdPaymentType] = P.[IdPaymentType]
		JOIN [dbo].[Status] S1 ON T.[IdStatus] = S1.[IdStatus]
		LEFT JOIN [dbo].[Status] S2 ON @IdStatusKYC = S2.[IdStatus]
		LEFT JOIN [dbo].[Status] S3 (nolock) on @IdStatusDeny=s3.IdStatus
		JOIN [dbo].[Payer] PA ON T.[IdPayer] = PA.[IdPayer]
		JOIN [dbo].[Gateway] G ON T.[IdGateway] = G.[IdGateway]
		JOIN [dbo].[CountryCurrency] CC ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
		JOIN [dbo].[Country] C ON CC.[IdCountry] = C.[IdCountry]
		JOIN [dbo].[Currency] CU ON CC.[IdCurrency] = CU.[IdCurrency]
		JOIN @TransferRejected TR ON T.[IdTransfer] = TR.[IdTransfer]
		JOIN [dbo].[Users] U ON TR.[RejectedUserId] = U.[IdUser]
		JOIN (
			SELECT L.[IdTransfer], L.[IdTransferDetail], MIN(TN.[IdTransferNote]) [IdTransferNote]
			FROM (
				SELECT TD.[IdTransfer], MIN(TD.[IdTransferDetail]) [IdTransferDetail]
				FROM [dbo].[TransferDetail] TD
				WHERE TD.[IdStatus] = 31
				GROUP BY TD.[IdTransfer] ) L
			JOIN [dbo].[TransferNote] TN ON L.[IdTransferDetail] = TN.[IdTransferDetail]
			GROUP BY L.[IdTransfer], L.[IdTransferDetail]
			) M ON T.[IdTransfer] = M.[IdTransfer]
		LEFT JOIN [dbo].[TransferNote] TN ON M.[IdTransferNote] = TN.[IdTransferNote]
		WHERE
			T.[DateStatusChange] >= @BeginDate
			AND T.[DateStatusChange] < @EndDate
			--AND t.IdTransfer in (SELECT [IdTransfer] FROM @TransferRejected)
		UNION ALL
		SELECT 
			T.[IdTransferClosed] [IdTransfer],
			T.[DateOfTransfer],
			T.[ClaimCode],
			T.[Folio],
			T.[IdAgent],
			A.[AgentCode],
			A.[AgentName],
			T.[AmountInDollars],
			T.[AmountInMN],
			T.[IdPaymentType],
			T.[PaymentTypeName],
			T.[CustomerName] + ' ' + T.[CustomerFirstLastName] + ' ' + T.[CustomerSecondLastName] [Sender],
			T.[BeneficiaryName] + ' ' + T.[BeneficiaryFirstLastName] + ' ' + T.[BeneficiarySecondLastName] [Beneficiary],
			T.[IdStatus],
			T.[StatusName],
			T.[DateStatusChange],
			T.[IdPayer],
			T.[PayerName],
			T.[IdGateway],
			T.[GatewayName],
			T.[IdCountryCurrency],
			T.[CountryName],
			T.[CurrencyName],
			CASE
				WHEN EXISTS (SELECT TOP 1 1 FROM [dbo].[TransferClosedHolds] WHERE [IdStatus] = @IdStatusKYC AND [IdTransferClosed] = T.[IdTransferClosed] AND [IsReleased] = 0) THEN ISNULL(S2.[StatusName],'')
				WHEN EXISTS (SELECT TOP 1 1 FROM [dbo].[TransferClosedHolds] WHERE [IdStatus] = @IdStatusDeny AND [IdTransferClosed] = T.[IdTransferClosed] AND [IsReleased] = 0) THEN ISNULL(S3.[StatusName],'')
				ELSE ''
			END [RejectedHold],
			U.[UserName],
			ISNULL(TN.[Note],''),
			T.[FromStandByToKYC]
		FROM [dbo].[TransferClosed] T
		JOIN [dbo].[Agent] A ON T.[IdAgent] = A.[IdAgent]
		LEFT JOIN [dbo].[Status] S2 ON @IdStatusKYC=S2.[IdStatus]
		LEFT JOIN [dbo].[Status] S3 ON @IdStatusDeny=S3.[IdStatus]
		JOIN @TransferCloseRejected TCR ON T.[IdTransferClosed] = TCR.[IdTransfer]
		JOIN [dbo].[Users] U ON TCR.[RejectedUserId] = U.[IdUser]
		JOIN (
			SELECT L.[IdTransferClosed], L.[IdTransferClosedDetail], MIN(TN.[IdTransferClosedNote]) [IdTransferClosedNote]
			FROM (
				SELECT TD.[IdTransferClosed], MIN(TD.[IdTransferClosedDetail]) [IdTransferClosedDetail]
				FROM [dbo].[TransferClosedDetail] TD
				WHERE TD.[IdStatus] = 31
				GROUP BY TD.[IdTransferClosed] ) L
			JOIN [dbo].[TransferClosedNote] TN ON L.[IdTransferClosedDetail] = TN.[IdTransferClosedDetail]
			GROUP BY L.[IdTransferClosed], L.[IdTransferClosedDetail]
			) M ON T.[IdTransferClosed] = M.[IdTransferClosed]
		LEFT JOIN [dbo].[TransferClosedNote] TN ON M.[IdTransferClosedNote] = TN.[IdTransferClosedNote]
		WHERE
			T.[DateStatusChange] >= @BeginDate
			AND T.[DateStatusChange] < @EndDate
			--AND T.[IdTransferClosed] IN (SELECT [IdTransfer] FROM @TransferRejected)
	END
	ELSE
	BEGIN
		SELECT @Message = [dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'SEARCHERROR'), @HasError = 1
	END

	DECLARE @TempCounts TABLE(
		[IdAgent] INT,
		[RejectCount] INT
	)

	INSERT INTO @TempCounts
		SELECT
			[IdAgent],
			COUNT([IdAgent]) [RejectCount]
		FROM @TransferRejectedOut
		GROUP BY [IdAgent]

	SELECT
		TRO.[IdTransfer]
		, TRO.[DateOfTransfer]
		, TRO.[ClaimCode]
		, TRO.[Folio]
		, TRO.[IdAgent]
		, TRO.[AgentCode]
		, TRO.[AgentName]
		, TRO.[AmountInDollars]
		, TRO.[AmountInMN]
		, TRO.[IdPaymentType]
		, TRO.[PaymentTypeName]
		, TRO.[Sender]
		, TRO.[Beneficiary]
		, TRO.[IdStatus]
		, TRO.[StatusName]
		, TRO.[DateStatusChange]
		, TRO.[IdPayer]
		, TRO.[PayerName]
		, TRO.[IdGateway]
		, TRO.[GatewayName]
		, TRO.[IdCountryCurrency]
		, TRO.[CountryName]
		, TRO.[CurrencyName]
		, TRO.[RejectedHold]
		, TRO.[RejectedUser]
		, TRO.[Note]
		, ISNULL(TMC.[RejectCount], 0) [RejectCount]
		, TRO.[FromStandByToKYC]
	FROM @TransferRejectedOut TRO
	JOIN @TempCounts TMC ON TRO.[IdAgent] = TMC.[IdAgent]
	ORDER BY [DateOfTransfer] DESC

END