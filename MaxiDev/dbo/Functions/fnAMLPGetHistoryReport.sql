CREATE FUNCTION [dbo].[fnAMLPGetHistoryReport]
(
	@IdEntity		INT,
	@TypeEntity		VARCHAR(50),
	@DateFrom		DATE,
	@DateTo			DATE
)
RETURNS TABLE
AS
RETURN
(
	WITH AllTransfers AS
	(
		SELECT
			t.IdTransfer,
			'Transfer' [Type],
			t.DateOfTransfer,
			t.Folio,
			t.IdCountryCurrency,
			t.IdBeneficiary,
			CONCAT(T.BeneficiaryName, ' ', t.BeneficiaryFirstLastName, ' ', t.BeneficiarySecondLastName) Beneficiary,
			t.IdCustomer,
			CONCAT(t.CustomerName, ' ', t.CustomerFirstLastName, ' ', t.CustomerSecondLastName) Customer,
			t.IdBranch BranchSend,
			t.AmountInDollars,
			t.IdPaymentType,
			t.IdStatus,
			t.EnterByIdUser,
			t.IdAgent,
			t.IdBranch
		FROM Transfer t WITH(NOLOCK)
		WHERE
			(
				(@TypeEntity = 'Beneficiary' AND t.IdBeneficiary = @IdEntity)
				OR
				(@TypeEntity = 'Customer' AND t.IdCustomer = @IdEntity)
			) AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @DateFrom AND @DateTo
		UNION ALL
		SELECT
			t.IdTransferClosed IdTransfer,
			'TransferClosed' [Type],
			t.DateOfTransfer,
			t.Folio,
			t.IdCountryCurrency,
			t.IdBeneficiary,
			CONCAT(T.BeneficiaryName, ' ', t.BeneficiaryFirstLastName, ' ', t.BeneficiarySecondLastName) Beneficiary,
			t.IdCustomer,
			CONCAT(t.CustomerName, ' ', t.CustomerFirstLastName, ' ', t.CustomerSecondLastName) Customer,
			t.IdBranch BranchSend,
			t.AmountInDollars,
			t.IdPaymentType,
			t.IdStatus,
			t.EnterByIdUser,
			t.IdAgent,
			t.IdBranch
		FROM TransferClosed t WITH(NOLOCK)
		WHERE 
			(
				(@TypeEntity = 'Beneficiary' AND t.IdBeneficiary = @IdEntity)
				OR
				(@TypeEntity = 'Customer' AND t.IdCustomer = @IdEntity)
			) AND CONVERT(DATE, t.DateOfTransfer) BETWEEN @DateFrom AND @DateTo
	)
	SELECT
		t.IdTransfer,
		t.Type,
		t.DateOfTransfer,
		a.AgentCode,
		t.Folio,
		t.IdCustomer,
		t.Customer,
		t.IdBeneficiary,
		t.Beneficiary,
		t.AmountInDollars,
		st.StatusName,
		us.UserName,
		stateSent.StateCode StateSent,
		statePaid.StateCode StatePaid,
		pt.PaymentName,
		a.AgentName
	FROM AllTransfers t WITH(NOLOCK)
		JOIN Agent a WITH(NOLOCK) ON a.IdAgent = t.IdAgent
		JOIN Status st WITH(NOLOCK) ON st.IdStatus = t.IdStatus
		JOIN Users us WITH(NOLOCK) ON us.IdUser = t.EnterByIdUser
		JOIN Branch branchSent WITH(NOLOCK) ON branchSent.IdBranch = t.IdBranch
		JOIN City citySent WITH(NOLOCK) ON citySent.IdCity = branchSent.IdCity
		JOIN State stateSent WITH(NOLOCK) ON stateSent.IdState = citySent.IdState
		JOIN PaymentType pt WITH(NOLOCK) ON pt.IdPaymentType = t.IdPaymentType
		LEFT JOIN (
			SELECT IdTransfer, MAX(IdTransferPayInfo) IdTransferPayInfo 
			FROM TransferPayInfo WITH(NOLOCK)
			GROUP BY IdTransfer
		) pay ON t.IdTransfer = pay.IdTransfer
		LEFT JOIN TransferPayInfo payt WITH(NOLOCK) ON pay.IdTransferPayInfo = payt.IdTransferPayInfo
		LEFT JOIN Branch branchPaid WITH(NOLOCK) ON PAYT.IdBranch = branchPaid.IdBranch
		LEFT JOIN City cityPaid WITH(NOLOCK) ON branchPaid.IdCity = cityPaid.IdCity
		LEFT JOIN State statePaid WITH(NOLOCK) ON cityPaid.IdState= statePaid.IdState
)
