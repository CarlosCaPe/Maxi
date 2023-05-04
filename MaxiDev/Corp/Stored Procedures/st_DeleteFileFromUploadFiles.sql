CREATE procedure [Corp].[st_DeleteFileFromUploadFiles]
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
delete from ScannerProcessFile where IdUploadFile in (select IdUploadFile from UploadFiles with(nolock) where FileGuid = @FileGuid)
delete from UploadFiles where FileGuid = @FileGuid
  
Set @HasError=0          
Set @MessageOut= @IdUploadFile
End Try                                        
Begin Catch                                        
 Set @HasError=1                               
 Select @MessageOut =''                                        
 Declare @ErrorMessage nvarchar(max)                                         
 Select @ErrorMessage=ERROR_MESSAGE()                                        
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_DeleteFileFromUploadFiles]',Getdate(),@ErrorMessage)                                        
End Catch


