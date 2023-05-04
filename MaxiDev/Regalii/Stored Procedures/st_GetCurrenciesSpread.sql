CREATE PROCEDURE [Regalii].[st_GetCurrenciesSpread]
as

select isnull(s.IdCurrenciesSpread,0) IdCurrenciesSpread, c.IdCurrency,CurrencyName, c.Exchange ExRate, isnull(s.Spread,0) Spread
from regalii.Currencies c
join Currency cn on c.IdCurrency=cn.IdCurrency
left join Regalii.CurrenciesSpread s on c.IdCurrency=s.IdCurrency and s.idagent is null
order by CurrencyName
