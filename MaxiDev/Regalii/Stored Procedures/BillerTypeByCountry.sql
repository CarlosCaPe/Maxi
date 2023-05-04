CREATE procedure [Regalii].[BillerTypeByCountry]-- 16 , 2
(
    @IdCountry int,
    @IdLenguage int = null
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2022" Author="adominguez">Sp que obtiene los billers disponibles para un pais</log>
</ChangeLog>
*********************************************************************/

SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

declare @BillerTypeCell varchar(500) = (select Value from GlobalAttributes with(nolock) where Name='RegaliiBillerTypeCell')

select 
    BillerType, 
    case when BillerTypeName='' then BillerType else BillerTypeName end BillerTypeName  
from
(
    select distinct BillerType,[dbo].[GetMessageFromMultiLenguajeResorces](isnull(@IdLenguage,1),'Regalii'+BillerType) BillerTypeName 
	from regalii.[Billers] with(nolock)
	where idcountry=@IdCountry 
	and IdOtherProduct = 14 
	and IdGenericStatus = 1
	and BillerType != @BillerTypeCell
)t
order by 
    BillerType