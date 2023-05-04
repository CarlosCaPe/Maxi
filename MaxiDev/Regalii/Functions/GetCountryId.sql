CREATE function [Regalii].[GetCountryId] (@Name nvarchar(max))
--Select [Regalii].[GetCountryId] ('MX')
returns int
Begin
declare @Id int

	Select @Id=Co.IdCountry from Country Co 
	where Co.CountryCodeISO3166 = @Name


 --   SELECT top 1 @Id=C.IdCountry 
	--from Country C with(nolock)
	--	inner join [Regalii].[CountryMap] CM with(nolock) on CM.CountryCode=C.CountryCode
	--where C.CountryCodeISO3166=@Name order by C.IdCountry

return @id
End

