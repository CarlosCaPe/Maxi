CREATE PROCEDURE [Corp].[st_setViewImg]
(
 @Id int
)
as
if exists(select 1 from UploadAgentApp with(NOLOCK) where IdAgentApp = @Id) and exists(select 1 from UploadAgentApp with(NOLOCK) where IdAgentApp = @Id and HasNewImg = 1)
BEGIN
update UploadAgentApp set HasNewImg = 0 where IdAgentApp = @Id
update AgentApplications set DateOfLastChange = GETDATE() where IdAgentApplication = @Id
end
