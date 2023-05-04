CREATE procedure [Regalii].[GetCountry]
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2022" Author="adominguez">Sp que obtiene los paises disponibles para Pago de Bill </log>
</ChangeLog>
*********************************************************************/
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;


select 
    IdCountry,
    Countryname 
from 
    country 
where 
    idcountry in
    (
        select distinct idcountry 
		from regalii.[Billers] with(nolock)
		where idcountry is not null 
		and IdOtherProduct = 14
		and IdGenericStatus = 1
    )
order by 
    Countryname