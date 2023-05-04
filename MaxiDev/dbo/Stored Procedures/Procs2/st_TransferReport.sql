CREATE procedure [dbo].[st_TransferReport]  
(  
@StartDate DateTime,  
@EndDate Datetime  
)  
AS  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON; 
  
Select    
A.IdTransfer,  
E.PaymentName,  
D.PayerName,  
H.GatewayName,  
B.AgentCode,  
B.AgentName,  
C.StatusName,  
G.CountryName,  
A.ClaimCode,  
A.ConfirmationCode,  
A.AmountInDollars,  
A.Fee,  
A.AgentCommission,  
A.CorporateCommission,  
A.DateOfTransfer,  
A.ExRate,  
A.ReferenceExRate,  
A.AmountInMN,  
A.Folio,  
A.DepositAccountNumber,  
A.DateOfLastChange,  
A.EnterByIdUser,  
A.TotalAmountToCorporate,  
A.BeneficiaryName,  
A.BeneficiaryFirstLastName,  
A.BeneficiarySecondLastName,  
A.BeneficiaryAddress,  
A.BeneficiaryCity,  
A.BeneficiaryState,  
A.BeneficiaryCountry,  
A.BeneficiaryZipcode,  
A.BeneficiaryPhoneNumber,  
A.BeneficiaryCelularNumber,  
A.BeneficiarySSNumber,  
A.BeneficiaryBornDate,  
A.BeneficiaryOccupation,  
A.BeneficiaryNote,  
A.CustomerName,  
A.CustomerIdAgentCreatedBy,  
A.CustomerIdCustomerIdentificationType,  
A.CustomerFirstLastName,  
A.CustomerSecondLastName,  
A.CustomerAddress,  
A.CustomerCity,  
A.CustomerState,  
A.CustomerCountry,  
A.CustomerZipcode,  
A.CustomerPhoneNumber,  
A.CustomerCelullarNumber,  
A.CustomerSSNumber,  
A.CustomerBornDate,  
A.CustomerOccupation,  
A.CustomerIdentificationNumber,  
A.CustomerExpirationIdentification  
From [Transfer] A with(nolock) 
Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)  
Join [Status] C with(nolock) on (A.IdStatus=C.IdStatus)  
Join Payer D with(nolock) on (A.IdPayer=D.IdPayer)  
Join PaymentType E with(nolock) on (E.IdPaymentType=A.IdPaymentType)  
Join CountryCurrency F with(nolock) on (F.IdCountryCurrency=A.IdCountryCurrency)  
Join Country G with(nolock) on (G.IdCountry=F.IdCountry)  
Join Gateway H with(nolock) on (H.IdGateway=A.IdGateway)  
Where A.DateOfTransfer>=@StartDate And  A.DateOfTransfer<=@EndDate  
Union       
Select    
A.IdTransferClosed,  
A.PaymentTypeName,  
A.PayerName,  
A.GatewayName,  
B.AgentCode,  
B.AgentName,  
A.StatusName,  
A.CountryName,  
A.ClaimCode,  
A.ConfirmationCode,  
A.AmountInDollars,  
A.Fee,  
A.AgentCommission,  
A.CorporateCommission,  
A.DateOfTransfer,  
A.ExRate,  
A.ReferenceExRate,  
A.AmountInMN,  
A.Folio,  
A.DepositAccountNumber,  
A.DateOfLastChange,  
A.EnterByIdUser,  
A.TotalAmountToCorporate,  
A.BeneficiaryName,  
A.BeneficiaryFirstLastName,  
A.BeneficiarySecondLastName,  
A.BeneficiaryAddress,  
A.BeneficiaryCity,  
A.BeneficiaryState,  
A.BeneficiaryCountry,  
A.BeneficiaryZipcode,  
A.BeneficiaryPhoneNumber,  
A.BeneficiaryCelularNumber,  
A.BeneficiarySSNumber,  
A.BeneficiaryBornDate,  
A.BeneficiaryOccupation,  
A.BeneficiaryNote,  
A.CustomerName,  
A.CustomerIdAgentCreatedBy,  
A.CustomerIdCustomerIdentificationType,  
A.CustomerFirstLastName,  
A.CustomerSecondLastName,  
A.CustomerAddress,  
A.CustomerCity,  
A.CustomerState,  
A.CustomerCountry,  
A.CustomerZipcode,  
A.CustomerPhoneNumber,  
A.CustomerCelullarNumber,  
A.CustomerSSNumber,  
A.CustomerBornDate,  
A.CustomerOccupation,  
A.CustomerIdentificationNumber,  
A.CustomerExpirationIdentification  
From TransferClosed A with(nolock)  
Join Agent B with(nolock) on (A.IdAgent=B.IdAgent)  
Where A.DateOfTransfer>=@StartDate And  A.DateOfTransfer<=@EndDate
