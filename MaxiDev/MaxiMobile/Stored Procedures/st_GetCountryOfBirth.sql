CREATE PROCEDURE [MaxiMobile].[st_GetCountryOfBirth]
(
	@ShortList bit
)
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

	if @ShortList = 1
	begin
		select top 10 IdCountryBirth as Id, Country as NameEn, CountryEs as Name from CountryBirth
		union
		select 99999, 'SHOW MORE', 'MOSTRAR MÁS'
	end
	else
		select IdCountryBirth as Id, Country as NameEn, CountryEs as Name from CountryBirth

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetCountryOfBirth]',GETDATE(),@ErrorMessage)
END CATCH
