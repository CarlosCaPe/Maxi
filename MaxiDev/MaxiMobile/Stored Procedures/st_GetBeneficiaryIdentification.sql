CREATE PROCEDURE [MaxiMobile].[st_GetBeneficiaryIdentification]
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> SP para obtener el catálogo de identificaciones para beneficiario </Description>

<ChangeLog>
<log Date="22/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 

	select IdBeneficiaryIdentificationType as Id, Name as NameEn, NameEs as Name from BeneficiaryIdentificationType

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetBeneficiaryIdentification]',GETDATE(),@ErrorMessage)
END CATCH
