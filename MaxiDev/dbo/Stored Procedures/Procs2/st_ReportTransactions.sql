CREATE procedure [dbo].[st_ReportTransactions]            
(            
@StartDate DateTime,            
@EndDate Datetime            
)            
AS            
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="20/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;
        
        
Select @EndDate=dbo.RemoveTimeFromDatetime(@EndDate+1)                
Select @StartDate=dbo.RemoveTimeFromDatetime(@StartDate)        
    
 Select     
 A.ClaimCode,    
 C.StatusName,    
 D.PayerName,    
 H.GatewayName,    
 AmountInDollars,    
 AmountInMN,    
 Fee,    
 AgentCommission,    
 AgentCommissionExtra,    
 K.UserName as SellerName,    
 CorporateCommission,    
 ExRate,    
 ReferenceExRate,    
 E.PaymentName,    
 G.CountryName,    
 I.UserName,    
 A.TotalAmountToCorporate,    
 J.AgentCode,    
 J.AgentName,    
 A.Folio,  
 J.AgentState,   
 I.UserLogin,  
 B.DateOfMovement  
 From [transfer] A with(nolock)
 Join TransferDetail B with(nolock) on (A.IdTransfer=B.IdTransfer)    
 Join [Status] C with(nolock) on (B.IdStatus=C.IdStatus)    
 Join Payer D with(nolock) on (D.IdPayer=A.IdPayer)    
 Join PaymentType E with(nolock) on (E.IdPaymentType=A.IdPaymentType)            
 Join CountryCurrency F with(nolock) on (F.IdCountryCurrency=A.IdCountryCurrency)            
 Join Country G with(nolock) on (G.IdCountry=F.IdCountry)            
 Join Gateway H with(nolock) on (H.IdGateway=A.IdGateway)    
 Join Users I with(nolock) on (I.IdUser=A.EnterByIdUser)    
 Join Agent J with(nolock) on (J.IdAgent=A.IdAgent)    
 Join Users K with(nolock) on (K.IdUser=A.IdSeller)    
 Where B.DateOfMovement>=@StartDate And  B.DateOfMovement<@EndDate     
UNION    
 Select      
 A.ClaimCode,    
 C.StatusName,    
 A.PayerName,    
 A.GatewayName,    
 AmountInDollars,    
 AmountInMN,    
 Fee,    
 AgentCommission,    
 AgentCommissionExtra,    
 K.UserName as SellerName,    
 CorporateCommission,    
 ExRate,    
 ReferenceExRate,    
 A.PaymenttypeName as PaymentName,    
 A.CountryName,    
 I.UserName,    
 A.TotalAmountToCorporate,    
 J.AgentCode,    
 J.AgentName,    
 A.Folio,  
 J.AgentState,  
 I.UserLogin,  
 B.DateOfMovement    
 From TransferClosed A with(nolock)    
 Join TransferClosedDetail B with(nolock) on (A.IdTransferClosed=B.IdTransferClosed)    
 Join [Status] C with(nolock) on (B.IdStatus=C.IdStatus)    
 Join CountryCurrency F with(nolock) on (F.IdCountryCurrency=A.IdCountryCurrency)            
 Join Gateway H with(nolock) on (H.IdGateway=A.IdGateway)    
 Join Users I with(nolock) on (I.IdUser=A.EnterByIdUser)    
 Join Agent J with(nolock) on (J.IdAgent=A.IdAgent)    
 Join Users K with(nolock) on (K.IdUser=A.IdSeller)    
 Where B.DateOfMovement>=@StartDate And  B.DateOfMovement<@EndDate  
  