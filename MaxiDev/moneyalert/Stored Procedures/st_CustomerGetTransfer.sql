
CREATE PROCEDURE [moneyalert].[st_CustomerGetTransfer]
(
@IdCustomer int, 
@PageChat int, 
@HasError bit out  
)
AS
SET NOCOUNT ON
BEGIN TRY

	SET @HasError=0
	Set @PageChat=@PageChat*5	
		
	

SELECT *, CASE  When RowNum<6 Then 1 Else 0 End AS IsToSave FROM 	
(	
SELECT ROW_NUMBER() OVER (ORDER BY IdTransfer desc) AS RowNum ,* FROM
(

SELECT BeneficiaryName+' '+BeneficiaryFirstLastName as Name, AmountInDollars as Amount, 
Case	When IdStatus<22 or IdStatus=41  Then 1
		When IdStatus=22 Then 2
		When IdStatus=23 Then 3
		When IdStatus=30 Then 4
		When IdStatus=31 Then 5
		
 Else 6 End as TransferStatus ,
  'USD' as Currency, IdTransfer
FROM Transfer WITH(NOLOCK) WHERE IdCustomer in (SELECT IdCustomer FROM MoneyAlert.Customer WHERE IdCustomerMobile=@IdCustomer)

 Union All
 
SELECT  BeneficiaryName+' '+BeneficiaryFirstLastName as Name, AmountInDollars as Amount, 
Case	When IdStatus<22 or IdStatus=41  Then 1
		When IdStatus=22 Then 2
		When IdStatus=23 Then 3
		When IdStatus=30 Then 4
		When IdStatus=31 Then 5
		
 Else 6 End as TransferStatus ,
  'usd' as Currency,IdTransferClosed as IdTransfer
FROM TransferClosed WITH(NOLOCK) WHERE IdCustomer in (SELECT IdCustomer FROM MoneyAlert.Customer WHERE IdCustomerMobile=@IdCustomer)

)M 
)J
WHERE   RowNum >= 1
AND RowNum <= @PageChat
ORDER BY IdTransfer DESC

exec MoneyAlert.st_SaveStoreProcedureUsage 'MoneyAlert.st_CustomerGetTransfer',@IdCustomer

END TRY
BEGIN CATCH
	SET @HasError=1
	INSERT INTO [MoneyAlert].[ErrorLogForStoreProcedure] ([StoreProcedure],[Line],[Message],[Number],[Severity],[State],[ErrorDate])
	VALUES (ERROR_PROCEDURE(), ERROR_LINE(), ERROR_MESSAGE(), ERROR_NUMBER(), ERROR_SEVERITY(), ERROR_STATE(), GETDATE())
END CATCH








