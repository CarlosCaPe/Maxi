
CREATE procedure [dbo].[st_GetTransferToStatus]
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

select IdStatus, StatusName 
from [OtherProductStatus] with(nolock) 
where idstatus!=1 
order by statusname
