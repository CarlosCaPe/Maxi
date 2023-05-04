CREATE procedure [dbo].[st_GetAppriza]                                    
as
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="12/07/2019" Author="jdarellano" Name="#1">Se agrega código de tipo de cuenta para 16 dígitos, por error en proceso de carga.</log>
<log Date="17/07/2019" Author="jdarellano" Name="#2">Se agrega validación para campo "SiIssuerStateCode" por problema reportado en ticket 1940.</log>
<log Date="04/09/2020" Author="jdarellano" Name="#3">Se agrega código para branch para pagador Circle K.</log>
</ChangeLog>
*********************************************************************/                                    
Set nocount on                                     
                                              
--- Get Minutes to wait to be send to service ---                                              
Declare @MinutsToWait Int                                              
Declare @IdGateway int = 32
Select @MinutsToWait=Convert(int,Value) From GlobalAttributes where Name='TimeFromReadyToAttemp'                                       
                                         
                                              
---  Update transfer to Attempt -----------------                                              
Select IdTransfer into #temp from Transfer  Where DATEDIFF(MINUTE,DateOfTransfer,GETDATE())>@MinutsToWait and IdGateway=@IdGateway and  IdStatus=20                                        
Update Transfer Set IdStatus=21,DateStatusChange=GETDATE() Where IdTransfer in (Select IdTransfer from #temp)                                                  
--------- Tranfer log ---------------------------                                          
Insert into TransferDetail (IdStatus,IdTransfer,DateOfMovement)                                           
Select 21,IdTransfer,GETDATE() from #temp                                            
                                    
                                    
                              
Select  top 1
--Transferinfo                                     
A.Claimcode as UniqueReferenceNumber,
A.Claimcode as OrderTrackingNumber,
CONVERT(varchar(8),a.dateoftransfer,112) ProcessDate,
replace(convert(varchar, a.dateoftransfer, 108),':','') ProcessTime,
Convert(varchar(20),A.AmountInDollars) OriginAmount,
Convert(varchar(20),A.AmountInMN) DestinationAmount,
Convert(varchar(20),A.ExRate) RetailExchangeRate,
'' as WholesaleExchangeRate,
Convert(varchar(20),a.Fee) ServiceFeeAmount,
'' DiscountAmount,
'' DiscountReasonTypeCode,
'O' ProcessTypeCode,
'' ReasonTypeCode,
'REQUEST OF THE CLIENT' ReasonForTransfer,
'' SourceOfFunds,
'' SecurityPhrase,
'' FreeMessage,
 
 --Branch
 dbo.fn_EspecialChrOFF(E.AGENTCODE) BranchLocationUnit,
 E.IdAgent BranchNumber,
 'BRN' BranchTypeCode, 
 'USA' BranchCountryCode,
 ltrim(rtrim(isnull(E.AgentState,'000'))) BranchStateCode,
 '' BranchSupervisorId,
Convert(varchar(20), A.Enterbyiduser) BranchUserId,
'1' BranchTerminalId,

--corridor
'USA' OriginCountryCode,
'USD' OriginCurrencyCode,
'MTS' DestinationServiceCode,
C.CountryCode DestinationCountryCode,
case when D.CurrencyCode='MXP' THEN 'MXN' else D.CurrencyCode end DestinationCurrencyCode,
Case A.IdPaymentType When 1 Then 'CAS'
                     When 2 Then 'DEP'
                     When 4 Then 'CAS'
                     Else '' End
DestinationDeliveryMethodCode, 
--deliveryinstruction
G.PAYERCODE DiPayNetworkCode,
'' DiPaySubNetworkCode,
--AGREGAR PAYERCODE
case 
                     When G.PAYERCODE='BCL' and A.IdPaymentType in (1,4) Then RIGHT('0000'+GatewayBranchCode,4)  
					 When G.PAYERCODE='CHR' and A.IdPaymentType in (1,4) Then GatewayBranchCode
					 When G.PAYERCODE='WLD' and A.IdPaymentType in (1,4) Then GatewayBranchCode
					 When G.PAYERCODE='APM' and A.IdPaymentType in (1,4) Then GatewayBranchCode--#3
                     Else ''
end
--''
DiBranchNumber,
--AGREGAR PAYERCODE
CASE 
	WHEN A.IdPaymentType= 2 AND LEN(ISNULL(a.depositaccountnumber,''))=18 THEN 'CLB' 
	WHEN A.IdPaymentType= 2 AND LEN(ISNULL(a.depositaccountnumber,''))=16 THEN 'CDN'--#1
	WHEN A.IdPaymentType= 2 AND LEN(ISNULL(a.depositaccountnumber,''))=11 THEN 'CAN' 
	ELSE '' END DiAccountTypeCode, 
ISNULL(a.depositaccountnumber,'') DiAccountNumber,

--senderpaymentmethod
'CSH' TypeCode,
'' AccountNumber,
'' BicCode,
'' ReferenceNumber ,

--sender
A.CustomerAddress SAiAddress,
A.CustomerCity SAiCity,
'USA' SAiCountryCode,
ltrim(rtrim(isnull(A.CustomerState,'000'))) SAiStateCode,
A.CustomerZipCode SAiZipCode,
'' SEmail,
A.CustomerPhoneNumber SHomePhoneNumber,
'' SWorkPhoneNumber,
'' SCpCarrierCode,
'' SCpCountryCode,
CustomerCelullarNumber SCpNumber,
'NOT' SReceiveEmail,
'NOT' SReceiveSms,
isnull(k.ApprizaIdentificationType,'') SiTypeCode,
IsNull(A.CustomerIdentificationNumber,'') SiNumber,
isnull(CONVERT(varchar(8),A.CustomerExpirationIdentification,112),CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN 'NOTAPPLY' ELSE '' END)  SiExpirationDate,
isnull(IC.CountryCode,CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN 'USA' ELSE '' END) SiIssuerCountryCode,
--CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN CASE WHEN (isnull(IC.CountryCode,'')='USA' OR isnull(IC.CountryCode,'')='MEX') THEN ISNULL(IST.StateCodeISO3166,'') ELSE '000' END ELSE '' END SiIssuerStateCode, 
CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN CASE WHEN (isnull(IC.CountryCode,'')='USA' OR isnull(IC.CountryCode,'')='MEX') THEN ISNULL(CASE WHEN isnull(IC.CountryCode,'')='USA' THEN IST.StateCodeISO3166 ELSE '' END,'') ELSE '000' END ELSE '' END SiIssuerStateCode,--#2
CustomerSSNumber SocialSecurityNumber,
REPLACE(isnull(CONVERT(varchar(8),A.CustomerBornDate,112),''),'19000101','')  DateOfBirth,
ISNULL(A.CustomerOccupation,'') Occupation,
ISNULL(ISS.CountryCode,'') SPobCountryCode,
'' SPobStateCode,
'' SPobCity,
Convert(varchar(20),IdCustomer) SCustomerNumber,
A.CustomerName SFirstName,
'' SMiddleName,
A.CustomerFirstLastName SLastName,
A.CustomerSecondLastName SMotherMaidenName,
'' BfFirstName,
'' BfMiddleName,
'' BfLastName,
A.BeneficiaryAddress BAiAddress,
--A.BeneficiaryCity BAiCity,
I.CITYNAME BAiCity,
C.CountryCode BAiCountryCode,
CASE WHEN (isnull(C.CountryCode,'')='USA' OR isnull(C.CountryCode,'')='MEX') THEN ltrim(rtrim(isnull(SI.StateCodeISO3166,'000'))) ELSE '000' END BAiStateCode, --revisar
ISNULL(A.BeneficiaryZipcode,'') BAiZipCode,
'' BCpCarrierCode,
'' BCpCountryCode,
ISNULL(A.BeneficiaryCelularNumber,'') BCpNumber,
'' BEmail,
ISNULL(A.BeneficiaryPhoneNumber,'') BHomePhoneNumber,
'' BWorkPhoneNumber,
'NOT' BReceiveEmail,
'NOT' BReceiveSms,
isnull(l.ApprizaIdentificationType,CASE WHEN LEN (ISNULL(BeneficiaryIdentificationNumber,''))>0 THEN 'SIC' ELSE '' END) BiTypeCode, 
ISNULL(BeneficiaryIdentificationNumber,'') BiNumber,
CASE WHEN LEN (ISNULL(BeneficiaryIdentificationNumber,''))>0 THEN 'NOTAPPLY' ELSE '' END  BiExpirationDate,
CASE WHEN LEN (ISNULL(BeneficiaryIdentificationNumber,''))>0 THEN C.CountryCode ELSE '' END BiIssuerCountryCode,
'' BiIssuerStateCode,
A.IDBENEFICIARY BCustomerNumber,
BeneficiaryName BFirstName,
'' BMiddleName,
BeneficiaryFirstLastName BLastName,
BeneficiarySecondLastName BMotherMaidenName                                   
From Transfer A                     
Join CountryCurrency B on (A.IdCountryCurrency=B.IdCountryCurrency)                                    
Join Country C on (B.IdCountry=C.IdCountry)
Join Currency D on (D.IdCurrency=B.IdCurrency)           
JOIN AGENT E ON E.IDAGENT=A.IDAGENT 
Join Payer G on (G.IdPayer=A.IdPayer)         
left Join Country IC on (A.CustomerIdentificationIdCountry=IC.IdCountry)
left Join State  IST on (A.CustomerIdentificationIdState=IST.IdSTATE)
left Join Country ISS on (A.CustomerIdCountryOfBirth=ISS.IdCountry)
LEFT JOIN BRANCH h ON H.IdBranch=A.IdBranch
LEFT JOIN CITY I ON I.IDCITY=H.IDCITY
LEFT JOIN STATE SI ON SI.IDSTATE=I.IDSTATE
Left Join CustomerIdentificationType K on (A.CustomerIdCustomerIdentificationType=K.IdCustomerIdentificationType)    
Left Join BeneficiaryIdentificationType L on (A.IdBeneficiaryIdentificationType=L.IdbeneficiaryIdentificationType)  
Where a.IdGateway=@IdGateway and IdStatus=21 