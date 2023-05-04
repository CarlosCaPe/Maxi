CREATE PROCEDURE [MaxiMobile].[st_GetOccupation]
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> SP para obtener el catálogo de ocupaciones </Description>

<ChangeLog>
<log Date="22/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 

	select Name as NameEn, NameEs as Name from DictionaryOccupation

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetOccupation]',GETDATE(),@ErrorMessage)
END CATCH
