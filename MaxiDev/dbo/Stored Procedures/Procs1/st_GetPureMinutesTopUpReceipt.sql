create procedure [dbo].[st_GetPureMinutesTopUpReceipt] 
(
    @IdPureMinutesTopUp int
)
as
    
declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
  
declare @ReceiptPureMinutesEnglishMessage varchar(max)      
set @ReceiptPureMinutesEnglishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesEnglishMessage');   

declare @ReceiptPureMinutesSpanishMessage varchar(max)      
set @ReceiptPureMinutesSpanishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesSpanishMessage');   
  
  
Select       
  @CorporationPhone CorporationPhone,      
  @CorporationName CorporationName,     
  @ReceiptPureMinutesEnglishMessage ReceiptPureMinutesEnglishMessage,
  @ReceiptPureMinutesSpanishMessage ReceiptPureMinutesSpanishMessage,  
  ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
  A.AgentAddress,      
  ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ ISNULL(A.AgentZipcode,'') AgentLocation,      
  A.AgentPhone,
  t.IdPureMinutesTopUp,       
  U.UserLogin,      
  t.DateOfTransaction,    
  t.IdPureMinutesTopUp Reference,       
  t.BuyerPhonenumber, 
  t.TopUpAmount Amount,
  t.fee Fee,
  --ISNULL(t.TopUpAmount ,0)+ ISNULL(t.Fee,0) TotalOperation,  
  PureMinutesTopUpTransID,
  isnull(c.CountryName,'') CountryName,
  isnull(ca.CarrierName,'') CarrierName,
  isnull(b.RechargeAmount,'') BillerName,
  t.TopUpNumber
from dbo.PureMinutesTopUpTransaction t
	inner join Agent a on a.IdAgent= t.IdAgent
	inner join Users u on u.IdUser= t.IdUser
    left join 
        CountryPureMinutesTopUp c on t.CountryID=c.IdCountryPureMinutesTopUp
    left join 
        CarrierPureMinutesTopUp ca on t.CarrierID=ca.IdCarrierPureMinutesTopUp
    left join
        BillerPureMinutesTopUp b on t.BillerID=b.IdBillerPureMinutesTopUp
	where t.IdPureMinutesTopUp=@IdPureMinutesTopUp
	

