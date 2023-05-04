
CREATE PROCEDURE [MoneyAlert].[st_BeneficiaryGetTransferDetail]
(
@IdTransfer int, 
@HasError bit out  
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0
	
	
SELECT  CustomerName+' '+CustomerFirstLastName as Name,
Case	When IdStatus<22 or IdStatus=41  Then 1
		When IdStatus=22 Then 2
		When IdStatus=23 Then 3
		When IdStatus=30 Then 4
		When IdStatus=31 Then 5
		
 Else 6 End as TransferStatus ,
  F.PayerName,
  --AmountInDollars as Amount,
  --'usd' as Currency,
  ClaimCode,
  --ExRate,
  AmountInMN,
  ISNULL(E.CurrencyCode,'') as BeneficiaryCurrency,
  ISNULL(B.idChat,0) as IdChat,
  ISNULL(C.IsOnline,0) as IsOnline,
  ISNULL(C.Photo,'') as Photo,
  CONVERT(VARCHAR(11),A.DateOfTransfer,106) as DateOfTransfer,
  ISNULL(G.LikeStatus,0) as Ilike
FROM Transfer A WITH(NOLOCK)
LEFT JOIN MoneyAlert.Customer Z ON (Z.IdCustomer=A.IdCustomer)
LEFT JOIN MoneyAlert.Beneficiary W ON (W.IdBeneficiary=A.IdBeneficiary)
LEFT JOIN MoneyAlert.Chat B on (Z.IdCustomerMobile=B.IdCustomerMobile AND W.IdBeneficiaryMobile=B.IdBeneficiaryMobile)
LEFT JOIN MoneyAlert.CustomerMobile C  WITH(NOLOCK) on (Z.IdCustomerMobile=C.IdCustomerMobile)
JOIN CountryCurrency D  WITH(NOLOCK) on (D.IdCountryCurrency=A.IdCountryCurrency)
JOIN Currency E WITH(NOLOCK) on (E.IdCurrency=D.IdCurrency)
JOIN Payer F WITH(NOLOCK) on (A.IdPayer=F.IdPayer)
LEFT JOIN MoneyAlert.Likes G  WITH(NOLOCK) on (G.IdTransfer=A.IdTransfer AND G.IdPersonRole=2)
WHERE A.IdTransfer=@IdTransfer 

UNION
SELECT  CustomerName+' '+CustomerFirstLastName as Name,
Case	When IdStatus<22 or IdStatus=41  Then 1
		When IdStatus=22 Then 2
		When IdStatus=23 Then 3
		When IdStatus=30 Then 4
		When IdStatus=31 Then 5
		
 Else 6 End as TransferStatus ,
  PayerName,
  --AmountInDollars as Amount,
  ---'usd' as Currency,
  ClaimCode,
  ---ExRate,
  AmountInMN,
  ISNULL(E.CurrencyCode,'') as BeneficiaryCurrency,
  ISNULL(B.idChat,0) as IdChat,
  ISNULL(C.IsOnline,0) as IsOnline,
  ISNULL(C.Photo,'') as Photo,
  CONVERT(VARCHAR(11),A.DateOfTransfer,106) as DateOfTransfer,
  ISNULL(G.LikeStatus,0) as Ilike
FROM TransferClosed A WITH(NOLOCK)
LEFT JOIN MoneyAlert.Customer Z ON (Z.IdCustomer=A.IdCustomer)
LEFT JOIN MoneyAlert.Beneficiary W ON (W.IdBeneficiary=A.IdBeneficiary)
LEFT JOIN MoneyAlert.Chat B on (Z.IdCustomerMobile=B.IdCustomerMobile AND W.IdBeneficiaryMobile=B.IdBeneficiaryMobile)
LEFT JOIN MoneyAlert.CustomerMobile C WITH(NOLOCK) on (Z.IdCustomerMobile=C.IdCustomerMobile)
JOIN CountryCurrency D WITH(NOLOCK) on (D.IdCountryCurrency=A.IdCountryCurrency)
JOIN Currency E WITH(NOLOCK) on (E.IdCurrency=D.IdCurrency)
LEFT JOIN MoneyAlert.Likes G  WITH(NOLOCK) on (G.IdTransfer=A.IdTransferClosed AND G.IdPersonRole=2)
WHERE IdTransferClosed=@IdTransfer 

		
       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH











