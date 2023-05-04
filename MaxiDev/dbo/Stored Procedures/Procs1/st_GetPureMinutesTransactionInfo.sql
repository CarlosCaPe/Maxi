CREATE procedure [dbo].[st_GetPureMinutesTransactionInfo]
(    
    @IdPureMinutes int
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

select 
    t.IdAgent,
    a.AgentCode+' '+a.AgentName Agent,
    t.IdPureMinutes Folio,
    t.ReceiveAccountNumber ReceiveAccountNumber,
    t.ReceiveAmount Amount,
    t.Fee Fee,
    t.AgentCommission AgentCommission,
    t.CorpCommission MaxiCommission,
    t.DateOfTransaction Date,
    Isnull(t.SenderName,'') +' '+ Isnull(t.SenderFirstLastName,'') +' '+ Isnull(t.SenderSecondLastName,'') Customer,
    t.SenderAddress [Address],
    t.SenderZipCode ZipCode,
    t.SenderCountry Country,
    t.SenderState [State],
    t.SenderCity City,
    U.UserLogin,
    t.PureMinutesTransID,
    t.AgentReferenceNumber,
    t.ConfirmationCode,
    t.CancelDateOfTransaction,
    U2.UserLogin UserLoginCancel,
    isnull(t.Balance,0) Balance,
    t.PromoCode,
    t.CreditForPromoCode,
    t.Bonification,
	t.AccessNumber
	, A.AgentFax
	, A.AgentPhone
	, A.AgentName
	, A.AgentCode
	, A.AgentZipcode
	, A.AgentState
	, A.AgentCity
	, A.AgentAddress
from 
    PureMinutesTransaction t with(nolock)
join 
    Agent a with(nolock) on a.IdAgent=t.IdAgent
left join 
    Users u with(nolock) on u.IdUser= t.IdUser
left join 
    Users u2 with(nolock) on u2.IdUser= t.CancelIdUser
where 
    IdPureMinutes=@IdPureMinutes


/****** Object:  StoredProcedure [dbo].[st_GetOwnerInfoByIdOwner]    Script Date: 06/02/2015 05:54:16 p. m. ******/
SET ANSI_NULLS ON
