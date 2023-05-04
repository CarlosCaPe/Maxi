CREATE PROCEDURE [Corp].[st_GetLongDistanceDetailbyIdProductTransfer_Operation]
(
    @IdProductTransfer bigint
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

SET NOCOUNT ON;

declare @IdOtherProduct int;

select @IdOtherProduct=IdOtherProduct from operation.ProductTransfer with(nolock) where IdProductTransfer=@IdProductTransfer

if @IdOtherProduct=10
begin

    Select       
        t.IdProductTransfer,
        t.EnterByIdUser,
        u.[UserName] username,
        t.idagent,
        --t.TransactionProviderDate,
        t.DateOfCreation TransactionProviderDate,
        t.DateOfStatusChange,
        dbo.[fnFormatPhoneNumber](piv.Phone) AccountNumber, 
        piv.SenderName,
        '' SenderFirstLastName,
        '' SenderSecondLastName,
        piv.SenderAddress,        
        piv.SenderCity,
        piv.SenderState,
        'USA' SenderCountry,
        null SenderZipCode,
        null PromoCode,
        t.Amount Amount,
        null fee,
        t.AgentCommission,
        t.CorpCommission,
        t.idstatus,
        piv.LNStatus LastReturnCode,
        null Response,
        null Request,
        t.EnterByIdUserCancel,        
        isnull(u2.Userlogin,'') UserNameCancel,   
        t.TransactionProviderCancelDate,
        t.TransactionProviderID AgentReferenceNumber,
        t.TransactionProviderID,
        null ConfirmationCode,
        null SenderPhoneNumber,
        StatusName,
        piv.AccessNumber,
        a.Agentcode+' '+a.agentname SelectedAgent,
        t.idprovider,
        pr.providername,
        t.IdOtherProduct,
		piv.D1Discount Discount --- Se regresa el Discount 1 que es con el que se calculan las comisiones
    from Operation.ProductTransfer t with(nolock)
	inner join Agent a with(nolock) on a.IdAgent= t.IdAgent
	inner join Users u with(nolock) on u.IdUser= t.EnterByIdUser
    left join users u2 with(nolock) on t.EnterByIdUserCancel=u2.iduser     
    inner join lunex.TransferLN piv with(nolock) on piv.IdProductTransfer=t.IdProductTransfer
    inner join [status] s with(nolock) on t.idstatus=s.idstatus
    inner join providers pr with(nolock) on pr.idprovider=t.idprovider
	where t.IdProductTransfer=@IdProductTransfer
end


if @IdOtherProduct=5
begin
    Select       
        t.IdProductTransfer,
        t.EnterByIdUser,
        u.[UserName] username,
        t.idagent,
        --t.TransactionProviderDate,
        t.DateOfCreation TransactionProviderDate,
        t.DateOfStatusChange,
        piv.ReceiveAccountNumber AccountNumber, 
        ISNULL(piv.SenderName,'') SenderName,
        ISNULL(piv.SenderFirstLastName,'') SenderFirstLastName,
        ISNULL(piv.SenderSecondLastName,'') SenderSecondLastName,
        piv.SenderAddress,
        piv.SenderCity,
        piv.SenderState,
        piv.SenderCountry,
        piv.SenderZipCode,
        piv.PromoCode,
        t.Amount Amount,
        piv.fee Fee, 
        t.AgentCommission,
        t.CorpCommission,
        t.idstatus,
        piv.LastReturnCode,
        piv.Response,
        piv.Request,
        t.EnterByIdUserCancel,        
        isnull(u2.Userlogin,'') UserNameCancel, 
        t.TransactionProviderCancelDate,
        piv.AgentReferenceNumber,
        t.TransactionProviderID,
        piv.ConfirmationCode,
        piv.SenderPhoneNumber,
        StatusName,
        piv.AccessNumber,
        a.Agentcode+' '+a.agentname SelectedAgent,
        t.idprovider,
        pr.providername,
        t.IdOtherProduct,
		0.0 Discount
    from Operation.ProductTransfer t with(nolock)
	inner join Agent a with(nolock) on a.IdAgent= t.IdAgent
	inner join Users u with(nolock) on u.IdUser= t.EnterByIdUser
    left join users u2 with(nolock) on t.EnterByIdUserCancel=u2.iduser     
    inner join pureminutestransaction piv with(nolock) on piv.IdProductTransfer=t.IdProductTransfer
    inner join [status] s with(nolock) on t.idstatus=s.idstatus
    inner join providers pr with(nolock) on pr.idprovider=t.idprovider
	where t.IdProductTransfer=@IdProductTransfer
end


