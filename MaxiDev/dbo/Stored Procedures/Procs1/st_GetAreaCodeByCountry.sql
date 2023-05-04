/********************************************************************
<Author>Mhinojo</Author>
<app>Agent</app>
<Description>Obtiene el area code correspondiente a un pais</Description>
<ChangeLog>
<log Date="29/08/2017" Author="mhinojo">Creación del procedimiento almacenado</log>
</ChangeLog>

*********************************************************************/
CREATE PROCEDURE [dbo].[st_GetAreaCodeByCountry]
(
    @IdCountry int
)
AS
SELECT        
IdCountryAreaCode, IdCountry, AreaCode
FROM            
dbo.CountryAreaCode
WHERE        
(IdCountry = @IdCountry)