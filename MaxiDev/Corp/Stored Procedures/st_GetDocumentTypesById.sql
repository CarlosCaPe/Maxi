CREATE PROCEDURE [Corp].[st_GetDocumentTypesById]
(
	@IdType int
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

		, isnull(ci.CountryRequired, 0) as CountryRequired
		, isnull(StateRequired, 0) as StateRequired 
		, ISNULL(DateOfBirthRequired,0)  DateOfBirthRequired
	from DocumentTypes AS dt WITH(NOLOCK)
		left join CustomerIdentificationType AS ci WITH(NOLOCK) on ci.IdCustomerIdentificationType = dt.IdDocumentType
	where dt.IdType = @IdType

  End Try
Begin Catch
	 Declare @ErrorMessage nvarchar(max);
	 Select @ErrorMessage=ERROR_MESSAGE();
	 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('[Corp].[st_GetDocumentTypesById]',Getdate(),@ErrorMessage);
End Catch 
   
