CREATE procedure [dbo].[st_GetAgentApplicationCompleteById]
(
    @idAgentApplication int
    ,@IsSubAccount bit =  null
)
as
/********************************************************************
--exec [st_GetAgentApplicationById] 2,null
<Author> ??? </Author>
<app> Corporative </app>
<Description> Gets agent application information</Description>

<ChangeLog>
<log Date="14/09/2017" Author="snevarez">S39:Add IsSubAccount:Gets Agent Application Status History</log>
</ChangeLog>
*********************************************************************/
select
    a.AgentActivity activity,
    a.agentAddress agentAddress,
    s.StatusName agentApplicationStatusName,
    b.BankName  agentBankName,
    b.AccountNumber agentAccountNumber,
    ach_com.BankName achBankName,
    bt.Name agentBusinessTypeName,
    a.AgentCity agentCity,
    a.AgentCode agentCode,
    ac.Communication agentCommunicationName,
    a.AgentContact agentContact,
    isnull(c.CountyName,'') agentCounty,
    a.AgentFax agentFax,
    a.AgentName agentName,
    a.AgentPhone agentPhone,
    r.Name agentReceiptTypeName,
    isnull(a.AgentState,'') agentState,
    isnull(st.StateName,'') agentStateName,
    a.AgentTimeInBusiness agentTimeInBusiness,
    a.AgentBusinessEmail agentBusinessEmail,
    a.AgentBusinessWebsite agentBusinessWebsite,
    a.AgentCheckCasher agentCheckCasher,
    a.AgentCheckLicense agentCheckLicense,
    a.AgentCheckLicenseNumber agentCheckLicenseNumber,
    a.AgentFinCENReg agentFinCENReg,
    a.AgentFinCENRegExpiration agentFinCENRegExpiration,
    a.MailCheckTo mailCheckTo,
    a.ComplianceOfficerPlaceOfBirth complianceOfficerPlaceOfBirth,
    a.ComplianceOfficerDateOfBirth complianceOfficerDateOfBirth,
    a.AgentZipCode agentZipCode,
    a.BusinessPermissionExpiration businessPermissionExpiration,
    isnull(a.BusinessPermissionNumber,'') businessPermissionNumber,
    a.CommissionAgent commissionAgent,
    a.CommissionAgentOtherCountries commissionAgentOtherCountries,
    a.CommissionCorp commissionCorp,
    a.CommissionCorpOtherCountries commissionCorpOtherCountries,
    a.DateOfCreation dateOfCreation,
    a.DateOfLastChange dateOfLastChange,
    a.doneOnFridayPayOn,
    a.doneOnMondayPayOn,
    a.doneOnSaturdayPayOn,
    a.doneOnSundayPayOn,
    a.doneOnThursdayPayOn,
    a.doneOnTuesdayPayOn,
    a.doneOnWednesdayPayOn,
    a.enterByIdUser,
    a.guarantorAddress,
    a.guarantorBornCountry,
    a.guarantorBornDate,
    a.guarantorCel,
    a.guarantorCity,
    --a.guarantorCounty,
    a.idcountyguarantor idguarantorcounty,
    isnull(cog.CountyName,'') guarantorCounty,
    a.guarantorCreditScore,
    a.guarantorEmail,
    a.guarantorIdExpirationDate,
    a.guarantorIdNumber,
    a.guarantorIdType,
    isnull(ct.Name, '') GuarantorIdTypeName, -- nombre de la identifgicacion en ingles
    isnull(ct.NameES, '') GuarantorIdTypeNameEs, -- nombre de identificacion en español
    a.guarantorLastName,
    a.guarantorName,
    a.guarantorPhone,
    a.guarantorSecondLastName,
    a.guarantorSsn,
    isnull(a.guarantorState,'') guarantorState,
    isnull(stg.StateName,'') guarantorStateName,
    a.guarantorZipCode,
    a.hasAch,
    a.hasBillPayment,
    a.hasFlexStatus,
    a.IdAgentApplication id,
    a.idAgentApplicationBankDeposit,
    a.idAgentApplicationCommunication,
    a.idAgentApplicationReceiptType,
    a.idAgentApplicationStatus,
    a.idAgentBusinessType,
    a.idAgentApplicationStatus idAgentStatus,
    a.idcounty idCountyAgent,
    a.idOwner,
    a.idUserSeller,
    a.notes,
    o.Address ownerAddress,
    o.BornCountry ownerBornCountry,
    o.BornDate ownerBornDate,
    o.Cel ownerCel,
    o.City ownerCity,
    o.IdCounty idCountyOwner,
    isnull(co.CountyName,'') ownerCounty,
    o.CreditScore ownerCreditScore,
    o.Email ownerEmail,
    o.IdExpirationDate ownerIdExpirationDate,
    o.IdNumber ownerIdNumber,
    o.IdType ownerIdType,
    o.IdType ownerIdTypeName,
    o.LastName ownerLastName,
    o.Name ownerName,
    o.Phone ownerPhone,
    o.SecondLastName ownerSecondLastName,
    o.SSN ownerSsn,
    o.TypeTaxId OwnerTypeTaxId,
    o.IdCountryEmission idCountryEmission,
    o.IdStateEmission idStateEmission,
    case when isnull(o.State,'')='null' then '' else isnull(o.State,'') end ownerState,
    isnull(sto.StateName,'') ownerStateName,
    o.Zipcode ownerZipcode,
    a.taxId,
    a.TypeTaxId TypeTaxId,
    a.idAgentClass,
    isnull(a.doingBusinessAs,'') doingBusinessAs,
    a.idAgentPaymentSchema,
    a.retainMoneyCommission,
    a.idAgentCommissionPay,
    isnull(a.accountNumberCommission,'') accountNumberCommission,
    isnull(a.routingNumberCommission,'') routingNumberCommission,
    u.UserName UserSellerName,
	a.NeedsWFSubaccount,
	a.RequestWFSubaccount

	,o.[IdStatus]  AS  OwnerGenericStatus /*S13:Habilitar Opcion de Editar y Seleccionar Otro Dueño*/
	, cla.Name ClassName
	, a.ComplianceOfficerTitle
	, a.ComplianceOfficerName
