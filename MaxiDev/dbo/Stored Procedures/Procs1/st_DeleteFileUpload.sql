
Create procedure [dbo].[st_DeleteFileUpload](@IdUploadFile int)
as
update UploadFiles set IsPhysicalDeleted = 1 where IdUploadFile = @IdUploadFile

