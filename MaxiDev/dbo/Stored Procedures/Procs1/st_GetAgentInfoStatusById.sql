CREATE procedure [dbo].[st_GetAgentInfoStatusById]
(
    @idAgentApplication int
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
    a.AgentCode,
    a.GuarantorCreditScore,
    a.IdAgentApplicationStatus,
    a.IdUserSeller,
    a.OfacBusinessChecked,
    a.OfacGuarantorChecked,
    a.OfacOwnerChecked,
    o.CreditScore OwnerCreditScore
from AgentApplications a with(nolock)
left join [owner] o with(nolock) on a.idowner=o.idowner
where a.IdAgentApplication=@idAgentApplication