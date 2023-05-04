 
CREATE Procedure [dbo].[st_ReportPendingTransferSave]  
as  

Set nocount on   
insert into ReportPendingTransfer
Select  F.GatewayName,  
	P.PayerName,t.DateOfTransfer, t.DateStatusChange, t.claimcode, t.AmountInDollars, t.AmountInMN,s.StatusName,D.CurrencyName,E.CountryName, GETDATE()  
from        Transfer T WITH(NOLOCK)  
	Join Status s WITH(NOLOCK) on (T.IdStatus=S.IdStatus)  
	Join Payer P WITH(NOLOCK) on (T.IdPayer=P.IdPayer)  
	Join CountryCurrency C WITH(NOLOCK) on (T.IdCountryCurrency=C.IdCountryCurrency)  
	Join Currency D WITH(NOLOCK) on (D.Idcurrency=C.IdCurrency)  
	Join Country E WITH(NOLOCK) on (E.IdCountry=C.IdCountry)  
	Join Gateway F WITH(NOLOCK) on (F.IdGateway=T.IdGateway)  
Where   
		t.IdStatus Not in ('21','22','23','25','26','27','28','29','30','31','35','40')  
	and T.IdGateway<>12  
Union  
Select  F.GatewayName,  
	P.PayerName,t.DateOfTransfer, t.DateStatusChange, t.claimcode, t.AmountInDollars, t.AmountInMN,s.StatusName,D.CurrencyName,E.CountryName, GETDATE()  
from        Transfer T WITH(NOLOCK)  
	Join Status s WITH(NOLOCK) on (T.IdStatus=S.IdStatus)  
	Join Payer P WITH(NOLOCK) on (T.IdPayer=P.IdPayer)  
	Join CountryCurrency C WITH(NOLOCK) on (T.IdCountryCurrency=C.IdCountryCurrency)  
	Join Currency D WITH(NOLOCK) on (D.Idcurrency=C.IdCurrency)  
	Join Country E WITH(NOLOCK) on (E.IdCountry=C.IdCountry)  
	Join Gateway F WITH(NOLOCK) on (F.IdGateway=T.IdGateway)  
Where   
	t.IdStatus not in ('30','31','22')  
	and T.IdGateway=12  
order by F.GatewayName, P.PayerName,t.DateOfTransfer  
 