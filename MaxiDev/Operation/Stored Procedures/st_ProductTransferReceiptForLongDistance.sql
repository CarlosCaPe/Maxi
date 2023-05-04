CREATE procedure [Operation].[st_ProductTransferReceiptForLongDistance] 
(
    @IdProductTransfer bigint
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

declare @IdOtherProduct int;

declare @CorporationPhone varchar(50)      
set @CorporationPhone = dbo.GetGlobalAttributeByName('CorporationPhone');      
      
declare @CorporationName varchar(50)      
set @CorporationName = dbo.GetGlobalAttributeByName('CorporationName');   
  
declare @ReceiptPureMinutesEnglishMessage varchar(max)      
set @ReceiptPureMinutesEnglishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesEnglishMessage');   

declare @ReceiptPureMinutesSpanishMessage varchar(max)      
set @ReceiptPureMinutesSpanishMessage = dbo.GetGlobalAttributeByName('ReceiptPureMinutesSpanishMessage');   


select @IdOtherProduct=IdOtherProduct from operation.ProductTransfer with(nolock) where IdProductTransfer=@IdProductTransfer

if @IdOtherProduct=10
begin

    Select       
        @CorporationPhone CorporationPhone,      
        @CorporationName CorporationName,     
        @ReceiptPureMinutesEnglishMessage ReceiptEnglishMessage,
        @ReceiptPureMinutesSpanishMessage ReceiptSpanishMessage,  
        ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
        A.AgentAddress,      
        ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	    REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
        A.AgentPhone,
        t.IdProductTransfer,               
        --t.TransactionProviderDate,    
        t.DateOfCreation TransactionProviderDate,
        t.IdProductTransfer Reference,     
        piv.SenderName CustomerFullName,  
        dbo.[fnFormatPhoneNumber](piv.Phone) AccountNumber, 
        t.Amount Amount,
        null Fee,        
        t.TransactionProviderID AgentReferenceNumber,
        null Balance,
        t.TransactionProviderID,
        null PromoCode,
        null ConfirmationCode,
        null CreditForPromoCode,
        null Bonification,
        piv.AccessNumber
        , A.AgentFax	
	    , A.AgentName AS AgentNameTicket
	    , A.AgentCode
	    , A.AgentZipcode
	    , A.AgentState
	    , A.AgentCity
        ,t.EnterByIdUser
        ,u.Userlogin username,
        t.AgentCommission,
        t.CorpCommission,
        piv.SenderAddress,
        piv.SenderName
        ,t.EnterByIdUserCancel
        ,t.TransactionProviderCancelDate DateOfCancelTransaction
        ,isnull(u2.Userlogin,'') UserNameCancel       
    from Operation.ProductTransfer t with(nolock)
	inner join Agent a with(nolock) on a.IdAgent= t.IdAgent
	inner join Users u with(nolock) on u.IdUser= t.EnterByIdUser
     left join users u2 with(nolock) on t.EnterByIdUserCancel=u2.iduser     
    inner join lunex.TransferLN piv with(nolock) on piv.IdProductTransfer=t.IdProductTransfer
	where t.IdProductTransfer=@IdProductTransfer
end


if @IdOtherProduct=5
begin
    Select       
        @CorporationPhone CorporationPhone,      
        @CorporationName CorporationName,     
        @ReceiptPureMinutesEnglishMessage ReceiptEnglishMessage,
        @ReceiptPureMinutesSpanishMessage ReceiptSpanishMessage,  
        ISNULL(A.AgentCode,'')+' '+ ISNULL(A.AgentName,'') AgentName,      
        A.AgentAddress,      
        ISNULL(A.AgentCity,'')+ ' '+ ISNULL(A.AgentState,'') + ' '+ 
	    REPLACE(STR(isnull(A.AgentZipcode,0), 5), SPACE(1), '0') AS  AgentLocation,      
        A.AgentPhone,
        t.IdProductTransfer,               
        --t.TransactionProviderDate,    
        t.DateOfCreation TransactionProviderDate,
        t.IdProductTransfer Reference,     
        LTRIM(RTRIM(ISNULL(piv.SenderName,'')+' '+ ISNULL(piv.SenderFirstLastName,'')+' '+ISNULL(piv.SenderSecondLastName,''))) CustomerFullName,  
        piv.ReceiveAccountNumber AccountNumber, 
        t.Amount Amount,
        piv.fee Fee,        
        piv.AgentReferenceNumber,
        piv. Balance,
        t.TransactionProviderID,
        piv.PromoCode,
        piv.ConfirmationCode,
        piv.CreditForPromoCode,
        piv.Bonification,
        isnull(piv.AccessNumber,'') AccessNumber
        , A.AgentFax	
	    , A.AgentName AS AgentNameTicket
	    , A.AgentCode
	    , A.AgentZipcode
	    , A.AgentState
	    , A.AgentCity
        ,t.EnterByIdUser
        ,u.Userlogin username,
        t.AgentCommission,
        t.CorpCommission,
        piv.SenderAddress,
        piv.SenderName
        ,t.EnterByIdUserCancel
        ,t.TransactionProviderCancelDate DateOfCancelTransaction
        ,isnull(u2.Userlogin,'') UserNameCancel       
    from Operation.ProductTransfer t with(nolock)
	inner join Agent a with(nolock) on a.IdAgent= t.IdAgent
	inner join Users u with(nolock) on u.IdUser= t.EnterByIdUser
     left join users u2 with(nolock) on t.EnterByIdUserCancel=u2.iduser     
    inner join pureminutestransaction piv with(nolock) on piv.IdProductTransfer=t.IdProductTransfer
	where t.IdProductTransfer=@IdProductTransfer
end