from AgentApplications a WITH(NOLOCK)
    join [dbo].[AgentApplicationStatuses] s WITH(NOLOCK) on a.IdAgentApplicationStatus=s.IdAgentApplicationStatus
    join [dbo].[AgentBankDeposit] b		WITH(NOLOCK) on a.IdAgentApplicationBankDeposit = b.IdAgentBankDeposit
    join [dbo].[AgentBusinessTypes] bt	WITH(NOLOCK) on a.IdAgentBusinessType=bt.IdAgentBusinessType
    join dbo.AgentCommunication ac	WITH(NOLOCK) on a.IdAgentApplicationCommunication = ac.IdAgentCommunication
    join dbo.AgentReceiptType r		WITH(NOLOCK) on a.IdAgentApplicationReceiptType = r.IdAgentReceiptType
	join AgentClass cla with(nolock) on cla.IdAgentClass  = a.idAgentClass
    left join CustomerIdentificationType ct  WITH(NOLOCK) on ct.IdCustomerIdentificationType = a.GuarantorIdType -- nombre de la identificaciónd e guarantor
    left join County c	WITH(NOLOCK) on a.IdCounty=c.IdCounty
    left join state st	WITH(NOLOCK) on a.AgentState=st.StateCode and st.IdCountry=18
    left join state stg WITH(NOLOCK) on a.GuarantorState=stg.StateCode and stg.IdCountry=18
    left join owner o	WITH(NOLOCK) on a.IdOwner=o.IdOwner
    left join County co WITH(NOLOCK) on o.IdCounty=co.IdCounty
    left join state sto WITH(NOLOCK) on o.State =sto.StateCode and sto.IdCountry=18
    left join users u	WITH(NOLOCK) on a.IdUserSeller=u.iduser
    left join County cog WITH(NOLOCK) on a.IdCountyguarantor=cog.IdCounty
    left join AgentAppACHAgreement ach_com WITH(NOLOCK) on a.IdAgentApplication = ach_com.IdAgentApplication
