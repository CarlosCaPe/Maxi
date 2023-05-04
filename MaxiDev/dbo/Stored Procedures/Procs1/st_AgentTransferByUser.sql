CREATE procedure [dbo].[st_AgentTransferByUser]              
(
    @IdAgent int = null,
    @DateFrom datetime,
    @DateTo datetime
)
as     
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
Set nocount on         
Select @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom),@DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)              

(
Select
    DateOfTransfer,
    ClaimCode,
    T.Folio Folio,
    A.AgentCode AgentCode,
    A.AgentName AgentName,
    AmountInDollars Amount,
    Fee FeeTotal,
    AgentCommission FeeFE,
    Fee-AgentCommission FeeMaxi,
    P.PaymentName Payment,
    CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName Sender,
    BeneficiaryName+' '+BeneficiaryFirstLastName+' '+BeneficiarySecondLastName Beneficiary,
    S.StatusName [Status],
    isnull(Pa.PayerName,'') Payer,
    isnull(U.UserName,'') UserName
from 
    [Transfer] T with(nolock)
Join 
    Agent A with(nolock) on T.IdAgent=A.IdAgent
Join 
    PaymentType P with(nolock) on T.IdPaymentType=P.IdPaymentType
Join 
    [Status] S with(nolock) on T.IdStatus=S.IdStatus
left Join 
    Payer Pa with(nolock) on T.IdPayer=Pa.IdPayer
left join
    Users U with(nolock) on T.EnterByIdUser=U.IdUser
WHERE
    T.IdAgent=isnull(@IdAgent,T.IdAgent)
    and T.DateOfTransfer>=@DateFrom and T.DateOfTransfer<@DateTo
)
UNION ALL
(
Select
    DateOfTransfer,
    ClaimCode,
    T.Folio Folio,
    A.AgentCode AgentCode,
    A.AgentName AgentName,
    AmountInDollars Amount,
    Fee FeeTotal,
    AgentCommission FeeFE,
    Fee-AgentCommission FeeMaxi,
    PaymentTypeName Payment,
    CustomerName+' '+CustomerFirstLastName+' '+CustomerSecondLastName Sender,
    BeneficiaryName+' '+BeneficiaryFirstLastName+' '+BeneficiarySecondLastName Beneficiary,
    StatusName [Status],
    isnull(PayerName,'') Payer,
    isnull(U.UserName,'') UserName
from 
    TransferClosed T with(nolock)
Join 
    Agent A with(nolock) on T.IdAgent=A.IdAgent
left join
    Users U with(nolock) on T.EnterByIdUser=U.IdUser
WHERE
    T.IdAgent=isnull(@IdAgent,T.IdAgent)
    and T.DateOfTransfer>=@DateFrom and T.DateOfTransfer<@DateTo
)
Order by 
    AgentCode,DateOfTransfer asc