CREATE procedure [dbo].[st_SavePendingFiles]
(
	@IsAgentApp bit,
    @IdAgent int, 
	@IdPendingFile int, 
	@IdDocumenteType int, 
	@ExpirationDate DateTime, 
	@IsUpload bit, 
	@IdUser int,
	@IdGenericStatus int,
	@idPendingFileOut int out,
	@HasError bit out,
	@ErrorMessage varchar(max) out
)       
as      
set @HasError = 0
Begin try
if @IsAgentApp = 1
	begin 
		if @IdPendingFile <> 0
			begin
				update PendingFilesAgentApp set IdDocumentType = @IdDocumenteType, ExpirationDate = @ExpirationDate, IsUpload = @IsUpload, IdUserLastChange = @IdUser, DateLastChange = GETDATE(), IdGenericStatus = @IdGenericStatus
				where IdAgentApplication = @IdAgent and IdPendingfilesAgentApp = @IdPendingFile
				set @idPendingFileOut = @IdPendingFile
			end
		else
			begin 
				insert into PendingFilesAgentApp (IdAgentApplication, IdDocumentType, ExpirationDate, IsUpload, IdUserCreate, DateCreate, IdUserLastChange, DateLastChange, IdGenericStatus, SendNotification) 
										values (@IdAgent, @IdDocumenteType, @ExpirationDate, @IsUpload, @IdUser, GETDATE(), @IdUser, GETDATE(), 1, 1)
				set @idPendingFileOut = SCOPE_IDENTITY()
			end
	end
else
	begin
		if @IdPendingFile <> 0
			begin
				update PendingFilesAgent set IdDocumentType = @IdDocumenteType, ExpirationDate = @ExpirationDate, IsUpload = @IsUpload, IdUserLastChange = @IdUser, DateLastChange = GETDATE(), IdGenericStatus = @IdGenericStatus
				where IdAgent = @IdAgent and IdPendingfilesAgent = @IdPendingFile
				set @idPendingFileOut = @IdPendingFile
			end
		else
			begin 
				insert into PendingFilesAgent (IdAgent, IdDocumentType, ExpirationDate, IsUpload, IdUserCreate, DateCreate, IdUserLastChange, DateLastChange, IdGenericStatus) 
										values (@IdAgent, @IdDocumenteType, @ExpirationDate, @IsUpload, @IdUser, GETDATE(), @IdUser, GETDATE(), 1)
				set @idPendingFileOut = SCOPE_IDENTITY()
			end
	end
End try
Begin Catch    
    set @HasError=1                                                                      
    Select @ErrorMessage=ERROR_MESSAGE()   
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SavePendingFiles',Getdate(),@ErrorMessage)
End catch