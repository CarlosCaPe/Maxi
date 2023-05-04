CREATE VIEW AtlasTransaction
AS
SELECT IdTransfer,
	   T.IdBeneficiary,
	   B.[Name] AS BeneficiaryName,
	   B.FirstLastName AS BeneficiaryFirstLastName,
	   B.SecondLastName as BeneficiarySecondLastName,
	   T.Folio,
	   T.AmountInDollars,
	   1 AS IdCountryCurrency,
	   'USD' AS CurrencyCode,
	   T.DateOfTransferUTC as DateOfTransfer,
	   CONVERT(datetime, SWITCHOFFSET(CONVERT(datetimeoffset,T.DateStatusChange), '+05:00')) AS DateStatusChange,
	   T.AmountInMN,
	   CU.CurrencyCode AS CurrencyCodeInMN,
	   T.IdPaymentType,
	   PT.PaymentName,
	   T.IdStatus,
	   S.StatusName,
	   A.AgentCode,
	   A.AgentName
	   IdPayer,
	   P.PayerName
FROM [Transfer] T WITH (NOLOCK)
INNER JOIN dbo.Agent A WITH (NOLOCK) ON T.IdAgent=A.IdAgent
INNER JOIN dbo.Beneficiary B WITH (NOLOCK) ON T.IdBeneficiary=B.IdBeneficiary
INNER JOIN dbo.CountryCurrency CC WITH (NOLOCK) ON T.IdCountryCurrency=CC.IdCountryCurrency
INNER JOIN dbo.Currency CU WITH (NOLOCK) on CC.IdCurrency=CU.IdCurrency
INNER JOIN dbo.PaymentType PT WITH (NOLOCK) ON T.IdPaymentType=PT.IdPaymentType
INNER JOIN dbo.[Status] S WITH (NOLOCK) ON T.IdStatus=S.IdStatus
INNER JOIN dbo.Payer P WITH (NOLOCK) ON T.IdPayer=P.IdPayer
WHERE T.DateOfTransferUTC >= CAST(GETDATE()-1 AS DATE) AND T.DateOfTransferUTC < CAST(GETDATE() AS DATE);