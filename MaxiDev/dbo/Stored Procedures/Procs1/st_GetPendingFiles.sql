create procedure [dbo].[st_GetPendingFiles]
(
	@IsAgentApp bit,
    @IdAgent int           
)              
as      
Begin try
if @IsAgentApp = 1
	begin 
		select f.ExpirationDate ExpirationDate, f.IdDocumentType IdDocumentType, f.IdPendingfilesAgentApp IdPendingFiles, f.IsUpload IsUpload, f.IdGenericStatus IdGenericStatus from PendingFilesAgentApp f where IdAgentApplication = @IdAgent and IdGenericStatus = 1
	end
else
	begin
		select f.ExpirationDate ExpirationDate, f.IdDocumentType IdDocumentType, f.IdPendingFilesAgent IdPendingFiles, f.IsUpload IsUpload, f.IdGenericStatus IdGenericStatus from PendingFilesAgent f where IdAgent = @IdAgent and IdGenericStatus = 1
	end
End try
Begin Catch
    Declare @ErrorMessage nvarchar(max)                                                                               
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetPendingFiles',Getdate(),@ErrorMessage)
End catch