
CREATE procedure [dbo].[st_DeleteFileFromUploadFiles]
(  
    @FileGuid nvarchar(max),
    @HasError bit out,          
    @MessageOut nvarchar(max) out    
)  
AS  
Set nocount on  
Begin Try  
	declare @IdUploadFile int
	--set @IdUploadFile = (select IdUploadFile from UploadFiles where FileGuid = @FileGuid)
	--delete from ScannerProcessFile where IdUploadFile = @IdUploadFile
	DELETE FROM ScannerProcessFile where IdUploadFile in (select IdUploadFile from UploadFiles WITH(NOLOCK) where FileGuid = @FileGuid);

	DELETE FROM UploadFiles where FileGuid = @FileGuid;
  
	Set @HasError=0          
	Set @MessageOut= @IdUploadFile
End Try                                        
Begin Catch                                        
 Set @HasError=1                               
 Select @MessageOut =''                                        
 Declare @ErrorMessage nvarchar(max)                                         
 Select @ErrorMessage=ERROR_MESSAGE()                                        
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_DeleteFileFromUploadFiles',Getdate(),@ErrorMessage)                                        
End Catch


