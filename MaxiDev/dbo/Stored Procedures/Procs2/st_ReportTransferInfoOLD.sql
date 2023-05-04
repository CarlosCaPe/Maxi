create PROCEDURE [dbo].[st_ReportTransferInfoOLD]
(
@Days int
)    
as
Set nocount on 
declare @Date datetime
set @Date=GETDATE()-@Days

SELECT            T.IdTransfer,A.AmountRequiredToAskId,A.AgentCode,a.AgentZipcode,T.Folio, T.DateOfTransfer, T.AmountInDollars, S.StatusName, T.DepositAccountNumber,T.ClaimCode,
                 
                  T.IdCustomer,T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName, T.CustomerAddress, T.CustomerCity,
                  T.CustomerState, T.CustomerZipcode, T.CustomerPhoneNumber, ISNULL(I.Name,'') Name, ISNULL(t.CustomerIdentificationIdCountry,0) CustomerIdentificationIdCountry, T.CustomerIdentificationNumber,
                  T.CustomerSSNumber, T.CustomerBornDate, T.CustomerOccupation,
                 
                  T.BeneficiaryName, T.BeneficiaryFirstLastName,T.BeneficiarySecondLastName,
                  T.BeneficiaryAddress + ' '+ T.BeneficiaryCity + ' '+ T.BeneficiaryState AS RecipientAddress,
                  
                  
                  P.PayerName,ISNULL(B.IdBranch, 0) IdBranch,ISNULL(Y.CityName,'') CityName,ISNULL(X.StateName,'') StateName,R.CountryName,
                  --informacion de pago
                  tpi.DateOfPayment,                  
                  isnull(tpi.BranchCode,'') BranchReceive,
                  isnull(dbo.funPayInfoGetAddress(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveAddress,
                  isnull(dbo.funPayInfoGetState(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveState,
                  isnull(dbo.funPayInfoGetCity(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveCity,
                  isnull(tpi.BeneficiaryIdNumber,'') BeneficiaryIdNumber ,
                  isnull(tpi.BeneficiaryIdType,'') BeneficiaryIdType
 
FROM              Agent A
Join Transfer T with (nolock) on (A.IdAgent=T.IdAgent)
Join Status S on (T.IdStatus=S.IdStatus)
Left Join CustomerIdentificationType I on (I.IdCustomerIdentificationType=T.CustomerIdCustomerIdentificationType)
Left Join Branch B on (B.IdBranch = t.IdBranch)
Left Join City Y on (Y.IdCity=b.IdCity)
Left Join State X on (X.IdState=Y.IdState)
Left Join Payer P on (p.IdPayer=t.IdPayer)
Left Join CountryCurrency C on (T.IdCountryCurrency = C.IdCountryCurrency)
Left Join Country R on (R.IdCountry = c.IdCountry)
left join TransferPayInfo tpi on t.idtransfer=tpi.IdTransfer and tpi.IdTransferPayInfo=(select max(IdTransferPayInfo) from TransferPayInfo where IdTransfer =t.idtransfer)
                 
WHERE               T.DateOfTransfer > @Date
 
 
UNION
 
 
SELECT            T.IdTransferClosed IdTransfer,A.AmountRequiredToAskId,A.AgentCode,a.AgentZipcode,T.Folio, T.DateOfTransfer, T.AmountInDollars, S.StatusName,T.DepositAccountNumber,T.ClaimCode,
                 
                  T.IdCustomer,T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName, T.CustomerAddress, T.CustomerCity,
                  T.CustomerState, T.CustomerZipcode, T.CustomerPhoneNumber, ISNULL(I.Name,'') Name, ISNULL(t.CustomerIdentificationIdCountry,0) CustomerIdentificationIdCountry , T.CustomerIdentificationNumber,
                  T.CustomerSSNumber, T.CustomerBornDate, T.CustomerOccupation,
                  
                  T.BeneficiaryName, T.BeneficiaryFirstLastName,T.BeneficiarySecondLastName,
                  T.BeneficiaryAddress + ' '+ T.BeneficiaryCity + ' '+ T.BeneficiaryState AS RecipientAddress,
                  
                  
                  P.PayerName,ISNULL(B.IdBranch, 0) IdBranch, ISNULL(Y.CityName,'') CityName,ISNULL(X.StateName,'') StateName,R.CountryName,
                  --informacion de pago
                  tpi.DateOfPayment,  
                  isnull(tpi.BranchCode,'') BranchReceive,
                  isnull(dbo.funPayInfoGetAddress(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveAddress,
                  isnull(dbo.funPayInfoGetState(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveState,
                  isnull(dbo.funPayInfoGetCity(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveCity,
                  isnull(tpi.BeneficiaryIdNumber,'') BeneficiaryIdNumber ,
                  isnull(tpi.BeneficiaryIdType,'') BeneficiaryIdType 
     
 
FROM              Agent A
Join TransferClosed T with (nolock) on (A.IdAgent=T.IdAgent)
Join Status S on (T.IdStatus=S.IdStatus)
Left Join CustomerIdentificationType I on (I.IdCustomerIdentificationType=T.CustomerIdCustomerIdentificationType)
Left Join Branch B on (B.IdBranch = t.IdBranch)
Left Join City Y on (Y.IdCity=b.IdCity)
Left Join State X on (X.IdState=Y.IdState)
Left Join Payer P on (p.IdPayer=t.IdPayer)
Left Join CountryCurrency C on (T.IdCountryCurrency = C.IdCountryCurrency)
Left Join Country R on (R.IdCountry = c.IdCountry)
left join TransferPayInfo tpi on t.IdTransferClosed=tpi.IdTransfer and tpi.IdTransferPayInfo=(select max(IdTransferPayInfo) from TransferPayInfo where IdTransfer =t.IdTransferClosed)
                 
WHERE               T.DateOfTransfer > = @Date
 
 
 
 
ORDER BY  T.DateOfTransfer --desc