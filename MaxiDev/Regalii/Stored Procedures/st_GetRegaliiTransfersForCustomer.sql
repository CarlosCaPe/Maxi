CREATE procedure [Regalii].[st_GetRegaliiTransfersForCustomer]
@IdCustomer int
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
<log Date="28/07/2022" Author="adominguez">Se agrega join con billers y filtro de status activo</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

BEGIN


select distinct T.IdCountry, T.BillerType, T.Account_Number, T.Name_On_Account , T.IdBiller, T.Name BillerName
from Regalii.TransferR T with(nolock) 
inner join Regalii.Billers b on b.IdBiller = T.IdBiller and b.IdGenericStatus = 1
where T.IdCustomer= @IdCustomer
and b.IdOtherProduct = 14

END