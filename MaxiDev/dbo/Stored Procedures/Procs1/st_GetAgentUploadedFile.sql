CREATE PROCEDURE [dbo].[st_GetAgentUploadedFile]
	@idAgent int
AS
		select top 1 a.IdAgent,u.FileGuid, u.Extension
		from Agent a (nolock)
		inner join UploadFiles u  (nolock) on a.IdAgent = u.IdReference
		where a.IdAgent = @idAgent
		and u.IdDocumentType = 58
		and u.IdStatus = 1
		and a.ShowLogo = 1 
		order by u.IdUploadFile desc
