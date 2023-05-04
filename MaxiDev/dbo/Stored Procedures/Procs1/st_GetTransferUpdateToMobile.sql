CREATE procedure [dbo].[st_GetTransferUpdateToMobile]
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

DECLARE @GatewayId INT = 31 /*TransferToMobile*/

select 
    ClaimCode,
    UniqueReferenceNumber 
from 
    [Transfer] t with(nolock)
join [TToMobileOperation] o with(nolock) on t.IdTransfer=o.TransferId
where 
t.IdGateway=@GatewayId and t.IdStatus in (29,40)
    