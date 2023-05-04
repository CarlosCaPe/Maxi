CREATE PROCEDURE [dbo].[st_GetChecksReceipt] 
@Id int
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
  ISNULL(A.AgentName,'') AgentName,      
  A.AgentAddress,      
  ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0')  AgentLocation,      
  A.AgentPhone,
  A.AgentCity,
  A.AgentState,
  A.AgentZipcode,
  A.AgentCode,
  A.AgentFax,
  b.IdCheck,       
  U.UserLogin,      
  b.DateOfMovement  PaymentDate,  
  ' ' as VendorName,
  b.CheckNumber, 
  b.IdCheck  MerchId,
  b.RoutingNumber,
  b.Name + b.FirstLastName + b.SecondLastName  SenderNameRequired,
  LTRIM(RTRIM(ISNULL(b.Name,'')+' '+ ISNULL(b.FirstLastName,'')+' '+ISNULL(b.SecondLastName,''))) CustomerFullName,
  b.Name CustomerNameRequired,
  LTRIM(RTRIM(ISNULL(b.Name,'')+' '+ ISNULL(b.Name,'')+' ' + ISNULL(b.Name,''))) BehalfFullName,
  b.Account AccountNumber,
  ' ' as AltLookupLabel,
  b.Amount,
  b.Fee,
  ISNULL(b.Amount,0)- ISNULL(b.Fee,0) TotalOperation,
  ' ' as ReceiptMessage
  
from dbo.Checks b with(nolock)
	inner join Agent a with(nolock) on a.IdAgent= b.IdAgent
	inner join Users u with(nolock) on u.IdUser= b.EnteredByIdUser
	where b.IdCheck=@Id;