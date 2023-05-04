CREATE PROCEDURE [dbo].[st_CheckPendingFile]
(
	@IdAgent int, --1240
	@IsAgent bit,  --0
	@IdDocumentType int,
	@IdUploadFile int,
	@IdUser int
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

if @IsAgent = 0
begin 
	if (select top 1 1 from PendingFilesAgent with(nolock) where IdGenericStatus = 1 and IsUpload = 0 and ExpirationDate >= GETDATE() and IdAgent = @IdAgent and IdDocumentType = @IdDocumentType) > 0
	begin 
		update PendingFilesAgent set IsUpload = 1, IdUploadFile = @IdUploadFile, IdUserLastChange = @IdUser, DateLastChange = GETDATE() where IdGenericStatus = 1 and IsUpload = 0 and ExpirationDate >= GETDATE() and IdAgent = @IdAgent and IdDocumentType = @IdDocumentType;
	end
end
else
begin
	if (select top 1 1 from PendingFilesAgentApp with(nolock) where IdGenericStatus = 1 and IsUpload = 0 and ExpirationDate >= GETDATE() and IdAgentApplication = @IdAgent and IdDocumentType = @IdDocumentType) > 0
	begin 
		update PendingFilesAgentApp set IsUpload = 1, IdUploadFile = @IdUploadFile, IdUserLastChange = @IdUser, DateLastChange = GETDATE() where IdGenericStatus = 1 and IsUpload = 0 and ExpirationDate >= GETDATE() and IdAgentApplication = @IdAgent and IdDocumentType = @IdDocumentType;
	end
end
