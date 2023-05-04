CREATE PROCEDURE [dbo].[st_AMLPGetAgentTransactionById]
(
	@IdTransfer INT
)
AS
BEGIN
SET NOCOUNT ON
	
	SELECT 
		T.IdTransfer IdTransfer, 
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
						AND NOT EXISTS (SELECT 1 FROM BrokenRulesByTransfer brt  WITH(NOLOCK) WHERE brt.IdTransfer = t.IdTransfer AND brt.IdKYCAction = 8)
					)
				)
			THEN 1 
			ELSE 0 
		END CanSetKycHold,
		CASE
			WHEN EXISTS(SELECT 1 FROM TransferHolds TH WITH(NOLOCK) WHERE TH.IdTransfer = T.IdTransfer AND ISNULL(TH.IsReleased, 0) = 0) THEN 1
			ELSE 0
		END Hold
	FROM Transfer T WITH(NOLOCK)
		JOIN Beneficiary B WITH(NOLOCK) ON T.IdBeneficiary = B.IdBeneficiary
		join Status S WITH(NOLOCK) ON T.IdStatus=S.IdStatus
		JOIN Users US WITH(NOLOCK) ON T.EnterByIdUser = US.IdUser 
		JOIN CountryCurrency CC WITH(NOLOCK) ON T.IdCountryCurrency=CC.IdCountryCurrency
		JOIN Country CO WITH(NOLOCK) ON CC.IdCountry=CO.IdCountry
		JOIN Branch BR WITH(NOLOCK) ON T.IdBranch=BR.IdBranch
		JOIN City C WITH(NOLOCK) ON BR.IdCity=C.IdCity
		JOIN State ST WITH(NOLOCK) ON C.IdState=ST.IdState
		JOIN PaymentType PT WITH(NOLOCK) ON T.IdPaymentType = PT.IdPaymentType
		JOIN Payer P WITH(NOLOCK) ON P.IdPayer = T.IdPayer
		LEFT JOIN (
			SELECT IdTransfer, MAX(IdTransferPayInfo) IdTransferPayInfo 
			FROM TransferPayInfo WITH(NOLOCK) 
			GROUP BY IdTransfer
		) PAY ON T.IdTransfer = PAY.IdTransfer
		LEFT JOIN TransferPayInfo PAYT WITH(NOLOCK) ON PAY.IdTransferPayInfo=PAYT.IdTransferPayInfo
		LEFT JOIN Branch PAYBR WITH(NOLOCK) ON PAYT.IdBranch=PAYBR.IdBranch
		LEFT JOIN City PAYCT WITH(NOLOCK) ON PAYBR.IdCity=PAYCT.IdCity
		LEFT JOIN State PAYST WITH(NOLOCK) ON PAYCT.IdState=PAYST.IdState
	WHERE T.IdTransfer = @IdTransfer

	-- KYC Rules Applied
	SELECT 
		brt.IdBrokenRulesByTransfer	IdBrokenRuleByTransfer,
		brt.IdTransfer				IdTransfer,
		ka.IdKYCAction				IdKycAction,
		ka.Action					KycActionName,
		brt.IsDenyList				IsDenyList,
		brt.MessageInEnglish		MessageInEnglish,
		brt.MessageInSpanish		MessageInSpanish,
		brt.RuleName				RuleNameKYC,
		brt.IdRule					IdRule
	FROM [BrokenRulesByTransfer] brt WITH(NOLOCK) 
		JOIN KYCAction ka WITH(NOLOCK) ON ka.IdKYCAction = brt.IdKYCAction
	WHERE brt.IdTransfer = @IdTransfer
	ORDER BY brt.IdBrokenRulesByTransfer DESC

	-- Status History
	SELECT
		td.IdTransferDetail				IdTransferDetail,
		s.IdStatus						IdStatus,
		s.StatusName					StatusName,
		td.DateOfMovement				DateOfMovement,
		u.IdUser						IdUser,
		CONCAT(u.FirstName, ' ', u.LastName, ' ', u.SecondLastName) UserName,
		tn.Note							Note,
		ISNULL(tnn.IdMessage, 0)		IdMessage,
		ISNULL(tnn.IdGenericStatus, 0)	IdGenericStatus
	FROM TransferDetail td WITH(NOLOCK) 
		JOIN Status s WITH(NOLOCK) ON s.IdStatus = td.IdStatus
		LEFT JOIN TransferNote tn WITH(NOLOCK) ON tn.IdTransferDetail = td.IdTransferDetail
		LEFT JOIN Users u WITH(NOLOCK) ON u.IdUser = tn.IdUser
		LEFT JOIN TransferNoteNotification tnn WITH(NOLOCK) ON tnn.IdTransferNote = tn.IdTransferNote
	WHERE td.IdTransfer = @IdTransfer
	ORDER BY td.DateOfMovement DESC

	-- Hold	
	SELECT
		th.IdTransferHold			IdTransferHold,
		th.IdTransfer				IdTransfer,
		s.IdStatus					IdStatus,
		s.StatusName				StatusName,
		th.DateOfValidation			DateOfValidation,
		th.IsReleased				IsReleased,
		th.DateOfLastChange			DateOfLastChange,
		th.EnterByIdUser			EnterByIdUser,
		CONCAT(u.FirstName, ' ', u.LastName, ' ', u.SecondLastName) EnterByUser
	FROM TransferHolds th WITH(NOLOCK)
		JOIN Status s WITH(NOLOCK) ON s.IdStatus = th.IdStatus
		LEFT JOIN Users u WITH(NOLOCK) ON u.IdUser = th.EnterByIdUser
	WHERE th.IdTransfer = @IdTransfer
	ORDER BY th.DateOfValidation ASC
END
