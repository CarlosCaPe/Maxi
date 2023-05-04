
CREATE procedure [dbo].[st_GetOwnerInfoForAgentApplication]
(
    @IdOwner int
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

select [Address],
       BornCountry,
       BornDate,
       Cel,
       City,
       Email,
       IdExpirationDate,
       IdNumber,
       IdStatus,
       IdType,
       LastName,
       Name,
       Phone,
       SecondLastName,
       SSN,
       [State],
       ZipCode,
       o.IdCounty,
       isnull(CountyName,'') CountyName,
       IdStateEmission,
       IdCountryEmission,
       CountryName,
       StateName,
       o.TypeTaxId
from [owner] o with(nolock)
    left join county c with(nolock) on o.IdCounty=c.IdCounty
    left join Country country on IdCountryEmission = country.IdCountry
    left join State sta on IdStateEmission = sta.IdState
where idowner=@IdOwner

select r.IdCountyClass  IdOwnerCountyClass, c.CountyClassName OwnerCountyClassName from RelationCountyCountyClass r with(nolock)
join CountyClass c with(nolock) on r.IdCountyClass = c.IdCountyClass
where idcounty in
(
select idcounty from [owner] with(nolock) where idowner=@IdOwner

)
