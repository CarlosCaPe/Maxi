CREATE procedure [dbo].[st_GetTransferOFACReview]
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

SET NOCOUNT ON;
select IdTransfer,	IdUserReview, UserName,	DateOfReview, r.IdOFACAction, isnull(NameOFACAction,'') NameOFACAction, Note
from TransferOFACReview r with(nolock)
join users u with(nolock) on r.IdUserReview=u.iduser
left join OFACAction a with(nolock) on a.IdOFACAction=r.IdOFACAction
where idtransfer=@IdTransfer
order by dateofreview desc, username