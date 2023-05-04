CREATE procedure [TransFerTo].[st_GetTransferToCountry]
(
    @All bit
)
as

select idcountry,countryname,PhoneCountryCode, idcountryTTO,IdGenericStatus from [TransFerTo].Country where IdGenericStatus = case when @All=1 then IdGenericStatus else 1 end  order by countryname