create procedure [dbo].[st_setNewImg]
(
	@Id int, 
	@IdUser int
)
as
if exists(select*from UploadAgentApp where IdAgentApp = @Id)
BEGIN
	update UploadAgentApp set HasNewImg = 1, IdUser = @IdUser where IdAgentApp = @Id
END
ELSE
BEGIN
	insert into UploadAgentApp (IdAgentApp, HasNewImg, IdUser) VALUES (@Id, 1, @IdUser)
END
update AgentApplications set DateOfLastChange = GETDATE() where IdAgentApplication = @Id