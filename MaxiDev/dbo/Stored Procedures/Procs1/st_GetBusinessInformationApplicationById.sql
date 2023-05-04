create procedure st_GetBusinessInformationApplicationById
(
    @idAgentApplication int
)
as
select 
  a.AgentActivity Activity,
  a.agentAddress Address, 
  a.AgentName AgentName,
  a.AgentCity City,
  a.AgentContact Contact,
  a.AgentFax Fax,
  a.IdAgentApplication IdAgentApplication,
  a.idAgentApplicationCommunication,
  a.idAgentApplicationReceiptType,
  a.BusinessPermissionExpiration PermissionExpiration,
  isnull(a.BusinessPermissionNumber,'') PermissionNumber,
  a.AgentPhone Phone,
  a.TaxId,
  a.AgentTimeInBusiness TimeBusiness,
  a.AgentZipCode ZipCode
from dbo.AgentApplications a
where a.IdAgentApplication=@idAgentApplication
