CREATE procedure [Corp].[st_GetCountryCurrenciesDontSendDollars]

as

declare @IdCountryMexico varchar(50)
	set @IdCountryMexico = CAST( dbo.GetGlobalAttributeByName('IdCountryMexico')  as int)
	
declare @IdCurrencyUSA varchar(50)
	set @IdCurrencyUSA = CAST( dbo.GetGlobalAttributeByName('IdCurrencyUSA')  as int)

select CC.IdCountryCurrency	,
		C.CountryName+ '/'+ Cy.CurrencyName	CountryCurrency	
	from CountryCurrency CC with(nolock)
		inner join Country C with(nolock) on CC.IdCountry =C.IdCountry
		inner join Currency Cy with(nolock) on Cy.IdCurrency=CC.IdCurrency
	where CC.IdCountry <> @IdCountryMexico and CC.IdCurrency<>@IdCurrencyUSA
