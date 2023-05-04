
CREATE PROCEDURE [dbo].[st_ReportTransferInfo]
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
                  --isnull(dbo.funPayInfoGetAddress(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveAddress,
                  --isnull(dbo.funPayInfoGetState(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveState,
                  --isnull(dbo.funPayInfoGetCity(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveCity,
                  isnull(br.address,'') BranchReceiveAddress,
                  isnull(cr.cityname,'') BranchReceiveCity,
                  isnull(sr.statename,'') BranchReceiveState,
                  isnull(tpi.BeneficiaryIdNumber,'') BeneficiaryIdNumber ,
                  isnull(tpi.BeneficiaryIdType,'') BeneficiaryIdType 
into #tmp1 
FROM              Agent A with (nolock)
Join Transfer T with (nolock) on (A.IdAgent=T.IdAgent)
Join Status S with (nolock) on (T.IdStatus=S.IdStatus)
Left Join CustomerIdentificationType I with (nolock)on (I.IdCustomerIdentificationType=T.CustomerIdCustomerIdentificationType)
Left Join Branch B with (nolock) on (B.IdBranch = t.IdBranch)
Left Join City Y with (nolock) on (Y.IdCity=b.IdCity)
Left Join State X with (nolock) on (X.IdState=Y.IdState)
Left Join Payer P with (nolock) on (p.IdPayer=t.IdPayer)
Left Join CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
Left Join Country R with (nolock) on (R.IdCountry = c.IdCountry)
left join TransferPayInfo tpi with (nolock) on t.idtransfer=tpi.IdTransfer and tpi.IdTransferPayInfo=(select max(IdTransferPayInfo) from TransferPayInfo with (nolock) where IdTransfer =t.idtransfer)
left join branch br on br.idbranch=tpi.idbranch   
left join city cr on cr.idcity=br.idcity     
left join state sr on cr.idstate=sr.idstate         
WHERE               T.DateOfTransfer > @Date and t.idstatus=30
 
 
--UNION
 
 
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
                  --isnull(dbo.funPayInfoGetAddress(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveAddress,
                  --isnull(dbo.funPayInfoGetState(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveState,
                  --isnull(dbo.funPayInfoGetCity(b.idcity,isnull(tpi.BranchCode,''),t.idgateway,t.idpayer,t.idstatus),'') BranchReceiveCity,
                  isnull(br.address,'') BranchReceiveAddress,
                  isnull(cr.cityname,'') BranchReceiveCity,
                  isnull(sr.statename,'') BranchReceiveState,
                  isnull(tpi.BeneficiaryIdNumber,'') BeneficiaryIdNumber ,
                  isnull(tpi.BeneficiaryIdType,'') BeneficiaryIdType 
     
into #tmp2 
FROM              Agent A with (nolock)
Join TransferClosed T with (nolock) on (A.IdAgent=T.IdAgent)
Join Status S with (nolock) on (T.IdStatus=S.IdStatus)
Left Join CustomerIdentificationType I with (nolock) on (I.IdCustomerIdentificationType=T.CustomerIdCustomerIdentificationType)
Left Join Branch B with (nolock) on (B.IdBranch = t.IdBranch)
Left Join City Y with (nolock) on (Y.IdCity=b.IdCity)
Left Join State X with (nolock) on (X.IdState=Y.IdState)
Left Join Payer P with (nolock) on (p.IdPayer=t.IdPayer)
Left Join CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
Left Join Country R with (nolock) on (R.IdCountry = c.IdCountry)
left join TransferPayInfo tpi with (nolock) on t.IdTransferClosed=tpi.IdTransfer and tpi.IdTransferPayInfo=(select max(IdTransferPayInfo) from TransferPayInfo with (nolock) where IdTransfer =t.IdTransferClosed)
left join branch br on br.idbranch=tpi.idbranch   
left join city cr on cr.idcity=br.idcity     
left join state sr on cr.idstate=sr.idstate 
                 
WHERE               T.DateOfTransfer > @Date and t.idstatus=30

--union
 
SELECT            T.IdTransfer,A.AmountRequiredToAskId,A.AgentCode,a.AgentZipcode,T.Folio, T.DateOfTransfer, T.AmountInDollars, S.StatusName, T.DepositAccountNumber,T.ClaimCode,
                 
                  T.IdCustomer,T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName, T.CustomerAddress, T.CustomerCity,
                  T.CustomerState, T.CustomerZipcode, T.CustomerPhoneNumber, ISNULL(I.Name,'') Name, ISNULL(t.CustomerIdentificationIdCountry,0) CustomerIdentificationIdCountry, T.CustomerIdentificationNumber,
                  T.CustomerSSNumber, T.CustomerBornDate, T.CustomerOccupation,
                 
                  T.BeneficiaryName, T.BeneficiaryFirstLastName,T.BeneficiarySecondLastName,
                  T.BeneficiaryAddress + ' '+ T.BeneficiaryCity + ' '+ T.BeneficiaryState AS RecipientAddress,
                  
                  
                  P.PayerName,ISNULL(B.IdBranch, 0) IdBranch,ISNULL(Y.CityName,'') CityName,ISNULL(X.StateName,'') StateName,R.CountryName,
                  --informacion de pago
                  null DateOfPayment,                  
                  '' BranchReceive,
                  '' BranchReceiveAddress,
                  '' BranchReceiveState,
                  '' BranchReceiveCity,
                  '' BeneficiaryIdNumber ,
                  '' BeneficiaryIdType
into #tmp3
FROM              Agent A with (nolock)
Join Transfer T with (nolock) on (A.IdAgent=T.IdAgent)
Join Status S with (nolock) on (T.IdStatus=S.IdStatus)
Left Join CustomerIdentificationType I with (nolock) on (I.IdCustomerIdentificationType=T.CustomerIdCustomerIdentificationType)
Left Join Branch B with (nolock) on (B.IdBranch = t.IdBranch)
Left Join City Y with (nolock) on (Y.IdCity=b.IdCity)
Left Join State X with (nolock) on (X.IdState=Y.IdState)
Left Join Payer P with (nolock) on (p.IdPayer=t.IdPayer)
Left Join CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
Left Join Country R with (nolock) on (R.IdCountry = c.IdCountry)
--left join TransferPayInfo tpi on t.idtransfer=tpi.IdTransfer and tpi.IdTransferPayInfo=(select max(IdTransferPayInfo) from TransferPayInfo where IdTransfer =t.idtransfer)
                 
WHERE               T.DateOfTransfer > @Date and t.idstatus!=30
 
 
--UNION
 
 
SELECT            T.IdTransferClosed IdTransfer,A.AmountRequiredToAskId,A.AgentCode,a.AgentZipcode,T.Folio, T.DateOfTransfer, T.AmountInDollars, S.StatusName,T.DepositAccountNumber,T.ClaimCode,
                 
                  T.IdCustomer,T.CustomerName, T.CustomerFirstLastName, T.CustomerSecondLastName, T.CustomerAddress, T.CustomerCity,
                  T.CustomerState, T.CustomerZipcode, T.CustomerPhoneNumber, ISNULL(I.Name,'') Name, ISNULL(t.CustomerIdentificationIdCountry,0) CustomerIdentificationIdCountry , T.CustomerIdentificationNumber,
                  T.CustomerSSNumber, T.CustomerBornDate, T.CustomerOccupation,
                  
                  T.BeneficiaryName, T.BeneficiaryFirstLastName,T.BeneficiarySecondLastName,
                  T.BeneficiaryAddress + ' '+ T.BeneficiaryCity + ' '+ T.BeneficiaryState AS RecipientAddress,
                  
                  
                  P.PayerName,ISNULL(B.IdBranch, 0) IdBranch, ISNULL(Y.CityName,'') CityName,ISNULL(X.StateName,'') StateName,R.CountryName,
                  --informacion de pago
                  null DateOfPayment,                  
                  '' BranchReceive,
                  '' BranchReceiveAddress,
                  '' BranchReceiveState,
                  '' BranchReceiveCity,
                  '' BeneficiaryIdNumber ,
                  '' BeneficiaryIdType
     
into #tmp4 
FROM              Agent A with (nolock)
Join TransferClosed T with (nolock) on (A.IdAgent=T.IdAgent)
Join Status S with (nolock) on (T.IdStatus=S.IdStatus)
Left Join CustomerIdentificationType I with (nolock) on (I.IdCustomerIdentificationType=T.CustomerIdCustomerIdentificationType)
Left Join Branch B with (nolock) on (B.IdBranch = t.IdBranch)
Left Join City Y with (nolock) on (Y.IdCity=b.IdCity)
Left Join State X with (nolock) on (X.IdState=Y.IdState)
Left Join Payer P with (nolock) on (p.IdPayer=t.IdPayer)
Left Join CountryCurrency C with (nolock) on (T.IdCountryCurrency = C.IdCountryCurrency)
Left Join Country R with (nolock) on (R.IdCountry = c.IdCountry)
--left join TransferPayInfo tpi on t.IdTransferClosed=tpi.IdTransfer and tpi.IdTransferPayInfo=(select max(IdTransferPayInfo) from TransferPayInfo where IdTransfer =t.IdTransferClosed)
                 
WHERE               T.DateOfTransfer > @Date and t.idstatus!=30 
 

select * from #tmp1
union
select * from #tmp2
union
select * from #tmp3
union
select * from #tmp4
ORDER BY  DateOfTransfer --desc