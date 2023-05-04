
CREATE procedure [dbo].[st_setViewImg]
(
 @Id int
)
as
if exists(select*from UploadAgentApp where IdAgentApp = @Id) and exists(select*from UploadAgentApp where IdAgentApp = @Id and HasNewImg = 1)
BEGIN
update UploadAgentApp set HasNewImg = 0 where IdAgentApp = @Id
update AgentApplications set DateOfLastChange = GETDATE() where IdAgentApplication = @Id
end