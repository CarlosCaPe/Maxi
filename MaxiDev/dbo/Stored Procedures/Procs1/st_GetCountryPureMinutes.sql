create procedure st_GetCountryPureMinutes
(
    @ShowDisable bit
)
as
select IdCountryPureMinutes,CountryName,IdGenericStatus from dbo.CountryPureMinutes where idgenericstatus = case when @ShowDisable=1 then idgenericstatus else 1 end