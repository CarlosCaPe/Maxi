CREATE procedure [dbo].[st_GetAgentAppACHAgreement]
(
    @IdAgentApplication int
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

select o.Name+' '+o.LastName+' '+o.SecondLastName OwnerName,isnull(a.BankName,'') BankName, isnull(a.Addreess,'') Addreess, isnull(a.City,'') City, isnull(a.[State],'') [State],isnull(a.ZipCode,'') ZipCode, app.AgentName, app.RoutingNumberCommission, app.AccountNumberCommission, app.DateofLastChange
from AgentApplications app with(nolock)
left join [AgentAppACHAgreement] a with(nolock) on a.IdAgentApplication=app.IdAgentApplication
left join [owner] o with(nolock) on app.idowner=o.idowner
where app.IdAgentApplication=@IdAgentApplication