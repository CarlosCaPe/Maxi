CREATE PROCEDURE [Corp].[st_GetEgiftDetailbyIdProductTransfer_Operation]
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

if @IdOtherProduct=11
begin

    Select       
        t.IdProductTransfer,
        t.EnterByIdUser,
        u.[UserName] username,
        t.idagent,
        t.TransactionProviderDate,
        t.DateOfStatusChange,
        dbo.[fnFormatPhoneNumber](piv.Phone) Phone,
        piv.topupphone,
        t.Amount Amount,        
        t.AgentCommission,
        t.CorpCommission,
        t.idstatus,
        piv.LNStatus LastReturnCode,
        t.EnterByIdUser,        
        isnull(u.Userlogin,'') UserName,   
        t.EnterByIdUserCancel,        
        isnull(u2.Userlogin,'') UserNameCancel,   
        t.TransactionProviderCancelDate,        
        t.TransactionProviderID,        
        StatusName,        
        a.Agentcode+' '+a.agentname SelectedAgent,
        t.idprovider,
        pr.providername,
        t.IdOtherProduct,
        piv.skuname ProductName,
		piv.D1Discount Discount --- se regresa el discount 1 que es con el que se calculan las comisiones
    from Operation.ProductTransfer t with(nolock)
	inner join Agent a with(nolock) on a.IdAgent= t.IdAgent
	inner join Users u with(nolock) on u.IdUser= t.EnterByIdUser
    left join users u2 with(nolock) on t.EnterByIdUserCancel=u2.iduser     
    inner join lunex.TransferLN piv with(nolock) on piv.IdProductTransfer=t.IdProductTransfer
    inner join [status] s with(nolock) on t.idstatus=s.idstatus
    inner join providers pr with(nolock) on pr.idprovider=t.idprovider
	where t.IdProductTransfer=@IdProductTransfer
end

