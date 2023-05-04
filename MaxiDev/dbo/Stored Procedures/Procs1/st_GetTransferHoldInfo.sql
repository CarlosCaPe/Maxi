CREATE PROCEDURE [dbo].[st_GetTransferHoldInfo]
(
    @IdTransfer int
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
select 
    IdTransferHold, Idtransfer,h.IdStatus,s.StatusName, IsReleased, DateOfValidation,h.DateOfLastChange,h.EnterByIdUser, UserName EnterByUser
from transferholds h with(nolock)
join [status] s with(nolock) on h.IdStatus=s.idstatus
join users u with(nolock) on u.iduser=h.EnterByIdUser
where idtransfer=@IdTransfer
