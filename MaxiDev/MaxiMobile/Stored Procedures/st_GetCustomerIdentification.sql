CREATE PROCEDURE [MaxiMobile].[st_GetCustomerIdentification]
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> SP para obtener el catálogo de identificaciones para customer </Description>

<ChangeLog>
<log Date="22/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 

	select IdCustomerIdentificationType as Id, Name as NameEn, NameEs as Name, RequireSSN as NssRequired, StateRequired as StateRequired, CountryRequired as CountryRequired
	from CustomerIdentificationType

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetCustomerIdentification]',GETDATE(),@ErrorMessage)
END CATCH
