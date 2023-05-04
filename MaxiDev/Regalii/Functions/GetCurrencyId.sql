CREATE function [Regalii].[GetCurrencyId] (@Name nvarchar(max))
--Select [Regalii].[GetCurrencyId] ('MX')
returns int
Begin
declare @Id int

 --   if @Name='DO' 
	--	set @Name='DOP'
	--if @Name='US' 
	--	set @Name='USD'
	--if @Name='MX' 
	--	set @Name='MXN'
	--if @Name='AR' 
	--	set @Name='ARS'
	--if @Name='BR' 
	--	set @Name='BRL'
	--if @Name='CL' 
	--	set @Name='COP'
	--if @Name='HN' 
	--	set @Name='HNL'
	--if @Name='IN' 
	--	set @Name='INR'
	--if @Name='JM' 
	--	set @Name='JMD'
	--if @Name='PE' 
	--	set @Name='PEN'
	--if @Name='PH' 
	--	set @Name='PHD'


	Select top 1 @Id=Cu.IdCurrency from Country Co 
	inner join CountryCurrency Cc on Co.IdCountry = Cc.IdCountry
	inner join Currency Cu on Cu.IdCurrency = Cc.IdCurrency
	where Co.CountryCodeISO3166 = @Name
	order by Cu.IdCurrency desc

    --SELECT top 1 @Id=idcurrency from dbo.Currency with (nolock) where CurrencyCode=@Name order by IdCurrency

return @id
End

/*
SELECT [Currency]
      ,[Exchange]
  FROM [MaxiDev].[Regalii].[Currencies]

where currency not in
(
select CurrencyCode from currency
)
*/

--select *,[Regalii].GetCurrencyId(Currency) from [Regalii].[Currencies]

