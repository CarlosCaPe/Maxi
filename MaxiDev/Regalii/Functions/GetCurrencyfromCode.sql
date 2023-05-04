CREATE function [Regalii].[GetCurrencyfromCode] (@Code nvarchar(max))
--Select [Regalii].[GetCurrency] ('GL')
returns VARCHAR(MAX)
Begin
declare @CURRENCY VARCHAR(3)



	Select top 1 @CURRENCY = IdCurrency from Currency Cu
	where Cu.CurrencyCode = @Code
	order by Cu.IdCurrency desc


return @CURRENCY
End


