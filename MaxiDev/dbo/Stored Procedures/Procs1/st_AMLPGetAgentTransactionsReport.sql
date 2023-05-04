
CREATE PROCEDURE [dbo].[st_AMLPGetAgentTransactionsReport]
(
	@IdAgent		INT, 
	@IdCountry		INT,
	@SelectedIds	XML
)
AS
BEGIN
	DECLARE @DateFrom			DATETIME, 
			@DateTo				DATETIME,
			@AlertDate			DATETIME,
			@MonitorMinutes		INT

	SET @DateTo = GETDATE()

	SELECT 
		@MonitorMinutes = Value
	FROM AMLP_MonitorSettings WITH(NOLOCK)
	WHERE IdMonitorSettings= 1

	SELECT
		@AlertDate = sa.CreationDate
	FROM AMLP_SuspiciousAgentCurrent sac WITH(NOLOCK)
		JOIN AMLP_SuspiciousAgent sa  WITH(NOLOCK) ON sa.IdSuspiciousAgent = sac.IdSuspiciousAgent
	WHERE sac.IdAgent = @IdAgent AND sac.IdCountry = @IdCountry

	-- Only for Tests
	-- SET @DateTo = @AlertDate

	SET @DateFrom= DATEADD(MINUTE, -360, @DateTo)


	DECLARE @SelectedTransfers TABLE(Id INT)

	INSERT @SelectedTransfers(Id)
	SELECT 
		AD.value('.', 'INT')
	FROM @SelectedIds.nodes('/root/Id') AS N(AD)

	SELECT
		a.IdAgent,
		a.AgentCode,
		a.AgentName,
		a.AgentAddress		[Address],
		CONCAT(o.Name, ' ', o.LastName, ' ', o.SecondLastName) [Owner],
		@AlertDate			AlertDate,
		@MonitorMinutes		[Minutes]
	FROM Agent a  WITH(NOLOCK)
		JOIN Owner o WITH(NOLOCK) ON o.IdOwner = a.IdOwner
	WHERE a.IdAgent = @IdAgent

	SELECT
		A.AgentCode,
		T.Folio,
		T.IdStatus,
		T.DateOfTransfer,
		T.AmountInDollars,
		S.StatusName [Status],
		CuIdIssuer.CountryName CustomerIdIssuer,
		CU.IdCustomer,
		CU.FullName CustomerString,
		T.CustomerName,
		T.CustomerFirstLastName,
		T.CustomerSecondLastName,
		T.CustomerAddress,
		BE.FullName BeneficiaryString,
		T.BeneficiaryName,
		T.BeneficiaryFirstLastName,
		T.BeneficiarySecondLastName,
		ST.StateName State,
		CT.CityName City,
		CO.CountryName Country,
		PAYST.StateName PaymentState,
		PAYCT.CityName PaymentCity,
		PAYT.DateOfPayment PaymentDate,
		P.PayerName Payer,
		BR.BranchName Branch,
		ISNULL((SELECT TOP 1 1 FROM TransferDetail td WITH(NOLOCK) WHERE td.IdTransfer = T.IdTransfer AND td.IdStatus = 9), 0) KYCHold,
		ISNULL((SELECT TOP 1 1 FROM TransferDetail td WITH(NOLOCK) WHERE td.IdTransfer = T.IdTransfer AND td.IdStatus = 12), 0) DenyHold,
		CASE
			WHEN EXISTS (SELECT TOP 1 1 FROM TransferHolds (NOLOCK) WHERE IdStatus=9 and IdTransfer= T.IdTransfer and IsReleased=0) 
			THEN ISNULL((SELECT TOP 1 StatusName FROM [Status] WITH(NOLOCK) WHERE IdStatus = 9), '')
			WHEN EXISTS (SELECT TOP 1 1 FROM TransferHolds  WITH(NOLOCK) WHERE IdStatus=12 and IdTransfer= T.IdTransfer and IsReleased=0) 
			THEN ISNULL((SELECT TOP 1 StatusName FROM [Status] WITH(NOLOCK) WHERE IdStatus = 9), '')
		ELSE ''
		END RejectedHold,
		TCN.Note CancellationNote,
		DLC.DateInToList DateIntoDenyList,
		PT.PaymentName PaymentType,
		CONCAT(US.FirstName, ' ', US.LastName, ' ', US.SecondLastName) Cashier,
		CIT.Name CustomerIdType,
		CU.IdentificationNumber CustomerIdNumber,
		CU.BornDate CustomerDOB,
		CU.Occupation CustomerOccupation,
		T.CustomerCity CustomerCity,
		T.CustomerState CustomerState,
		T.CustomerPhoneNumber CustomerPhone,
		T.CustomerCelullarNumber CustomerCellular,
		T.IdBeneficiary,
		CASE 
			WHEN T.DateOfTransfer BETWEEN DATEADD(MINUTE, -@MonitorMinutes, @AlertDate) AND @AlertDate THEN 1
			ELSE 0 
		END Evaluated
	FROM Transfer T  WITH(NOLOCK)
		JOIN Agent A WITH(NOLOCK) ON A.IdAgent = T.IdAgent
		JOIN CountryCurrency CC WITH(NOLOCK) ON T.IdCountryCurrency=CC.IdCountryCurrency
		JOIN Country CO WITH(NOLOCK) ON CC.IdCountry=CO.IdCountry
		JOIN Status S WITH(NOLOCK) ON T.IdStatus=S.IdStatus
	
		JOIN Customer CU WITH(NOLOCK) ON CU.IdCustomer = T.IdCustomer
		LEFT JOIN Country CuIdIssuer WITH(NOLOCK) ON CuIdIssuer.IdCountry = CU.IdentificationIdCountry
	
		JOIN Beneficiary BE WITH(NOLOCK) ON T.IdBeneficiary = BE.IdBeneficiary
	
		JOIN Branch BR WITH(NOLOCK) ON T.IdBranch = BR.IdBranch
		JOIN City CT WITH(NOLOCK) ON BR.IdCity = CT.IdCity
		JOIN State ST WITH(NOLOCK) ON CT.IdState = ST.IdState
	
		-- User
		JOIN Users US WITH(NOLOCK) ON T.EnterByIdUser = US.IdUser 
	
		-- Payment Type
		JOIN PaymentType PT WITH(NOLOCK) ON T.IdPaymentType = PT.IdPaymentType

		LEFT JOIN (
			SELECT IdTransfer, MAX(IdTransferPayInfo) IdTransferPayInfo 
			FROM TransferPayInfo  WITH(NOLOCK)
			GROUP BY IdTransfer
		) PAY ON T.IdTransfer = PAY.IdTransfer
		LEFT JOIN TransferPayInfo PAYT WITH(NOLOCK) ON PAY.IdTransferPayInfo=PAYT.IdTransferPayInfo
		LEFT JOIN Branch PAYBR WITH(NOLOCK) ON PAYT.IdBranch=PAYBR.IdBranch
		LEFT JOIN City PAYCT WITH(NOLOCK) ON PAYBR.IdCity=PAYCT.IdCity
		LEFT JOIN State PAYST WITH(NOLOCK) ON PAYCT.IdState=PAYST.IdState

		JOIN Payer P WITH(NOLOCK) ON P.IdPayer = T.IdPayer

		-- Cancellation Notes
		LEFT JOIN TransferDetail TDC WITH(NOLOCK) ON TDC.IdTransfer = T.IdTransfer AND TDC.IdStatus = 31
		LEFT JOIN 
		(
			SELECT 
				IdTransferDetail, 
				MAX(IdTransferNote) IdTransferNote 
			FROM TransferNote WITH(NOLOCK)
			GROUP BY IdTransferDetail 
		) TCNMax ON TCNMax.IdTransferDetail = TDC.IdTransferDetail
		LEFT JOIN TransferNote TCN  WITH (NOLOCK) ON TCNMax.IdTransferNote=TCN.IdTransferNote 

		-- Date Deny List
		LEFT JOIN 
		(
			SELECT IdCustomer, MAX(IdDenyListCustomer) IdDenyListCustomer 
			FROM DenyListCustomer WITH(NOLOCK)
			GROUP BY IdCustomer
		) DeCus ON DeCus.IdCustomer= T.IdCustomer
		LEFT JOIN [DenyListCustomer] DLC WITH(NOLOCK) ON DeCus.IdDenyListCustomer = DLC.IdDenyListCustomer

		-- Customer Id
		LEFT JOIN CustomerIdentificationType CIT WITH(NOLOCK) ON CIT.IdCustomerIdentificationType = CU.IdCustomerIdentificationType
	WHERE T.IdAgent = @IdAgent
		AND DateOfTransfer BETWEEN @DateFrom AND @DateTo
		AND CC.IdCountry = @IdCountry
		AND
		( 
			(SELECT COUNT(0) FROM @SelectedTransfers) = 0
			OR
			EXISTS(SELECT 1 FROM @SelectedTransfers sf WHERE sf.Id = T.IdTransfer)
		)
	ORDER BY T.DateOfTransfer DESC
END
