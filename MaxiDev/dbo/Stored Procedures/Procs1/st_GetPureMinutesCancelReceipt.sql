CREATE procedure [dbo].[st_GetPureMinutesCancelReceipt] 
(
    @IdPureMinutes int
)
as
    
declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
  
declare @ReceiptPureMinutesCancelEnglishMessage varchar(max)      
set @ReceiptPureMinutesCancelEnglishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesCancelEnglishMessage');   

declare @ReceiptPureMinutesCancelSpanishMessage varchar(max)      
set @ReceiptPureMinutesCancelSpanishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesCancelSpanishMessage');   
  
  
Select       
  @CorporationPhone CorporationPhone,      
  @CorporationName CorporationName,     
  @ReceiptPureMinutesCancelEnglishMessage ReceiptPureMinutesCancelEnglishMessage,
  @ReceiptPureMinutesCancelSpanishMessage ReceiptPureMinutesCancelSpanishMessage,  
  ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
  A.AgentAddress,      
  ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
  A.AgentPhone,
  t.IdPureMinutes,       
  U.UserLogin,      
  t.CancelDateOfTransaction as PaymentDate,    
  t.IdPureMinutes Reference,  
  LTRIM(RTRIM(ISNULL(t.SenderName,'')+' '+ ISNULL(t.SenderFirstLastName,'')+' '+ISNULL(t.SenderSecondLastName,''))) CustomerFullName,  
  t.ReceiveAccountNumber AccountNumber, 
  t.ReceiveAmount Amount,
  t.fee Fee,
  --ISNULL(t.ReceiveAmount,0)+ ISNULL(t.Fee,0) TotalOperation,
  AgentReferenceNumber,
  isnull(t.Balance,0) Balance,
  PureMinutesTransID,
  PromoCode,
  ConfirmationCode,
  t.CreditForPromoCode,
  t.Bonification  
from dbo.PureMinutesTransaction t
	inner join Agent a on a.IdAgent= t.IdAgent
	left join Users u on u.IdUser= t.CancelIdUser	
	where t.IdPureMinutes=@IdPureMinutes
