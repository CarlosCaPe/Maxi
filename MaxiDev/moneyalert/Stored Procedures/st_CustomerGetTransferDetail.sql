
CREATE PROCEDURE [moneyalert].[st_CustomerGetTransferDetail]
(
@IdTransfer int, 
@HasError bit out  
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0
	
	
SELECT  BeneficiaryName+' '+BeneficiaryFirstLastName as Name,
Case	When IdStatus<22 or IdStatus=41  Then 1
		When IdStatus=22 Then 2
		When IdStatus=23 Then 3
		When IdStatus=30 Then 4
		When IdStatus=31 Then 5
		
 Else 6 End as TransferStatus ,
  F.PayerName,
  AmountInDollars as Amount,
  'USD' as Currency,ClaimCode,
  ExRate,
  AmountInMN,
  ISNULL(E.CurrencyCode,'') as BeneficiaryCurrency,
  ISNULL(B.idChat,0) as IdChat,
  ISNULL(h.IsOnline,0) as IsOnline,
  ISNULL(H.Photo,'') as Photo,
  CONVERT(VARCHAR(11),A.DateOfTransfer,106) as DateOfTransfer,
  ISNULL(G.LikeStatus,0) as Ilike
FROM Transfer A
LEFT JOIN MoneyAlert.Customer Z ON (Z.IdCustomer=A.IdCustomer)
LEFT JOIN MoneyAlert.Beneficiary W ON (W.IdBeneficiary=A.IdBeneficiary)
LEFT JOIN MoneyAlert.Chat B on (Z.IdCustomerMobile=B.IdCustomerMobile AND W.IdBeneficiaryMobile=B.IdBeneficiaryMobile)
JOIN CountryCurrency D on (D.IdCountryCurrency=A.IdCountryCurrency)
JOIN Currency E on (E.IdCurrency=D.IdCurrency)
JOIN Payer F on (A.IdPayer=F.IdPayer)
LEFT JOIN MoneyAlert.Likes G on (G.IdTransfer=A.IdTransfer AND G.IdPersonRole=1)
LEFT JOIN MoneyAlert.BeneficiaryMobile H on (H.IdBeneficiaryMobile=w.IdBeneficiaryMobile)
WHERE A.IdTransfer=@IdTransfer 

UNION
SELECT  BeneficiaryName+' '+BeneficiaryFirstLastName as Name,
Case	When IdStatus<22 or IdStatus=41  Then 1
		When IdStatus=22 Then 2
		When IdStatus=23 Then 3
		When IdStatus=30 Then 4
		When IdStatus=31 Then 5
		
 Else 6 End as TransferStatus ,
  PayerName,
  AmountInDollars as Amount,
  'usd' as Currency,ClaimCode,
  ExRate,
  AmountInMN,
  ISNULL(E.CurrencyCode,'') as BeneficiaryCurrency,
  ISNULL(B.idChat,0) as IdChat,
  ISNULL(h.IsOnline,0) as IsOnline,
  ISNULL(H.Photo,'') as Photo,
  CONVERT(VARCHAR(11),A.DateOfTransfer,106) as DateOfTransfer,
  ISNULL(G.LikeStatus,0) as Ilike
FROM TransferClosed A
LEFT JOIN MoneyAlert.Customer Z ON (Z.IdCustomer=A.IdCustomer)
LEFT JOIN MoneyAlert.Beneficiary W ON (W.IdBeneficiary=A.IdBeneficiary)
LEFT JOIN MoneyAlert.Chat B on (Z.IdCustomerMobile=B.IdCustomerMobile AND W.IdBeneficiaryMobile=B.IdBeneficiaryMobile)
JOIN CountryCurrency D on (D.IdCountryCurrency=A.IdCountryCurrency)
JOIN Currency E on (E.IdCurrency=D.IdCurrency)
LEFT JOIN MoneyAlert.Likes G on (G.IdTransfer=A.IdTransferClosed AND G.IdPersonRole=1)
LEFT JOIN MoneyAlert.BeneficiaryMobile H on (H.IdBeneficiaryMobile=w.IdBeneficiaryMobile)
WHERE IdTransferClosed=@IdTransfer 

exec MoneyAlert.st_SaveStoreProcedureUsage 'MoneyAlert.st_CustomerGetTransferDetail',@IdTransfer		
       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH









