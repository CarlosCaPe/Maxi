CREATE PROCEDURE [Corp].[st_GetAgentInfoStatusById]
(
    @idAgentApplication int
)
as
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
left join owner o  with(nolock) on a.idowner=o.idowner
where a.IdAgentApplication=@idAgentApplication
