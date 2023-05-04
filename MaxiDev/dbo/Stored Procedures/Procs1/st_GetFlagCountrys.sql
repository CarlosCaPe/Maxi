
create procedure [st_GetFlagCountrys]
 
as
/********************************************************************
<Author>amoreno</Author>
<app>MaxiAgente</app>
<Description>Tarifas</Description>

<ChangeLog>

<log Date="19/04/2018" Author="amoreno">se obtienen las banderas de los paises</log>
</ChangeLog>
*********************************************************************/
 select
 IdCountry
 , CountryName  
  , CountryFlag   
 from 
  Country with (nolock) 
 where 
  CountryFlag is not null 
  and CountryFlag<>''



