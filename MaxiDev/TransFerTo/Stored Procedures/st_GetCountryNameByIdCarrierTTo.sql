CREATE procedure [TransFerTo].[st_GetCountryNameByIdCarrierTTo]
(
    @IdCarrierTTo int
)
as
SELECT 
      c.[IdCountry] ,     
      cy.CountryName
FROM [TransFerTo].[Carrier] c WITH(NOLOCK)
join 
    [TransFerTo].[Country] cy WITH(NOLOCK) on c.idcountry=cy.idcountry
where idcarriertto=@IdCarrierTTo 