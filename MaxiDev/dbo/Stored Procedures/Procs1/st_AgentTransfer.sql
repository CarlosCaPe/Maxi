CREATE procedure [dbo].[st_AgentTransfer]              
(
    @IdAgent int = null,
    @DateFrom datetime,
    @DateTo datetime
)
as             

/********************************************************************
<Author>unk</Author>
<app>MaxiAgent</app>
<Description>Obtiene las transacciones por periodo de fecha y/o agente</Description>

<ChangeLog>
<log Date="15/06/2018" Author="jmolina">Se elimino el LEFT hacia la tabla de User y se agrego como sub-query la tabla Payer </log>
</ChangeLog>
********************************************************************/                                                                        

--Set nocount on         
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
    CustomerName + ' ' + CustomerFirstLastName + ' ' + ISNULL(CustomerSecondLastName, '') Sender,
    BeneficiaryName + ' ' + BeneficiaryFirstLastName + ' ' + ISNULL(BeneficiarySecondLastName, '') Beneficiary,
    S.StatusName [Status],
	Payer = ISNULL( (select pa.PayerName from dbo.Payer AS pa WITH(NOLOCK) where T.IdPayer = pa.IdPayer), '')
    --isnull(Pa.PayerName,'') Payer
from [Transfer] T WITH(NOLOCK)
Join Agent A WITH(NOLOCK) on A.IdAgent=T.IdAgent
Join PaymentType P WITH(NOLOCK) on P.IdPaymentType=T.IdPaymentType
Join [Status] S WITH(NOLOCK) on S.IdStatus=T.IdStatus
--left Join Payer Pa WITH(NOLOCK) on Pa.IdPayer=T.IdPayer
--left join Users U WITH(NOLOCK) on U.IdUser=T.EnterByIdUser
WHERE 1 = 1
    and T.IdAgent=isnull(@IdAgent,T.IdAgent)
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
    CustomerName + ' ' + CustomerFirstLastName + ' ' + ISNULL(CustomerSecondLastName, '') Sender,
    BeneficiaryName + ' ' + BeneficiaryFirstLastName + ' ' + ISNULL(BeneficiarySecondLastName, '') Beneficiary,
    StatusName [Status],
    isnull(PayerName,'') Payer
from TransferClosed T WITH(NOLOCK)
Join Agent A WITH(NOLOCK) on A.IdAgent=T.IdAgent
--left join Users U WITH(NOLOCK) on U.IdUser=T.EnterByIdUser
WHERE 1 = 1
    and T.IdAgent=isnull(@IdAgent,T.IdAgent)
    and T.DateOfTransfer>=@DateFrom and T.DateOfTransfer<@DateTo
)
Order by 
    AgentCode,DateOfTransfer asc