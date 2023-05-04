CREATE PROCEDURE [MaxiMobile].[st_GetCountry]
(
	@ShortList bit
)
/********************************************************************
<Author> RMacias </Author>
<app> WebApi </app>
<Description> SP para obtener el catálogo de paises </Description>

<ChangeLog>
<log Date="22/11/2017" Author="RMacias">Creation</log>
</ChangeLog>

*********************************************************************/
as
Begin Try 

	if @ShortList = 1
	begin
		select top 10 IdCountry as Id, CountryName as NameEn, CountryName as Name from Country
		union
		select 99999, 'SHOW MORE', 'MOSTRAR MÁS'
	end
	else
		select IdCountry as Id, CountryName as NameEn, CountryName as Name from Country

END TRY
BEGIN CATCH
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage = ERROR_MESSAGE()           
	INSERT INTO ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)
	VALUES('[MaxiMobile].[st_GetCountry]',GETDATE(),@ErrorMessage)
END CATCH
