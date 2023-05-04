CREATE PROCEDURE [dbo].[st_FindCountryCurrencyById]
(
	@IdCountryCurrency  INT
)
AS
BEGIN

	SELECT cc.IdCountryCurrency, cc.IdCountry, cc.IdCurrency,  cc.DateOfLastChange, cc.EnterByIdUser 
	FROM CountryCurrency cc WITH(NOLOCK)
		  WHERE cc.IdCountryCurrency=@IdCountryCurrency;
	
END
