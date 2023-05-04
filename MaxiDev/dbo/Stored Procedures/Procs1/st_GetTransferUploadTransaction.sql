CREATE PROCEDURE [dbo].[st_GetTransferUploadTransaction]
	@idTransfer int
AS
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
	If exists(Select 1 from [Transfer] with(nolock) where IdTransfer=@IdTransfer)    
	begin
		select top 1 t.IdAgent,u.FileGuid, u.Extension
		from [Transfer] t  with(nolock)
		inner join UploadFiles u  with(nolock) on t.IdAgent = u.IdReference
		inner join Agent a with(nolock) on t.IdAgent = a.IdAgent
		where t.IdTransfer = @idTransfer
		and u.IdDocumentType = 58
		and u.IdStatus = 1
		and a.ShowLogo = 1 
		order by u.IdUploadFile desc
	end
	else
	begin
		select top 1 t.IdAgent,u.FileGuid, u.Extension
		from TransferClosed t   with(nolock)
		inner join UploadFiles u  with(nolock) on t.IdAgent = u.IdReference
		inner join Agent a with(nolock) on t.IdAgent = a.IdAgent
		where t.IdTransferClosed = @idTransfer
		and u.IdDocumentType = 58
		and u.IdStatus = 1
		and a.ShowLogo = 1 
		order by u.IdUploadFile desc
	end
