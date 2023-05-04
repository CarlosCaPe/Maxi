CREATE PROCEDURE [Soporte].[st_GetTransferAnalisysReport]
(
	@IdStatus		INT,
	@DateFrom		DATE,
	@DateTo			DATE
)
AS
BEGIN
	DECLARE @DateFormat NVARCHAR(20) = 'dd/MM/yyyy hh:mm'

	SELECT
		FORMAT(A.DateOfTransfer, @DateFormat) 'Date Of Transfer',
		A.Folio,
		B.AgentCode 'Agent #',
		B.AgentName 'AgentName',
		A.AmountInDollars 'Amount',
		A.AmountInMN 'Amount in MN',
		E.PaymentName 'Payment Type',
		CONCAT(A.CustomerName, A.CustomerFirstLastName, A.CustomerSecondLastName) Sender,
		CONCAT(A.BeneficiaryName, A.BeneficiaryFirstLastName, A.BeneficiarySecondLastName) Beneficiary,
		C.StatusName Status,
		FORMAT(A.DateStatusChange, @DateFormat) 'Date of Last Status Change',
		D.PayerName Payer,
		I.GatewayName Gateway,
		G.CountryName Country,
		J.CurrencyName Currency
	FROM Transfer AS A WITH(NOLOCK)
		INNER JOIN Agent AS B WITH(NOLOCK) on (A.IdAgent = B.IdAgent)
		INNER JOIN Status AS C WITH(NOLOCK) on (A.IdStatus = C.IdStatus)
		INNER JOIN Payer AS D WITH(NOLOCK) on (A.IdPayer = D.IdPayer)
		INNER JOIN PaymentType AS E WITH(NOLOCK) on (E.IdPaymentType = A.IdPaymentType)
		INNER JOIN CountryCurrency AS F WITH(NOLOCK) on (F.IdCountryCurrency = A.IdCountryCurrency)
		INNER JOIN Country AS G WITH(NOLOCK) on (G.IdCountry = F.IdCountry)
		INNER JOIN TransferDetail AS H WITH(NOLOCK) on (A.IdTransfer = H.IdTransfer)
		INNER JOIN Gateway AS I WITH(NOLOCK) on (I.IdGateway = A.IdGateway)
		INNER JOIN Currency AS J WITH(NOLOCK) on (J.IdCurrency = F.IdCurrency)
	WHERE H.IdStatus = @IdStatus
		AND CONVERT(DATE, H.DateOfMovement) BETWEEN @DateFrom AND @DateTo
	UNION
	SELECT
		FORMAT(A.DateOfTransfer, @DateFormat),
		A.Folio,
		B.AgentCode,
		B.AgentName,
		A.AmountInDollars,
		A.AmountInMN,
		A.PaymentTypeName,
		CONCAT(A.CustomerName, A.CustomerFirstLastName, A.CustomerSecondLastName) CustomerName,
		CONCAT(A.BeneficiaryName, A.BeneficiaryFirstLastName, A.BeneficiarySecondLastName) BeneficiaryName,
		A.StatusName,
		FORMAT(A.DateStatusChange, @DateFormat),
		A.PayerName,
		A.GatewayName,
		A.CountryName,
		A.CurrencyName
	FROM TransferClosed AS A WITH(NOLOCK)
		INNER JOIN Agent AS B WITH(NOLOCK) on (A.IdAgent = B.IdAgent)
		INNER JOIN TransferClosedDetail AS C WITH(NOLOCK) on (C.IdTransferClosed = A.IdTransferClosed)
	Where C.IdStatus = @IdStatus
		AND CONVERT(DATE, C.DateOfMovement) BETWEEN @DateFrom AND @DateTo
END