CREATE procedure [dbo].[st_GetArias]        
as        
Set nocount on         
                  
--- Get Minutes to wait to be send to service ---                  
Declare @MinutsToWait Int                  
--Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'           
Set @MinutsToWait=0                 
                  
---  Update transfer to Attempt -----------------                  
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=8 and  IdStatus=20                
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                      
--------- Tranfer log ---------------------------              
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)               
Select 21,IdTransfer,GETDATE() from #temp                
        
        
Select        
CONVERT(int,'') as payerCode,      
A.GatewayBranchCode as payerDestinationCode,      
A.DepositAccountNumber  as paymentAccountNumber,      
'?' as paymentAccountType,      
A.AmountInDollars as paymentAmount,      
C.CurrencyCode as paymentCurrency,      
CONVERT(int,'') as paymentLocationCode,      
A.ClaimCode as paymentServiceNumber,      
D.PaymentName as paymentType,      
A.BeneficiaryAddress as recipientAddress,      
'' as recipientBirthday,      
F.CityName as recipientCityName,      
G.CountryCode as recipientCountryCode,      
'' as recipientDocumentNumber,      
'' as recipientDocumentType,      
'' as recipientExternalCode,      
BeneficiaryName as recipientFirstName,      
BeneficiaryFirstLastName as recipientFirstSurname,      
'' as recipientMiddleName,      
BeneficiaryPhoneNumber as recipientPhone,      
BeneficiarySecondLastName as recipientSecondSurname,      
'' as recipientSecurityAnswer,      
'' as recipientSecurityQuestion,      
BeneficiaryState as recipientStateName,      
BeneficiaryZipcode as recipientZipCode,      
A.AmountInDollars as remittanceAmount,      
'' as remittanceComments,      
'USD' as remittanceCurrency,      
'' as remittanceExternalCode,      
'' as remittancePassword,      
CustomerAddress as remitterAddress,      
'' as remitterBirthday,      
CustomerCity as remitterCityName,      
'USD' as remitterCountryCode,      
'' as remitterExternalCode,      
CustomerName as remitterFirstName,      
CustomerFirstLastName as remitterFirstSurname,      
'' as remitterMiddleName,      
'' as remitterOccupation,      
CustomerPhoneNumber as remitterPhone,      
'' as remitterPrimaryDocumentNumber,      
'' as remitterPrimaryDocumentType,      
'' as remitterSecondSurname,      
'' as remitterSecondaryDocumentNumber,      
'' as remitterSecondaryDocumentType,      
'' as remitterStateName,      
CustomerZipcode as remitterZipCode      
From Transfer A      
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)      
JOin Currency C on (C.IdCurrency=B.IdCurrency)      
Join PaymentType D on (D.IdPaymentType=A.IdPaymentType)      
Left Join Branch E on (E.IdBranch=A.IdBranch)      
Left Join City F on (F.IdCity=E.IdCity)      
Join Country G on (G.IdCountry=B.IdCountry)      
Where IdGateway=99 and IdStatus=21  




