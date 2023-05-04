create procedure [TransFerTo].st_GetCarriers
(
    @All bit
)
as
select IdCarrier,IdCountry,CarrierName,IdCarrierTTo,IdGenericStatus from [TransFerTo].[Carrier] where IdGenericStatus = case when @All=1 then IdGenericStatus else 1 end order by carriername