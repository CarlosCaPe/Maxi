
CREATE procedure [dbo].[st_TransferTToReceipt] 
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
  ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
  A.AgentPhone,
  t.IdTransferTTo,
  t.IdTransactionTTo,
  ReturnTimeStamp DateOfTransaction,
  Destination_Msisdn Phonenumber,
  t.RetailPrice Amount,
  --ISNULL(t.TopUpAmount ,0)+ ISNULL(t.Fee,0) TotalOperation,    
  OperatorReference Reference,
  Country CountryName,
  Operator CarrierName,
  LocalInfoAmount LocalAmount,
  LocalInfoCurrency LocalCurrency,
  pinBased,
  pinValidity,
  pinCode,
  pinIvr,
  pinSerial,
  pinValue,
  pinOption1,
  pinOption2,
  pinOption3,
  t.[Key],
  t.LocalInfoValue
  , A.AgentFax
	, A.AgentPhone
	, A.AgentName AS AgentNameTicket
	, A.AgentCode
	, A.AgentZipcode
	, A.AgentState
	, A.AgentCity
	, A.AgentAddress
from TransferTo.[TransferTTo] t with(nolock)
	inner join Agent a  with(nolock) on a.IdAgent= t.IdAgent   
where t.IdTransferTTo=@IdTransferTTo

/****** Object:  StoredProcedure [dbo].[st_TransferTToCancelReceipt]    Script Date: 06/02/2015 05:55:42 p. m. ******/
SET ANSI_NULLS ON
