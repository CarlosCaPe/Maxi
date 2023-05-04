CREATE procedure [dbo].[st_GetApprizaCancel]                                    
as   

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="24/07/2018" Author="jdarellano" Name="#1">Se valida fecha de expiración de Id de Cliente para casos expirados.</log>
</ChangeLog>
*********************************************************************/

SELECT 
A.Claimcode as UniqueReferenceNumber,
A.Claimcode as OrderTrackingNumber,
CASE WHEN ISNULL([ReturnAllComission],0)=1 THEN 'TEL' ELSE 'CUS' END ProcessReasonTypeCode,

--BRANCH
 dbo.fn_EspecialChrOFF(E.AGENTCODE) BranchLocationUnit,
 E.IdAgent BranchNumber,
 'BRN' BranchTypeCode, 
 'USA' BranchCountryCode,
 ltrim(rtrim(isnull(E.AgentState,'000'))) BranchStateCode,
 '' BranchSupervisorId,
Convert(varchar(20), A.Enterbyiduser) BranchUserId,
'1' BranchTerminalId,

CONVERT(varchar(8),a.DateStatusChange,112) ProcessDate,
replace(convert(varchar, a.DateStatusChange, 108),':','') ProcessTime,
Convert(varchar(20),a.Fee) ServiceFeeAmount,
'' DiscountAmount,
'' DiscountReasonTypeCode,
'USD' CurrencyCode,

--senderpaymentmethod
'CSH' TypeCode,
'' AccountNumber,
'' BicCode,
'' ReferenceNumber ,

--SENDER
isnull(k.ApprizaIdentificationType,'') SiTypeCode,
IsNull(A.CustomerIdentificationNumber,'') SiNumber,
--isnull(CONVERT(varchar(8),A.CustomerExpirationIdentification,112),CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN 'NOTAPPLY' ELSE '' END)  SiExpirationDate,
iif(CAST(A.CustomerExpirationIdentification as date)<CAST(GETDATE()as date),CONVERT(varchar(8),GETDATE()+1,112),isnull(CONVERT(varchar(8),A.CustomerExpirationIdentification,112),CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN 'NOTAPPLY' ELSE '' END))  SiExpirationDate,--#1
isnull(IC.CountryCode,CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN 'USA' ELSE '' END) SiIssuerCountryCode,
--CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN CASE WHEN (isnull(IC.CountryCode,'')='USA' OR isnull(IC.CountryCode,'')='MEX') THEN ISNULL(IST.StateCodeISO3166,'') ELSE '000' END ELSE '' END SiIssuerStateCode
CASE WHEN LEN(IsNull(A.CustomerIdentificationNumber,''))>0 THEN CASE WHEN (isnull(IC.CountryCode,'')='USA' OR isnull(IC.CountryCode,'')='MEX') THEN ISNULL(CASE WHEN isnull(IC.CountryCode,'')='USA' THEN IST.StateCodeISO3166 ELSE '' END,'') ELSE '000' END ELSE '' END SiIssuerStateCode
From dbo.[Transfer] A with (nolock)
Join dbo.CountryCurrency B with (nolock) on (A.IdCountryCurrency=B.IdCountryCurrency)                                            
JOIN dbo.Agent E with (nolock) ON E.IDAGENT=A.IDAGENT 
Join dbo.Currency D with (nolock) on (D.IdCurrency=B.IdCurrency)           
LEFT JOIN  dbo.[ReasonForCancel] RC with (nolock) ON A.[IdReasonForCancel]=RC.[IdReasonForCancel]
Left Join dbo.CustomerIdentificationType K with (nolock) on (A.CustomerIdCustomerIdentificationType=K.IdCustomerIdentificationType)    
left Join dbo.Country IC with (nolock) on (A.CustomerIdentificationIdCountry=IC.IdCountry)
left Join dbo.[State] IST with (nolock) on (A.CustomerIdentificationIdState=IST.IdSTATE)
Where A.IdGateway=32 and A.IdStatus=25 and DateOfTransfer>='2020-07-12'--or A.ClaimCode='700700265890'