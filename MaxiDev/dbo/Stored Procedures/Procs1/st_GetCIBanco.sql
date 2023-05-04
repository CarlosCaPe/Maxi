CREATE Procedure [dbo].[st_GetCIBanco]                      
AS                
Set nocount on                       
                  
--- Get Minutes to wait to be send to service ---                  
Declare @MinutsToWait Int                  
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                  
               
---  Update transfer to Attempt -----------------                  
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=10 and  IdStatus=20                
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                      
--------- Tranfer log ---------------------------              
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)               
Select 21,IdTransfer,GETDATE() from #temp                  
                  
              
                    
SELECT --top 20        
'80' AS  AgentCode,                      
'MAXITRAN' AS UserName,                      
'M4XI123S' AS Password,                      
-------------------- Remitance --------------------------                      
A.ClaimCode AS AgentReferenceID,                      
A.ClaimCode AS BenefReferenceID,                      
A.ClaimCode,                      
A.AmountInDollars AS SendAmount,                      
a.fee as FeeAmount,
'USD' AS SendCurrencyCode,                      
A.EXRate AS ExchangeRate,                      
A.AmountinMN AS PayoutAmount,                      
D.CurrencyCode AS PayoutCurrencyCode,                      
A.GatewayBranchCode  AS PayoutBranchCode,                      
Case IdPaymentType                       
When 1 Then '02'                      
When 2 Then '03'
When 3 Then '01' -- comentado por fidel fix de home delivery                       
End  AS SendType,    
Case IdPaymentType                         
When 1 Then '01'                        
When 2 Then '03'                         
Else '01' End AS  AccountType,                         
A.DepositAccountNumber AS AccountNumber,  
isnull(E.BranchName,'') As BankName,                        
                      
                      
--------------------   Sender Identification -------------                      
'' AS IdType,                      
'' AS IdNumber,                      
'' AS IssuerType,                      
                      
                      
--------------------------  Sender --------------------                      
A.CustomerName AS CFirstName,                      
A.CustomerFirstLastName AS CLastName,                      
A.CustomerSecondLastName AS CMiddleName,                      
A.CustomerPhoneNumber AS CHomePhone,                      
A.CustomerCelullarNumber AS CMobilePhone,                      
A.CustomerAddress  AS CAddress,                      
A.CustomerCity AS CCity,
Isnull(A.CustomerState,'') AS CState,                      
'USA' AS CCountryCode,
'' as CBornDate,                     
'' as CIdentification,
A.CustomerOccupation as COcupation,
A.CustomerSSNumber as CSSN,
A.CustomerZipcode as CZipcode,                      

 -----------  Beneficiary  --------------                      
A.BeneficiaryName AS BFirstName,                      
A.BeneficiaryFirstLastName AS BLastName,                      
A.BeneficiarySecondLastName AS BMiddleName,                      
A.BeneficiaryPhoneNumber AS BHomePhone,                      
A.BeneficiaryCelularNumber AS BMobilePhone,                      
A.BeneficiaryAddress  AS BAddress,                      
A.BeneficiaryCity AS BCity, 
Isnull(A.BeneficiaryState,'') AS BState,                     
C.CountryCode AS BCountryCode,
'' as BBornCountry,
convert(varchar,isnull(BeneficiaryBornDate,'')) as BBornDate,
'' as BOcupation,
A.BeneficiaryZipcode as BZipcode,
'' as BIdentificationType,
'' as BIdentificationNumber
From Transfer A                      
JOIN CountryCurrency B ON (A.IdCountryCurrency=B.IdCountryCurrency)                      
JOIN Country C ON (C.IdCountry=B.IdCountry)                    
JOIN Currency D ON (D.IdCurrency=B.IdCurrency)          
LEFT JOIN CibancoSpei E on (E.BranchCode=A.GatewayBranchCode)    
  
                      
WHERE A.IdGateway=10 and IdStatus=21
--SELECT --top 20        
--'80' AS  AgentCode,                      
--'MAXITRAN' AS UserName,                      
--'M4XI123S' AS Password,                      
---------------------- Remitance --------------------------                      
--'' AS AgentReferenceID,                      
--'' AS BenefReferenceID,                      
--'' ClaimCode,                      
--10.2 AS SendAmount,                      
--10.2 as FeeAmount,
--'USD' AS SendCurrencyCode,                      
--10.2 AS ExchangeRate,                      
--10.2 AS PayoutAmount,                      
--'' AS PayoutCurrencyCode,                      
--''  AS PayoutBranchCode,                      
--'' SendType,    
--''  AccountType,                         
--'' AS AccountNumber,  
--'' As BankName,                        
                      
                      
----------------------   Sender Identification -------------                      
--'' AS IdType,                      
--'' AS IdNumber,                      
--'' AS IssuerType,                      
                      
                      
----------------------------  Sender --------------------                      
--'' AS CFirstName,                      
--'' AS CLastName,                      
--'' AS CMiddleName,                      
--'' AS CHomePhone,                      
--'' AS CMobilePhone,                      
--''  AS CAddress,                      
--'' AS CCity,
--'' AS CState,                      
--'USA' AS CCountryCode, 
--'' as CBornDate,                     
--'' as CIdentification,
--'' as COcupation,
--'' as CSSN,
--'' as CZipcode,
                      
-- -----------  Beneficiary  --------------                      
--'' AS BFirstName,                      
--'' AS BLastName,                      
--'' AS BMiddleName,                      
--'' AS BHomePhone,                      
--'' AS BMobilePhone,                      
--'' AS BAddress,                      
--'' AS BCity, 
--'' AS BState,                     
--'' AS BCountryCode,
--'' as BBornCountry,
--'' as BBornDate,
--'' as BOcupation,
--'' as BZipcode,
--'' as BIdentificationType,
--'' as BIdentificationNumber