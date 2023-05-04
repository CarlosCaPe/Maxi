CREATE procedure [dbo].[st_GetBillPaymentReceipt] 
@Id int
as
    
declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
  
declare @ReceiptBillPaymentEnglishMessage varchar(max)      
set @ReceiptBillPaymentEnglishMessage = dbo.GetGlobalAttributeByName('ReceiptBillPaymentEnglishMessage');   

declare @ReceiptBillPaymentSpanishMessage varchar(max)      
set @ReceiptBillPaymentSpanishMessage = dbo.GetGlobalAttributeByName('ReceiptBillPaymentSpanishMessage');   
  
  
Select       
  @CorporationPhone CorporationPhone,      
  @CorporationName CorporationName,     
  @ReceiptBillPaymentEnglishMessage ReceiptBillPaymentEnglishMessage,
  @ReceiptBillPaymentSpanishMessage ReceiptBillPaymentSpanishMessage,  
  ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
  A.AgentAddress,      
  ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0')  AgentLocation,      
  A.AgentPhone,
  b.IdBillPayment,       
  U.UserLogin,      
  b.PaymentDate,  
  P.VendorName,
  b.ReferenceNumber, 
  b.MerchId,
  b.TrackingNumber,
  bp.SenderNameRequired SenderNameRequired,
  LTRIM(RTRIM(ISNULL(b.CustomerFirstName,'')+' '+ ISNULL(b.CustomerLastName,'')+' '+ISNULL(b.CustomerMiddleName,''))) CustomerFullName,
  bp.CustomerNameRequired CustomerNameRequired,
  LTRIM(RTRIM(ISNULL(b.BehalfFirstName,'')+' '+ ISNULL(b.BehalfLastName,'')+' ' + ISNULL(b.BehalfMiddleName,''))) BehalfFullName,
  case
	when bp.MaskAccountOnReceipt =0 then LTRIM(RTRIM(ISNULL(b.AccountNumber,''))) 
	else REPLICATE('*',LEN(ISNULL(b.AccountNumber,''))-4) +RIGHt(ISNULL(b.AccountNumber,''),4)  
  end AccountNumber,
  LTRIM(RTRIM(ISNULL(bp.AltLookupLabel,''))) AltLookupLabel,
  b.AltAccountNumber,
  b.ReceiptAmount,
  b.Fee,
  ISNULL(b.ReceiptAmount,0)+ ISNULL(b.Fee,0) TotalOperation,
  b.ReceiptMessage
  
from dbo.BillPaymentTransactions b
	inner join Agent a on a.IdAgent= b.IdAgent
	inner join Users u on u.IdUser= b.IdUser
	inner join dbo.SoftgateBillPaymentTransactions bp on b.IdBillPayment= bp.IdBillPayment
	inner join dbo.ProductsByProvider P on P.IdProductsByProvider=b.IdBiller
	where b.IdBillPayment=@Id
	


