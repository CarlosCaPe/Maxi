CREATE Procedure [dbo].[st_GetCIBancoX]                    
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
                
            
                  
SELECT                    
'80' AS  AgentCode,                    
'MAXITRAN' AS UserName,                    
'M4XI123S' AS Password,                    
-------------------- Remitance --------------------------                    
A.ClaimCode AS AgentReferenceID,                    
A.ClaimCode AS BenefReferenceID,                    
A.ClaimCode,                    
A.AmountInDollars AS SendAmount,                    
'USD' AS SendCurrencyCode,                    
A.EXRate AS ExchangeRate,                    
A.AmountinMN AS PayoutAmount,                    
D.CurrencyCode AS PayoutCurrencyCode,                    
A.GatewayBranchCode  AS PayoutBranchCode,                    
Case IdPaymentType                     
When 1 Then '02'                    
When 2 Then '03'                     
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
'USA' AS CCountryCode,                    
                    
 -----------  Beneficiary  --------------                    
A.BeneficiaryName AS BFirstName,                    
A.BeneficiaryFirstLastName AS BLastName,                    
A.BeneficiarySecondLastName AS BMiddleName,                    
A.BeneficiaryPhoneNumber AS BHomePhone,                    
A.BeneficiaryCelularNumber AS BMobilePhone,                    
A.BeneficiaryAddress  AS BAddress,                    
A.BeneficiaryCity AS BCity,                    
C.CountryCode AS BCountryCode                    
                    
From Transfer A                    
JOIN CountryCurrency B ON (A.IdCountryCurrency=B.IdCountryCurrency)                    
JOIN Country C ON (C.IdCountry=B.IdCountry)                  
JOIN Currency D ON (D.IdCurrency=B.IdCurrency)        
LEFT JOIN CibancoSpei E on (E.BranchCode=A.GatewayBranchCode)  

                    
WHERE A.IdGateway=10 and IdStatus=21 
  
  
  
