CREATE PROCEDURE [dbo].[st_ReportTransfer]      
 (              
@StartDate datetime,                    
@EndDate datetime,                
@IdAgent int,                
@IdStatus int,                
@IdPayer int,                
@IdGateway int,                
@IdCountry int,                 
@ClaimCode nvarchar(max),                
@Folio int,                
@CustomerFirstLastName nvarchar(max),                
@BeneficiaryFirstLastName nvarchar(max),                
@IdCustomer int,      
@ByFilter bit      
)       
AS  
  
DECLARE     @HasError bit,  
            @Message nvarchar(max)  
if @ByFilter = 1  
BEGIN  
exec st_Filter @StartDate, @EndDate, @IdAgent, @IdStatus, @IdPayer, @IdGateway, @IdCountry, @ClaimCode, @Folio, @CustomerFirstLastName, @BeneficiaryFirstLastName, @IdCustomer, @HasError OUTPUT, @Message OUTPUT  
END  
else  
BEGIN  
exec st_FilterByStatus @StartDate, @EndDate, @IdAgent, @IdStatus, @IdPayer, @IdGateway, @IdCountry, @ClaimCode, @Folio, @CustomerFirstLastName, @BeneficiaryFirstLastName, @IdCustomer , @HasError OUTPUT, @Message OUTPUT  
END  
  
 /*     
 Declare @ValorInt int,@ValorMoney money      
      
Select       
 @ValorInt as IdTransfer,                
'' as ClaimCode,                
GETDATE() as DateOfTransfer,                
'' as AgentCode,                
'' as AgentName,                
@ValorInt as Folio,                
'' as CustomerName,                
'' as BeneficiaryName,                
'' as PayerName,                
'' as PaymentTypeName,                
'' as CountryName,                
@ValorMoney as AmountInDollars,                
'' as StatusName         
*/
