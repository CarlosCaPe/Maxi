CREATE PROCEDURE [dbo].[st_AMLPGetAgentTransactions]
(
	@IdAgent	INT,
	@IdCountry	INT
)
AS
BEGIN
SET NOCOUNT ON
	
	DECLARE @DateFrom			DATETIME, 
			@DateTo				DATETIME,
			@AlertDate			DATETIME,
			@MonitorMinutes		INT,
			@RequiredMinAmount	INT

	SET @DateTo = GETDATE()

	SELECT 
		@MonitorMinutes = Value
	FROM AMLP_MonitorSettings WITH(NOLOCK)
	WHERE IdMonitorSettings= 1

	SELECT
		@RequiredMinAmount = Value
	FROM AMLP_MonitorSettings WITH(NOLOCK)
	WHERE IdMonitorSettings= 7

	SELECT
		@AlertDate = sa.CreationDate
	FROM AMLP_SuspiciousAgentCurrent sac WITH(NOLOCK)
		JOIN AMLP_SuspiciousAgent sa WITH(NOLOCK) ON sa.IdSuspiciousAgent = sac.IdSuspiciousAgent
	WHERE sac.IdAgent = @IdAgent AND sac.IdCountry = @IdCountry

	-- Only for Tests
	SET @DateTo = @AlertDate

	SET @DateFrom= DATEADD(MINUTE, -360, @DateTo)

	SELECT 
		T.IdTransfer IdTransfer, 
		T.IdPaymentType,
		PT.PaymentName PaymentType,
		T.Folio, 
		DateOfTransfer, 
		T.AmountInDollars,
		P.IdPayer,
		P.PayerName,
		P.PayerCode,
		T.IdBeneficiary,
		CONCAT(BeneficiaryName, ' ', BeneficiaryFirstLastName, ' ', BeneficiarySecondLastName) Beneficiary,
		T.IdCustomer,
		CONCAT(CustomerName, ' ', CustomerFirstLastName, ' ', CustomerSecondLastName) Customer,
		CASE WHEN EXISTS(SELECT 1 FROM UploadFiles uf WITH(NOLOCK) JOIN CustomerIdentificationType cit WITH(NOLOCK) ON cit.IdCustomerIdentificationType = uf.IdDocumentType WHERE uf.IdReference = T.IdCustomer AND uf.IdStatus = 1) 
			THEN 1
			ELSE 0
		END CustomerHasIDDocument,
		CASE WHEN EXISTS(SELECT 1 FROM UploadFiles uf WITH(NOLOCK) WHERE uf.IdReference = T.IdCustomer AND uf.IdDocumentType = 10 AND uf.IdStatus = 1) 
			THEN 1
			ELSE 0
		END CustomerHasSOFDocument,
		B.CreateDate CreatedDateBeneficiary,
		st.StateCode TransferState,
		c.CityName TransferCity,
		BR.BranchName TransferBranch,
		BR.Address TransferBranchAddress,
		ISNULL(PAYST.StateCode,'') PaidState, 
		ISNULL(PAYCT.CityName,'') PaidCity,
		ISNULL(PAYBR.BranchName,'') PaidBranch, 
		PAYBR.BranchName PaidBranchAddress,
		PAYT.DateOfPayment PaidDate,
		T.IdStatus,
		S.StatusName,
		US.UserName,
		CO.CountryName,
		CASE 
			WHEN (T.DateOfTransfer BETWEEN DATEADD(MINUTE, -@MonitorMinutes, @AlertDate) AND @AlertDate) THEN 1
			ELSE 0 
		END Evaluated,
		CASE 
			WHEN CONVERT(DATE, B.CreateDate) = CONVERT(DATE, GETDATE()) THEN 1
			ELSE 0 
		END NewBeneficiary,
		ISNULL((SELECT TOP 1 1 FROM TransferDetail td WITH(NOLOCK) WHERE td.IdTransfer = T.IdTransfer AND td.IdStatus = 9), 0) KYCHold,
		CASE 
			WHEN 
				ISNULL(T.IdStatus, 0) IN (20, 41) 
				AND 
				(
					NOT EXISTS(SELECT 1 FROM TransferDetail td WITH(NOLOCK) WHERE td.IdTransfer = t.IdTransfer AND td.IdStatus IN (12, 9))
					OR (
						EXISTS (SELECT 1 FROM TransferHolds th WITH(NOLOCK) WHERE th.IdTransfer = t.IdTransfer AND th.IdStatus = 9 AND ISNULL(th.IsReleased, 0) = 0)
						AND NOT EXISTS (SELECT 1 FROM BrokenRulesByTransfer brt WITH(NOLOCK) WHERE brt.IdTransfer = t.IdTransfer AND brt.IdKYCAction = 8)
					)
				)
			THEN 1 
			ELSE 0 
		END CanSetKycHold,
		CASE WHEN EXISTS(SELECT 1 FROM TransferHolds TH WITH(NOLOCK) WHERE TH.IdTransfer = T.IdTransfer AND ISNULL(TH.IsReleased, 0) = 0) 
			THEN 1
			ELSE 0
		END Hold,
		(
			SELECT TOP 1 
				brt.RuleName 
			FROM BrokenRulesByTransfer brt WITH(NOLOCK)
				JOIN fnAMLPGetKYCAlerts() ra ON ra.IdRule = brt.IdRule
			WHERE brt.IdTransfer = T.IdTransfer
		) KYCRuleAlert
	FROM Transfer T WITH(NOLOCK)
		JOIN Beneficiary B WITH(NOLOCK) ON T.IdBeneficiary = B.IdBeneficiary
		JOIN Status S WITH(NOLOCK) ON T.IdStatus=S.IdStatus
		JOIN Users US WITH(NOLOCK) ON T.EnterByIdUser = US.IdUser 
		JOIN CountryCurrency CC WITH(NOLOCK) ON T.IdCountryCurrency=CC.IdCountryCurrency
		JOIN Country CO WITH(NOLOCK) ON CC.IdCountry=CO.IdCountry
		JOIN Branch BR WITH(NOLOCK) ON T.IdBranch=BR.IdBranch
		JOIN City C WITH(NOLOCK) ON BR.IdCity=C.IdCity
		JOIN State ST WITH(NOLOCK) ON C.IdState=ST.IdState
		JOIN PaymentType PT WITH(NOLOCK) ON T.IdPaymentType = PT.IdPaymentType
		JOIN Payer P WITH(NOLOCK) on P.IdPayer = T.IdPayer
		LEFT JOIN (
			SELECT 
				IdTransfer, 
				MAX(IdTransferPayInfo) IdTransferPayInfo 
			FROM TransferPayInfo WITH(NOLOCK)
			GROUP BY IdTransfer
		) PAY ON T.IdTransfer = PAY.IdTransfer
		LEFT JOIN TransferPayInfo PAYT WITH(NOLOCK) ON PAY.IdTransferPayInfo=PAYT.IdTransferPayInfo
		LEFT JOIN Branch PAYBR WITH(NOLOCK) ON PAYT.IdBranch=PAYBR.IdBranch
		LEFT JOIN City PAYCT WITH(NOLOCK) ON PAYBR.IdCity=PAYCT.IdCity
		LEFT JOIN State PAYST WITH(NOLOCK) ON PAYCT.IdState=PAYST.IdState
	WHERE IdAgent=@IdAgent
		AND DateOfTransfer BETWEEN @DateFrom AND @DateTo
		AND CC.IdCountry = @IdCountry
		AND T.AmountInDollars >= @RequiredMinAmount
	ORDER BY T.DateOfTransfer DESC
END
