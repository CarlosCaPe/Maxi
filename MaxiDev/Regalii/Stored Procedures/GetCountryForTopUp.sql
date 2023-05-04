CREATE procedure [Regalii].[GetCountryForTopUp]
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2022" Author="adominguez">Sp que obtiene los paises disponibles para Topups </log>
</ChangeLog>
*********************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;



--declare @BillerTypeCell varchar(500) = (select Value from GlobalAttributes with(nolock) where Name='RegaliiBillerTypeCell')

select 
    C.IdCountry,
    C.Countryname,
	CM.PhoneCode,
	CM.PhoneLenght
from country C
	inner join [Regalii].[CountryMap] CM with(nolock) on CM.CountryCode=C.CountryCode
where C.idcountry in (select distinct idcountry from regalii.[Billers] with(nolock) where idcountry is not null and IdOtherProduct = 17)
	and ISNUMERIC(CM.PhoneLenght)=1
order by C.Countryname
