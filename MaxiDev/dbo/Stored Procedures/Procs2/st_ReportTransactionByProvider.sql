CREATE Procedure [dbo].[st_ReportTransactionByProvider]
@DateFrom datetime,               
@DateTo datetime   
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


set @DateFrom=dbo.RemoveTimeFromDatetime(@DateFrom)
set @DateTo=dbo.RemoveTimeFromDatetime(@DateTo+1)              


select 
	P.ProviderName,
	A.AgentCode,
	BPT.IdBillPayment Folio,
	BPT.ReceiptAmount Amount,
	BPT.Fee,
	BPT.BillPaymentProviderFee ProviderFee,
	BPT.AgentCommission, 
	BPT.CorpCommission MaxiCommission,
	BPT.PaymentDate [Date],
	PP.VendorName Biller,
	Isnull(BPT.CustomerLastName,'') +' ' +Isnull(BPT.CustomerMiddleName,'')+ ' '+ Isnull(BPT.CustomerFirstName,'') Customer,
	BPT.PostingMessage [Message],
	BPT.ReturnMessage,
	BPT.ReceiptMessage
from dbo.BillPaymentTransactions BPT with(nolock)
	inner join ProductsByProvider PP with(nolock) on PP.IdProductsByProvider=BPT.IdBiller
	inner join dbo.Providers P with(nolock) on P.IdProvider= PP.IdProvider
	inner join Agent A with(nolock) on A.idAgent = BPT.IdAgent
	where BPT.PaymentDate>=@DateFrom and BPT.PaymentDate<@DateTo and BPT.[Status]=1
	order by BPT.IdBillPayment
