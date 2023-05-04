CREATE procedure [dbo].[st_GetCountryCurrenciesDontSendDollars]

as

declare @IdCountryMexico varchar(50)
	set @IdCountryMexico = CAST( dbo.GetGlobalAttributeByName('IdCountryMexico')  as int)
	
declare @IdCurrencyUSA varchar(50)
	set @IdCurrencyUSA = CAST( dbo.GetGlobalAttributeByName('IdCurrencyUSA')  as int)

select CC.IdCountryCurrency	,
		C.CountryName+ '/'+ Cy.CurrencyName	CountryCurrency	
	from CountryCurrency CC
		inner join Country C on CC.IdCountry =C.IdCountry
		inner join Currency Cy on Cy.IdCurrency=CC.IdCurrency
	where CC.IdCountry <> @IdCountryMexico and CC.IdCurrency<>@IdCurrencyUSA
