CREATE procedure [dbo].[st_GetDocumentTypeById]
(
	@IdDocumentType int
)
as

Begin Try

	select 
		dt.IdDocumentType
		,dt.Name
		,dt.IdType
		,dt.RelativePath
		,dt.GenerateBySystem
		,dt.IdDocumentTypeDad
	from DocumentTypes AS dt WITH(NOLOCK)	
	where dt.IdDocumentType = @IdDocumentType

  End Try
Begin Catch
	 Declare @ErrorMessage nvarchar(max);
	 Select @ErrorMessage=ERROR_MESSAGE();
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_GetDocumentTypeById',Getdate(),@ErrorMessage);
End Catch 
   
