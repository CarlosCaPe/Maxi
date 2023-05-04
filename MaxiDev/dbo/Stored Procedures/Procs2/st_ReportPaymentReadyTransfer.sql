

CREATE Procedure [dbo].[st_ReportPaymentReadyTransfer]
as
Set nocount on 

Select  F.GatewayName
	,P.PayerName
	,t.DateOfTransfer
	,t.DateStatusChange
	,t.claimcode
	,t.AmountInDollars
	,t.AmountInMN
	,s.StatusName
	,D.CurrencyName
	,E.CountryName
from Transfer T  WITH(NOLOCK) 
	Join Status s WITH(NOLOCK) on (T.IdStatus=S.IdStatus)
	Join Payer P WITH(NOLOCK) on (T.IdPayer=P.IdPayer)
	Join CountryCurrency C WITH(NOLOCK) on (T.IdCountryCurrency=C.IdCountryCurrency)
	Join Currency D WITH(NOLOCK) on (D.Idcurrency=C.IdCurrency)
	Join Country E WITH(NOLOCK) on (E.IdCountry=C.IdCountry)
	Join Gateway F WITH(NOLOCK) on (F.IdGateway=T.IdGateway)
Where 
	t.IdStatus in ('23')
order by F.GatewayName, P.PayerName,t.DateOfTransfer;