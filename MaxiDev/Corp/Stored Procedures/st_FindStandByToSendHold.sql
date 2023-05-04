CREATE PROCEDURE [Corp].[st_FindStandByToSendHold]

AS

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="20/11/2018" Author="jdarellano" Name="#1">A solicitud de Gerardo González, se modifica filtro de monto mayor o igual a 500 dólares, a 200 (Ticket 1637).</log>
<log Date="19/09/2019" Author="erojas" ChangeIdentifier="DEPOSITHOLD">A solicitud de MAXI incluir tambien los envios en status DEPOSIT HOLD (IdStatus = 18). NOTA: Se cambio la sentencia WHERE T.[IdStatus] = 20 a WHERE T.IdStatus IN (20) or (T.IdStatus = 41 and TDG.IdStatus = 18 and IsReleased is null)</log>
</ChangeLog>
*********************************************************************/


	SET NOCOUNT ON
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED


	SELECT DISTINCT TOP 1500
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
		, CASE WHEN L.[IdAgent] IS NULL THEN 0 ELSE 1 END [AgentKycRule]
		,T.[CustomerAddress]
	FROM [dbo].[Transfer] T WITH (NOLOCK)
	INNER JOIN [Agent] A WITH(NOLOCK) ON T.IdAgent = A.IdAgent
	INNER JOIN [Payer] P WITH(NOLOCK) ON T.IdPayer = P.IdPayer
	INNER JOIN [Status] S WITH(NOLOCK) ON T.IdStatus = S.IdStatus
	INNER JOIN [Gateway] GAT WITH(NOLOCK) ON t.IdGateway = gat.IdGateway
	LEFT JOIN TransferDetail TDD WITH(NOLOCK) ON TDD.IdTransfer=T.IdTransfer and TDD.IdStatus in (12)
	LEFT JOIN TransferDetail TDK WITH(NOLOCK) ON TDK.IdTransfer=T.IdTransfer and TDK.IdStatus in (9)

	LEFT JOIN TransferHolds TDG WITH(NOLOCK) ON TDG.IdTransfer=T.IdTransfer --and TDG.IdStatus in (18) --DEPOSITHOLD

	LEFT JOIN [dbo].[CountryCurrency] CC WITH (NOLOCK) ON T.[IdCountryCurrency] = CC.[IdCountryCurrency]
	LEFT JOIN [dbo].[Country] C WITH (NOLOCK) ON CC.[IdCountry] = C.[IdCountry]
	LEFT JOIN (
		SELECT DISTINCT
			[IdAgent]
		FROM [dbo].[KYCRule] WITH (NOLOCK)
		WHERE [IdAgent] IS NOT NULL AND [IdGenericStatus] = 1 -- Should be Active
	) L ON T.[IdAgent] = L.[IdAgent]
	--WHERE T.[IdStatus] = 20 
	WHERE (T.IdStatus =20 
	AND T.[AmountInDollars] >= 200--#1
	AND TDD.[IdTransferDetail] IS NULL
	AND TDK.[IdTransferDetail] IS NULL)
	OR	(t.idstatus=41 and TDG.idstatus=18 and TDG.IsReleased is null  AND T.[AmountInDollars] >= 200)--DEPOSITHOLD)
	ORDER BY T.[DateOfTransfer] DESC
