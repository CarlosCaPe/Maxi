
CREATE procedure [dbo].[st_GetCellularRtrPurchaseReceipt] 
@Id int
as
    
declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
  
declare @CellularReceiptEnglishMessage varchar(max)      
set @CellularReceiptEnglishMessage = dbo.GetGlobalAttributeByName('CellularRtrReceiptEnglishMessage');   

declare @CellularReceiptSpanishMessage varchar(max)      
set @CellularReceiptSpanishMessage = dbo.GetGlobalAttributeByName('CellularRtrReceiptSpanishMessage');   
  
  
Select       
  @CorporationPhone CorporationPhone,      
  @CorporationName CorporationName,     
  @CellularReceiptEnglishMessage CellularReceiptEnglishMessage,
  @CellularReceiptSpanishMessage CellularReceiptSpanishMessage,  
  ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
  A.AgentAddress,      
  ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ ISNULL(A.AgentZipcode,'') AgentLocation,      
  A.AgentPhone,
  b.Id,       
  U.UserLogin,      
  b.TransactionDate,  
  b.PhoneNumber,
  b.Amount,
  b.Description,
  b.ResponseCustomerReceipt
from dbo.CellularRtrPurchaseTransactions b
	inner join Agent a on a.IdAgent= b.IdAgent
	inner join Users u on u.IdUser= b.IdUser
	where b.Id=@Id
	
	
