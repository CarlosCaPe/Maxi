CREATE function [Regalii].[GetCurrency] (@Name nvarchar(max))
--Select [Regalii].[GetCurrency] ('GL')
returns VARCHAR(MAX)
Begin
declare @CURRENCY VARCHAR(3)



	Select top 1 @CURRENCY=Cu.CurrencyCode from Country Co 
	inner join CountryCurrency Cc on Co.IdCountry = Cc.IdCountry
	inner join Currency Cu on Cu.IdCurrency = Cc.IdCurrency
	where Co.CountryCodeISO3166 = @Name
	order by Cu.IdCurrency desc


return @CURRENCY
End


