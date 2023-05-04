CREATE PROCEDURE [dbo].[st_GetPreTransferUploadTransaction]
	@idPreTransfer int
AS
	
		select top 1 t.IdAgent,u.FileGuid, u.Extension
		from PreTransfer t  (nolock)
		inner join UploadFiles u  (nolock) on t.IdAgent = u.IdReference
		inner join Agent a  (nolock) on t.IdAgent = a.IdAgent
		where t.IdPreTransfer = @idPreTransfer
		and u.IdDocumentType = 58
		and u.IdStatus = 1
		and a.ShowLogo = 1 
		order by u.IdUploadFile desc
	