CREATE PROCEDURE [Corp].[st_GetSpread]
AS

	SELECT S.IdSpread ,S.SpreadName ,S.DateOfLastChange ,S.EnterByIdUser , S.IdCountryCurrency, c.Countryname+'/'+cy.Currencyname CountryCurrencyName
	FROM Spread S (NOLOCK) 	
	inner join CountryCurrency CC on CC.IdCountryCurrency=S.IdCountryCurrency
		inner join Country C on C.IdCountry=CC.IdCountry
		inner join Currency Cy on Cy.IdCurrency=CC.IdCurrency	
	ORDER BY SpreadName
