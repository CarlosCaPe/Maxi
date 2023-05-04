
 
CREATE Procedure [dbo].[st_ReportPendingTransferAccepted]  
as  
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Select  F.GatewayName,  
P.PayerName,t.DateOfTransfer, t.DateStatusChange, t.claimcode, t.AmountInDollars, t.AmountInMN,s.StatusName,D.CurrencyName,E.CountryName  
from        [Transfer] T  with(nolock)
Join [Status] s with(nolock) on (T.IdStatus=S.IdStatus)  
Join Payer P with(nolock) on (T.IdPayer=P.IdPayer)  
Join CountryCurrency C with(nolock) on (T.IdCountryCurrency=C.IdCountryCurrency)  
Join Currency D with(nolock) on (D.Idcurrency=C.IdCurrency)  
Join Country E with(nolock) on (E.IdCountry=C.IdCountry)  
Join Gateway F with(nolock) on (F.IdGateway=T.IdGateway)  
Where   
t.IdStatus in (40)  
and T.IdGateway<>12  
Union  
Select  F.GatewayName,  
P.PayerName,t.DateOfTransfer, t.DateStatusChange, t.claimcode, t.AmountInDollars, t.AmountInMN,s.StatusName,D.CurrencyName,E.CountryName  
from        [Transfer] T  with(nolock) 
Join [Status] s with(nolock) on (T.IdStatus=S.IdStatus)  
Join Payer P with(nolock) on (T.IdPayer=P.IdPayer)  
Join CountryCurrency C with(nolock) on (T.IdCountryCurrency=C.IdCountryCurrency)  
Join Currency D with(nolock) on (D.Idcurrency=C.IdCurrency)  
Join Country E with(nolock) on (E.IdCountry=C.IdCountry)  
Join Gateway F with(nolock) on (F.IdGateway=T.IdGateway)  
Where   
t.IdStatus in (40)  
and T.IdGateway=12  
order by F.GatewayName, P.PayerName,t.DateOfTransfer  
 