where a.IdAgentApplication=@idAgentApplication;

    /*Orgin-Begin*/
    --select
    --    h.DateOfMovement DateOfMovementStr,
    --    h.IdAgentApplicationStatusHistory,
    --    h.IdAgentApplicationStatus,
    --    h.Note,
    --    u.UserName,
    --    s.StatusName,
    --    h.DateOfMovement
    --from AgentApplicationStatusHistory h WITH(NOLOCK)
    --    join AgentApplicationStatuses s WITH(NOLOCK) on h.IdAgentApplicationStatus=s.IdAgentApplicationStatus
    --    join users u WITH(NOLOCK) on h.IdUserLastChange=u.IdUser
    --where h.IdAgentApplication=@idAgentApplication
    --ORDER BY h.DateOfMovement DESC
    /*Origin-End*/

    /*S39-Begin*/
    set @IsSubAccount = ISNULL(@IsSubAccount,0);

	 --Table:AgentApplicationStatuses
	   --IdAgentApplicationStatus	 StatusCodeName					StatusName
	   --21						NeedsWellsFargo					Needs Wells Fargo
	   --22						RequestWellsFargo					Request Wells Fargo
	   --23						WellsFargoSubAccountReportGenerated	Wells Fargo Sub Account Report Generated
	   --QA:26/Stage:24			RequestWellsFargoCancelled			Request for Wells Fargo Sub Account was cancelled
	   --QA:28/Stage:25			DoesntNeedWellsFargo				Doesn’t Need Wells Fargo Sub Account
    select
	   h.DateOfMovement DateOfMovementStr,
	   h.IdAgentApplicationStatusHistory,
	   h.IdAgentApplicationStatus,
	   h.Note,
	   u.UserName,
	   s.StatusName,
	   h.DateOfMovement
    from AgentApplicationStatusHistory h WITH(NOLOCK)
	   join AgentApplicationStatuses s WITH(NOLOCK) on h.IdAgentApplicationStatus=s.IdAgentApplicationStatus
	   join users u WITH(NOLOCK) on h.IdUserLastChange=u.IdUser
    where h.IdAgentApplication=@idAgentApplication
	   And
	   (
		  (@IsSubAccount = 0 AND h.IdAgentApplicationStatus = h.IdAgentApplicationStatus)
		  OR
		  (@IsSubAccount = 1 AND h.IdAgentApplicationStatus NOT IN (21,22,23,24,25))
	   )
    order by  h.DateOfMovement desc;
    /*S39-End*/

select
    c.IdAgentApplicationCompetition,
    c.Transmitter,
    c.Country,
    c.FxRate,
    c.TransmitterFee,
    c.MaxiFee
from AgentApplicationCompetition c WITH(NOLOCK)
    where c.IdAgentApplication=@idAgentApplication;

select
    p.IdAgentApplicationPhoneNumber,
    p.IdAgentApplication,
    isnull(p.PhoneNumber,'') PhoneNumber,
    isnull(p.Comment,'') CommentPhone
from AgentApplicationPhoneNumber p WITH(NOLOCK)
    where p.IdAgentApplication=@idAgentApplication;
/*
select r.IdCountyClass IdAgentApplicationCountyClass, c.CountyClassName AgentApplicationCountyClassName from RelationCountyCountyClass r
join CountyClass c on r.IdCountyClass = c.IdCountyClass
where idcounty in
(
select idcounty from AgentApplications a where a.IdAgentApplication=@idAgentApplication
)*/ -- no se ocupa, ya se hace esto en código
/*
select r.IdCountyClass  IdOwnerCountyClass, c.CountyClassName OwnerCountyClassName from RelationCountyCountyClass r
join CountyClass c on r.IdCountyClass = c.IdCountyClass
where idcounty in
(
select idcounty from owner where idowner in (select idowner from AgentApplications a where a.IdAgentApplication=@idAgentApplication)
)*/ -- no se ocupa, ya se hace esto en código

select
    r.IdCountyClass IdGuarantorCountyClass
    , c.CountyClassName GuarantorCountyClassName
from RelationCountyCountyClass r WITH(NOLOCK)
    join CountyClass c WITH(NOLOCK) on r.IdCountyClass = c.IdCountyClass
    where idcounty in
    (
	   select idcountyguarantor from AgentApplications a  WITH(NOLOCK) where a.IdAgentApplication=@idAgentApplication
    );


select
       c.CountryName,
       f.PercentageFee
from FeesAgentApplication f WITH(NOLOCK)
    join Country c WITH(NOLOCK) on c.IdCountry = f.IdCountry
where f.IdAgentApplication=@idAgentApplication

select
    p.PayerName,
    c.CountryName,
    e.ExceptionAgentFee
from ExceptionsAgentApplication e WITH(NOLOCK)
    join Country c WITH(NOLOCK) on c.IdCountry = e.IdCountry
    join Payer p WITH(NOLOCK) on p.IdPayer = e.IdPayer
where e.IdAgentApplication=@idAgentApplication
