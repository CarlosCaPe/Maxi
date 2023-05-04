/********************************************************************
<Author>UNKNOWN</Author>
<app>Maxi Host Manager Service</app>
<Description>Return a receipt for lunex </Description>

<ChangeLog>
<log Date="08/01/2016" Author="UNKNOWN"> Creación </log>
<log Date="08/08/2017" Author="Mhinojo"> Alter </log>
</ChangeLog>

*********************************************************************/
CREATE procedure [Lunex].[LunexOtherProductsReceipt]
(
    @IdProductTransfer bigint
)
as

declare @IdOtherProduct int

select @IdOtherProduct = IdOtherProduct from operation.producttransfer where IdProductTransfer=@IdProductTransfer

declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
  
declare @ReceiptPureMinutesEnglishMessage varchar(max)      
set @ReceiptPureMinutesEnglishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesEnglishMessage');   

declare @ReceiptPureMinutesSpanishMessage varchar(max)      
set @ReceiptPureMinutesSpanishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesSpanishMessage'); 

if @IdOtherProduct in (11,12,13,16)
begin
select 
    pt.IdProductTransfer,pt.IdOtherProduct,op.Description OtherProduct,pt.IdAgent,TotalAmountToCorporate,TransactionProviderDate,TransactionProviderID,pt.EnterByIdUser,isnull(u1.UserLogin,'') EnterByIdUserName,TransactionProviderCancelDate,pt.EnterByIdUserCancel,isnull(u2.UserLogin,'') EnterByIdUserCancelName,
    sku,skutype,skuname,dbo.[fnFormatPhoneNumber](phone) phone,dbo.[fnFormatPhoneNumber](topupphone) topupphone,D2Discount,D1Discount,R1Discount,R2Discount,pt.amount,
     @CorporationPhone CorporationPhone,      
      @CorporationName CorporationName,     
      @ReceiptPureMinutesEnglishMessage ReceiptEnglishMessage,
      @ReceiptPureMinutesSpanishMessage ReceiptSpanishMessage,  
      ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
      A.AgentAddress,      
      ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	    REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
      A.AgentPhone
       , A.AgentFax	
	    , A.AgentName AS AgentNameTicket
	    , A.AgentCode
	    , A.AgentZipcode
	    , A.AgentState
	    , A.AgentCity
        , case when pt.idotherproduct=13 then ln.ExpirationDate else null end ExpirationDate
		, ISNULL(ln.AccessNumber,'') AS AccessNumber
from 
    operation.producttransfer pt
join
    otherproducts op on op.idotherproducts=pt.idotherproduct and op.idotherproducts in (11,12,13,16)
left join
    users u1 on u1.iduser=pt.enterbyiduser
left join
    users u2 on u2.iduser=pt.EnterByIdUserCancel
join
    lunex.transferln ln on ln.IdProductTransfer=pt.IdProductTransfer
join
    agent a on a.idagent=pt.idagent
where 
    pt.IdProductTransfer=@IdProductTransfer
end