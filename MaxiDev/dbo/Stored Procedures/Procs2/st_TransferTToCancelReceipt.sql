

CREATE procedure [dbo].[st_TransferTToCancelReceipt] 
(
    @IdTransferTTo int
)
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
  t.IdTransferTTo,
  t.IdTransactionTTo,
  ReturnTimeStamp DateOfTransaction,
  CancellationTimeStamp DateOfCancelTransaction,
  Destination_Msisdn Phonenumber,
  t.RetailPrice Amount,
  --ISNULL(t.TopUpAmount ,0)+ ISNULL(t.Fee,0) TotalOperation,    
  OperatorReference Reference,
  Country CountryName,
  Operator CarrierName
  , A.AgentFax
	, A.AgentPhone
	, A.AgentName
	, A.AgentCode
	, A.AgentZipcode
	, A.AgentState
	, A.AgentCity
	, A.AgentAddress
from TransferTo.[TransferTTo] t with(nolock)
	inner join Agent a with(nolock) on a.IdAgent= t.IdAgent   
where t.IdTransferTTo=@IdTransferTTo
/****** Object:  StoredProcedure [dbo].[st_GetPureMinutesTransactionInfo]    Script Date: 06/02/2015 05:55:08 p. m. ******/
SET ANSI_NULLS ON
