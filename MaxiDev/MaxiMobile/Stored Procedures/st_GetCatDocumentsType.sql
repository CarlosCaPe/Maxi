CREATE PROCEDURE [MaxiMobile].[st_GetCatDocumentsType]
/********************************************************************
<Author> Juan --Hernandez </Author>
<app> AppMaxiFax </app>
<Description> SP para obtener el catálogo de tipo de documentos para las transaciones </Description>
*********************************************************************/
as
Begin Try 

	select IdDocumentType, Name from DocumentTypes with (nolock) where IdType = 4

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetCatDocumentsType]',GETDATE(),@ErrorMessage)
END CATCH
