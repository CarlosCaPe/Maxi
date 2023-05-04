-- =============================================
-- Author:		Francisco Lara
-- Create date: 2016-03-16
-- Description:	Returns Transfer from stand by to Kyc Hold in corporate (BackOffice.Si.Fulfillment.StandByToHold)
-- =============================================
CREATE PROCEDURE [dbo].[st_FindStandByToSendHoldWithFilters]
	-- Add the parameters for the stored procedure here
	@AgentId INT = 0
	, @FromDate DATETIME
	, @EndDate DATETIME
	, @CountryId INT = 0
	, @Filter NVARCHAR(MAX)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT @FromDate = dbo.RemoveTimeFromDatetime(@FromDate)                            
	SELECT @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)
	SET @Filter = '%' + LTRIM(ISNULL(@Filter,'')) + '%'
	IF @AgentId <= 0 SET @AgentId = NULL
	IF @CountryId <= 0 SET @CountryId = NULL

    -- Insert statements for procedure here
	SELECT TOP 1500
		T.[IdAgent]
		, A.[AgentCode]
		, T.[ClaimCode]
		, A.[AgentState]
		, A.[AgentName]
		, T.[DateOfTransfer]
		, T.[IdTransfer]
		, T.[Folio]
		, P.[PayerName]
		, T.[AmountInDollars]
		, T.[IdStatus]
		, S.[StatusName]
		, T.[IdCustomer]
		, LTRIM(ISNULL(T.[CustomerName],'') +' '+ ISNULL(T.[CustomerFirstLastName],'') + ' ' + ISNULL(T.[CustomerSecondLastName],'')) [CustomerName]
		, T.[IdBeneficiary]
		, LTRIM(ISNULL(T.[BeneficiaryName],'') +' '+ ISNULL(T.[BeneficiaryFirstLastName],'') + ' ' + ISNULL(T.[BeneficiarySecondLastName],'')) [BeneficiaryName]
		, NULL [LastReview]
		, NULL [IdDocumentTransfertStatus]
		, T.[IdGateway]
		, GAT.[GatewayName]
		, [dbo].[fnCustomerHadIdentification](T.[IdCustomer], T.[DateOfTransfer]) [CustomerHasIdentification]
		, ISNULL(C.[IdCountry],-1) [IdCountry]
		, ISNULL(C.[CountryName],'') [CountryName]
		,T.[CustomerAddress]
	FROM [dbo].[Transfer] T WITH (NOLOCK)
	INNER JOIN [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
	INNER JOIN [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
	INNER JOIN [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
	INNER JOIN [Gateway] GAT WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
	LEFT JOIN TransferDetail TDD WITH(NOLOCK) ON TDD.IdTransfer=T.IdTransfer and TDD.IdStatus in (12)
	LEFT JOIN TransferDetail TDK WITH(NOLOCK) ON TDK.IdTransfer=T.IdTransfer and TDK.IdStatus in (9)
	LEFT JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
	LEFT JOIN [dbo].[Country] C WITH (NOLOCK) ON CC.[IdCountry] = C.[IdCountry]
	WHERE T.[IdStatus] = 20
		AND T.[IdAgent] = ISNULL(@AgentId,T.[IdAgent])
		AND C.[IdCountry] = ISNULL(@CountryId,C.[IdCountry])
		AND T.[AmountInDollars] >= 500
		AND T.[DateOfTransfer] >= @FromDate
		AND T.[DateOfTransfer] < @EndDate
		AND TDD.[IdTransferDetail] IS NULL
		AND TDK.[IdTransferDetail] IS NULL
		AND (CONVERT(NVARCHAR(MAX),T.[Folio]) LIKE @Filter
			OR T.[ClaimCode] LIKE @Filter )
	ORDER BY T.[DateOfTransfer] DESC

END
