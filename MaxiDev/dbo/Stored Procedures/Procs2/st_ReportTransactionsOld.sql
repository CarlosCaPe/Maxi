CREATE procedure [dbo].[st_ReportTransactionsOld]            
(            
@StartDate DateTime,            
@EndDate Datetime            
)            
AS            
Set nocount on          
        
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
A.DateOfTransfer,  
A.DateStatusChange    
From transfer A    
Join Status C on (A.IdStatus=C.IdStatus)    
Join Payer D on (D.IdPayer=A.IdPayer)    
Join PaymentType E on (E.IdPaymentType=A.IdPaymentType)            
Join CountryCurrency F on (F.IdCountryCurrency=A.IdCountryCurrency)            
Join Country G on (G.IdCountry=F.IdCountry)            
Join Gateway H on (H.IdGateway=A.IdGateway)    
Join Users I on (I.IdUser=A.EnterByIdUser)    
Join Agent J on (J.IdAgent=A.IdAgent)    
Join Users K on (K.IdUser=A.IdSeller)    
Where A.DateOfTransfer>=@StartDate And  A.DateOfTransfer<@EndDate   
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
A.DateOfTransfer,  
A.DateStatusChange   
From TransferClosed A    
Join TransferClosedDetail B on (A.IdTransferClosed=B.IdTransferClosed)    
Join Status C on (A.IdStatus=C.IdStatus)    
Join CountryCurrency F on (F.IdCountryCurrency=A.IdCountryCurrency)            
Join Gateway H on (H.IdGateway=A.IdGateway)    
Join Users I on (I.IdUser=A.EnterByIdUser)    
Join Agent J on (J.IdAgent=A.IdAgent)    
Join Users K on (K.IdUser=A.IdSeller)    
Where A.DateOfTransfer>=@StartDate And  A.DateOfTransfer<@EndDate
