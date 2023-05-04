CREATE PROCEDURE [MoneyAlert].[st_BeneficiaryGetTransfer]
(
@IdBeneficiary int,
@PageChat int, 
@HasError bit out  
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0
	Set @PageChat=@PageChat*5	

SELECT IdCustomerMobile INTO #TEMP FROM MoneyAlert.BeneficiaryMobile A
JOIN MoneyAlert.Chat B ON (A.IdBeneficiaryMobile=B.IdBeneficiaryMobile)
WHERE A.IdBeneficiaryMobile=@IdBeneficiary

SELECT *, CASE  When RowNum<6 Then 1 Else 0 End AS IsToSave FROM 	
(	
SELECT ROW_NUMBER() OVER (ORDER BY IdTransfer DESC) AS RowNum ,* FROM
(
SELECT CustomerName+' '+CustomerFirstLastName as Name, AmountInMN as Amount, 
Case	When IdStatus<22 or IdStatus=41  Then 1
		When IdStatus=22 Then 2
		When IdStatus=23 Then 3
		When IdStatus=30 Then 4
		When IdStatus=31 Then 5
		
 Else 6 End as TransferStatus ,
  C.CurrencyCode as Currency, IdTransfer
FROM Transfer A WITH(NOLOCK)
JOIN CountryCurrency B  WITH(NOLOCK) ON (A.IdCountryCurrency=B.IdCountryCurrency)
JOIN Currency C  WITH(NOLOCK) ON (B.IdCurrency=C.IdCurrency)
WHERE A.IdCustomer IN 
(
SELECT IdCustomer FROM MoneyAlert.Customer WHERE IdCustomerMobile IN (SELECT IdCustomerMobile FROM #TEMP)
)
AND A.IdBeneficiary IN (SELECT IdBeneficiary FROM MoneyAlert.Beneficiary WHERE IdBeneficiaryMobile=@IdBeneficiary)

 Union All


SELECT CustomerName+' '+CustomerFirstLastName as Name, AmountInMN as Amount, 
Case	When IdStatus<22 or IdStatus=41  Then 1
		When IdStatus=22 Then 2
		When IdStatus=23 Then 3
		When IdStatus=30 Then 4
		When IdStatus=31 Then 5
		
 Else 6 End as TransferStatus ,
  C.CurrencyCode as Currency, IdTransferClosed as IdTransfer
FROM TransferClosed A WITH(NOLOCK)
JOIN CountryCurrency B  WITH(NOLOCK) ON (A.IdCountryCurrency=B.IdCountryCurrency)
JOIN Currency C  WITH(NOLOCK) ON (B.IdCurrency=C.IdCurrency)
WHERE A.IdCustomer IN 
(
SELECT IdCustomer FROM MoneyAlert.Customer WHERE IdCustomerMobile IN (SELECT IdCustomerMobile FROM #TEMP)
)
AND A.IdBeneficiary IN (SELECT IdBeneficiary FROM MoneyAlert.Beneficiary WHERE IdBeneficiaryMobile=@IdBeneficiary)


)M 

)J
WHERE   RowNum >= 1
AND RowNum <= @PageChat
ORDER BY IdTransfer DESC
       
END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH








