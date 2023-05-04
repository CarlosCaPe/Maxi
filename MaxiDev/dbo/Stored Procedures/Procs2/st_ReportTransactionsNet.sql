

CREATE procedure [dbo].[st_ReportTransactionsNet]
@beginDate datetime,
@endDate datetime
as


set @beginDate = dbo.RemoveTimeFromDatetime(@beginDate)
set @endDate = dbo.RemoveTimeFromDatetime(DATEADD(day,1, @endDate) )

--select @beginDate,@endDate


select --T.IdGateway, T.IdPayer, T.IdCountryCurrency,
	C.CountryName, Cy.CurrencyName, G.GatewayName, P.PayerName, T.AmountDls, T.TransactionNumber, T.AmountLC, pt.PaymentName
from 
	(
		select LT.IdGateway, LT.IdPayer, LT.IdCountryCurrency, Sum(LT.amountDls) AmountDls, SUM(LT.transactionNumber) TransactionNumber ,SUM(LT.amountLC) AmountLC, LT.IdPaymentType
		from
			(
					select T.IdGateway, T.IdPayer, T.IdCountryCurrency, SUM(T.AmountInDollars) amountDls, SUM(1) transactionNumber, SUM(T.AmountInMN) amountLC, T.IdPaymentType
					from [Transfer] T with(nolock)
					where T.DateOfTransfer>= @beginDate and T.DateOfTransfer<@endDate	
					group by T.IdGateway, T.IdPayer, T.IdCountryCurrency, T.IdPaymentType
				union all
					select T.IdGateway, T.IdPayer, T.IdCountryCurrency, SUM(T.AmountInDollars) amountDls, SUM(1) transactionNumber, SUM(T.AmountInMN) amountLC, T.IdPaymentType
					from TransferClosed T with(nolock)
					where T.DateOfTransfer>= @beginDate and T.DateOfTransfer<@endDate	
					group by T.IdGateway, T.IdPayer, T.IdCountryCurrency, T.IdPaymentType
				union all
					select T.IdGateway, T.IdPayer, T.IdCountryCurrency,
						SUM( T.AmountInDollars)*-1 cancelledAndRejectedAmountDls,
						SUM(1)*-1 transactionNumber,
						SUM(T.AmountInMN)*-1 cancelledAndRejectedAmountLC, T.IdPaymentType
					from [Transfer] T with(nolock)
					where T.DateStatusChange>= @beginDate and T.DateStatusChange<@endDate and T.IdStatus in (22,31)
					group by T.IdGateway, T.IdPayer, T.IdCountryCurrency, T.IdPaymentType
				union all
					select T.IdGateway, T.IdPayer, T.IdCountryCurrency,
						SUM(T.AmountInDollars)*-1 cancelledAndRejectedAmountDls,
						SUM(1)*-1 transactionNumber,	
						SUM(T.AmountInMN)*-1 cancelledAndRejectedAmountLC, T.IdPaymentType
					from TransferClosed T with(nolock)
					where T.DateStatusChange>= @beginDate and T.DateStatusChange<@endDate	and T.IdStatus in (22,31) 
					group by T.IdGateway, T.IdPayer, T.IdCountryCurrency, T.IdPaymentType
			)LT 
		group by LT.IdGateway, LT.IdPayer, LT.IdCountryCurrency, LT.IdPaymentType
	) T
	inner join Gateway G with(nolock) on G.IdGateway=T.IdGateway
	inner join Payer P with(nolock) on P.IdPayer =T.IdPayer
	inner join CountryCurrency CC with(nolock) on CC.IdCountryCurrency = T.IdCountryCurrency
	inner join Country C with(nolock) on C.IdCountry =CC.IdCountry
	inner join Currency Cy with(nolock) on Cy.IdCurrency=CC.IdCurrency
	inner join PaymentType as pt with(nolock) on T.IdPaymentType = pt.IdPaymentType


