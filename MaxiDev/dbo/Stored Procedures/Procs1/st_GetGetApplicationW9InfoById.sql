create procedure st_GetGetApplicationW9InfoById
(
    @idAgentApplication int
)
as
select 
    a.agentAddress Addreess,
    a.AgentName BusinessName,
    a.agentcity City,
    o.Name Name,
    o.LastName LastName,
    o.SecondLastName SecondLastName,
    o.ssn Ssn,
   isnull(a.AgentState,'') State,
   isnull(st.StateName,'') StateName,
   a.AgentZipCode ZipCode
from AgentApplications a
left join owner o on a.IdOwner=o.IdOwner
left join state st on a.AgentState=st.StateCode and st.IdCountry=18
where a.IdAgentApplication=@idAgentApplication