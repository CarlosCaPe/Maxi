
CREATE Procedure [dbo].[st_CreateTransferOld]                                                                                            
(                                                                                            
--@IsSpanishLanguage bit,                                                                                            
@IdLenguage int ,
@IdCustomer int,                                                                                              
@IdBeneficiary int,                                                                                              
@IdPaymentType int,                                                            
@IdCity int,                                                                                              
@IdBranch int,                                                                                              
@IdPayer int,                                                                                              
@IdGateway int,                                                                                              
@GatewayBranchCode nvarchar(max),                                                                                              
@IdAgentPaymentSchema int,                                                                                              
@IdAgent int,                                                                                              
@IdAgentSchema int,                                                                                              
@IdCountryCurrency int,                                                                                              
@AmountInDollars money,                                                                                              
@Fee money,                                                                                              
@AgentCommission money,                                                                                              
@CorporateCommission money,                                                                                              
@ExRate money,                                                                                              
@ReferenceExRate money,                                                                                              
@AmountInMN money,                                                                                              
@DepositAccountNumber nvarchar(max),                                                                                              
@EnterByIdUser int,                                                                                              
@TotalAmountToCorporate money,                                                                                              
@BeneficiaryName nvarchar(max),                                                                                              
@BeneficiaryFirstLastName nvarchar(max),                                                                                              
@BeneficiarySecondLastName nvarchar(max),                                                                                              
@BeneficiaryAddress nvarchar(max),                                                                                              
@BeneficiaryCity nvarchar(max),                                                                                              
@BeneficiaryState nvarchar(max),                                                                                              
@BeneficiaryCountry nvarchar(max),                                                                                              
@BeneficiaryZipcode nvarchar(max),                                                                                              
@BeneficiaryPhoneNumber nvarchar(max),                                                                                              
@BeneficiaryCelularNumber nvarchar(max),                                                    
@CustomerName nvarchar(max),                              
@CustomerIdCustomerIdentificationType int,               
@CustomerFirstLastName nvarchar(max),                                                              
@CustomerSecondLastName nvarchar(max),                              
@CustomerAddress nvarchar(max),                                                             
@CustomerCity nvarchar(max),                                                                                         
@CustomerState nvarchar(max),                                                                                              
@CustomerZipcode nvarchar(max),                                           
@CustomerPhoneNumber nvarchar(max),                                                              
@CustomerCelullarNumber nvarchar(max),                                                         
@CustomerSSNumber nvarchar(max),                                                                
@CustomerBornDate datetime,                                                       
@CustomerOccupation nvarchar(max),                                                     
@CustomerIdentificationNumber nvarchar(max),                                                           
@CustomerExpirationIdentification datetime,                                                          
@CustomerPurpose nvarchar(max),                                                                                            
@CustomerRelationship nvarchar(max),                                                                                            
@CustomerMoneySource nvarchar(max),                                                                          
@CustomerIdCarrier int,                                                        
@XmlRules xml,                                                                                            
@IdTransferResend int,                                                                          
@OWBName nvarchar(max),                                                                                            
@OWBFirstLastName nvarchar(max),                                                                                            
@OWBSecondLastName nvarchar(max),                                                              
@OWBAddress nvarchar(max),                                                                                            
@OWBCity nvarchar(max),                                                                       
@OWBState nvarchar(max),                                                                                            
@OWBZipcode nvarchar(max),                                                                         
@OWBPhoneNumber nvarchar(max),                                                                                            
@OWBCelullarNumber nvarchar(max),                                                                                
@OWBSSNumber nvarchar(max),                                                                                            
@OWBBornDate datetime,                                                               
@OWBOccupation nvarchar(max),                                                                                            
@OWBIdentificationNumber nvarchar(max),                                                                                            
@OWBIdCustomerIdentificationType int,                                                                                            
@OWBExpirationIdentification datetime,                                                                                            
@OWBPurpose nvarchar(max),                                                                                            
@OWBRelationship nvarchar(max),                        
@OWBMoneySource nvarchar(max),                        
@AgentCommissionExtra Money,                                                                              
@AgentCommissionOriginal Money,                                                                              
@AgentCommissionEditedByCommissionSlider Money,                                                                       
@AgentCommissionEditedByExchangeRateSlider Money,                                                                   
@StateTax Money,                     
@OriginExRate Money,                        
@OriginAmountInMN Money,   
@NoteAdditional varchar(max),    
@CustomerIdentificationIdCountry int,  
@CustomerIdentificationIdState int,    
@OWBRuleType int,  
@IdBeneficiaryIdentificationType int,
@BeneficiaryIdentificationNumber nvarchar(max),             
@HasError bit out,                                                                                            
@Message varchar(max) out,                                                          
@IdTransferOutput int output,
@IdCustomerOutput int output,
@SSNRequired bit = null                                          
)                                                                                                        
As
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
Set nocount on    
--@OWBRuleType  0- No pidio Owbh, 1- Pidio y el dinero es suyo, 2- pidio y el dinero no es suyo                                                                     
Select  @HasError                                                                  
Declare @CustomerIdAgentCreatedBy  int                                                                                    
Set @CustomerIdAgentCreatedBy=@IdAgent                                                                                    
Declare @DateOfTransfer datetime                                                                                         
Declare @DateOfLastChange datetime                                                             
Set @DateOfTransfer=Getdate()                                                                                        
Set @DateOfLastChange=Getdate()                                                                                        
Declare @CustomerCountry nvarchar(max)                                                                      
Set  @CustomerCountry='USA'                                                                                        
Declare @OWBCountry nvarchar(max)                                                                              
Set   @OWBCountry ='USA'                                                                                         
Declare @BeneficiaryNote nvarchar(max)                                                                                        
Set  @BeneficiaryNote=''                                                                                          
declare @dateNow Datetime  
set @dateNow= GETDATE()  

if @IdLenguage is null 
    set @IdLenguage=2  
  
Begin Try     
  
----------------------  Verify if @EnterByIdUser resend transfer in #time --------------------  
if @EnterByIdUser<>0  
Begin  
 If  (select top 1 DATEDIFF(second, DateOfTransfer, @dateNow) from [Transfer] with(nolock) where EnterByIdUser= @EnterByIdUser order by IdTransfer desc) <= 5  
  Begin  
   Set @HasError=1                                                                           
   --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,61)   
   SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE61')
   Return   
 End  
End    
  
---------------------- TransferResend verification -------------------------------------------  
if @IdTransferResend<>0  
Begin  
 If exists (Select 1 from TransferResend with(nolock) where IdTransfer= @IdTransferResend)  
  Begin  
   Set @HasError=1                                                                           
   --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,56)   
   SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE56')
   Return   
 End  
End                                                            
----------  Special case when Agent is disable ------------------------------                        
                                                          
If exists (Select 1 from Agent with(nolock) where IdAgent=@IdAgent and (IdAgentStatus=2 or IdAgentStatus=3 or IdAgentStatus=5 or IdAgentStatus=6 or IdAgentStatus=7) )                                                           
  Begin                                                          
  Set @IdTransferOutput=0                                                        
  Set @HasError=1                                                                                            
     --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,29)                                                   
     SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE29')
  Return                                                          
  End                                                          
                                
								
if not exists(select idpayer from branch with(nolock) where idbranch=@IdBranch)
begin
    set @IdBranch=null
end 								                            
                                   
----- Special case when Idbranch is null but transfer is cash ----------------                                                            
If (@IdBranch is null and (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2))                                                            
Begin                                 
 If @IdCity is Null                                
 Begin                                
  Select top 1 @IdBranch=IdBranch from Branch with(nolock) where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null)  order by IdBranch                                                       
  Select @GatewayBranchCode=GatewayBranchCode from GatewayBranch with(nolock) where IdBranch=@IdBranch                                                           
 End                                
 Else                                
 Begin                
  Select top 1 @IdBranch=IdBranch from Branch with(nolock) where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null) and IdCity=@IdCity order by IdBranch                                                       
  Select @GatewayBranchCode=GatewayBranchCode from GatewayBranch with(nolock) where IdBranch=@IdBranch                                                           
 End                                
End   
  
  
-- Check Again IdBranch in case @IdCity was not null but not exists  
  
If (@IdBranch is null and (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2))                                                            
Begin                                 
  Select top 1 @IdBranch=IdBranch from Branch with(nolock) where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null)  order by IdBranch                                                       
  Select @GatewayBranchCode=GatewayBranchCode from GatewayBranch with(nolock) where IdBranch=@IdBranch   
  Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) values ('st_CreateTransfer',GETDATE(),' Y el IdPayer es '+CONVERT(Varchar,@IdPayer));  
    
End  
                            
---------------------------------------------------------------------------------                                                            
                                                                      
If @GatewayBranchCode is Null  Set @GatewayBranchCode=''                                                                                      
If @DepositAccountNumber is Null Set @DepositAccountNumber=''                                                                                      
If @BeneficiaryZipcode is Null  Set @BeneficiaryZipcode=''                                      
If @BeneficiaryAddress is Null Set @BeneficiaryAddress=''                                                      
if @BeneficiaryCity is Null Set @BeneficiaryCity=''                                                   
if @BeneficiaryState is Null Set @BeneficiaryState=''                                                                                             
if @BeneficiaryCountry is Null Set @BeneficiaryCountry=''                                                                             
if @BeneficiaryName is Null Set @BeneficiaryName=''                                                                                              
if @BeneficiaryFirstLastName is Null Set @BeneficiaryFirstLastName=''                                                                     
if @BeneficiarySecondLastName is Null Set @BeneficiarySecondLastName=''                                                      
If @BeneficiaryPhoneNumber is Null Set @BeneficiaryPhoneNumber=''                                                                                      
If @BeneficiaryCelularNumber is Null Set @BeneficiaryCelularNumber=''                                                                                      
If @BeneficiaryNote is Null Set @BeneficiaryNote=''                                                                                      
If @CustomerZipcode is Null Set @CustomerZipcode=''                                                                                      
If @CustomerPhoneNumber  is Null Set @CustomerPhoneNumber=''                                                                                      
If @CustomerCelullarNumber is Null Set @CustomerCelullarNumber=''                                                                                      
If @CustomerSSNumber is Null Set @CustomerSSNumber=''                                                                                      
If @CustomerOccupation is Null Set @CustomerOccupation=''                                                                                      
If @CustomerIdentificationNumber is Null Set @CustomerIdentificationNumber=''                                                                                      
If @CustomerPurpose is Null Set @CustomerPurpose=''                                                                                      
If @CustomerRelationship is Null Set @CustomerRelationship=''                                                                                      
If @CustomerMoneySource  is Null Set @CustomerMoneySource=''                  
if @OWBName is Null Set   @OWBName=''                                                                                        
if @OWBFirstLastName is Null Set @OWBFirstLastName=''                                                                                      
if @OWBSecondLastName is Null Set @OWBSecondLastName=''                                                                                  
if @OWBAddress is Null Set  @OWBAddress=''                             
if @OWBCity is Null Set @OWBCity=''                                                                                      
if @OWBState is Null Set @OWBState=''                                                              
if @OWBZipcode is Null Set @OWBZipcode=''                                              
if @OWBPhoneNumber is Null Set @OWBPhoneNumber=''                                                                                      
if @OWBCelullarNumber  is Null Set @OWBCelullarNumber=''                                                                                      
if @OWBSSNumber  is Null Set @OWBSSNumber=''                                                                                      
if @OWBOccupation  is Null Set @OWBOccupation=''                                                                                      
if @OWBIdentificationNumber  is Null Set @OWBIdentificationNumber=''                                                                                      
if @OWBPurpose  is Null Set @OWBPurpose=''                                                                                      
if @OWBRelationship  is Null Set @OWBRelationship=''                                                                                      
if @OWBMoneySource  is Null Set @OWBMoneySource=''                                                                                      
                                 
----------------------------------- Insert/Update Customer ----------------------------                                                                                            
--Declare @IdCustomerOutput INT                                                                                            
                                                                                         
                                                                                          
EXEC st_InsertCustomerByTransfer                                                                                             
@IdCustomer,                                                                                            
@CustomerIdAgentCreatedBy,                                                       
@CustomerIdCustomerIdentificationType,                                                                                            
1,                                                                                        
@CustomerName,                                                                                              
@CustomerFirstLastName,                                       
@CustomerSecondLastName,                                                                                      
@CustomerAddress,                                                                                      
@CustomerCity,                                                                                              
@CustomerState,                                                                    
@CustomerCountry,                                                                                              
@CustomerZipcode,                                                                                              
@CustomerPhoneNumber,                                                                                              
@CustomerCelullarNumber,                                                                                              
@CustomerSSNumber,                                                                      
@CustomerBornDate,                                                                                            
@CustomerOccupation,                                                                                       
@CustomerIdentificationNumber,                   
0,                                                                                              
@DateOfTransfer,                                                                                            
@EnterByIdUser,                                                                                            
@CustomerExpirationIdentification,                                                                          
@CustomerIdCarrier,     
@CustomerIdentificationIdCountry ,  
@CustomerIdentificationIdState , 
@AmountInDollars,                                                                                          
@IdCustomerOutput Output;                                                               
                                                                                    
----------------------------------- Insert/Update Beneficiary ----------------------------                    
Declare @IdBeneficiaryOutput INT                                                             
                                                                                            
EXEC st_InsertBeneficiaryByTransfer                                                                                            
@IdBeneficiary,                                                   
@BeneficiaryName,                                                                                              
@BeneficiaryFirstLastName,                                                                                              
@BeneficiarySecondLastName,                                       
@BeneficiaryAddress,                                                                                              
@BeneficiaryCity,                                                                                            
@BeneficiaryState,                                                                                              
@BeneficiaryCountry,                                                                                          
@BeneficiaryZipcode,                                                                                              
@BeneficiaryPhoneNumber,              
@BeneficiaryCelularNumber,              
'',                                                                            
Null,                                                                                              
'',                                                                                              
@BeneficiaryNote,                                                                                              
1,                                           
@DateOfTransfer,                                                                       
@EnterByIdUser, 
@IdBeneficiaryIdentificationType,  
@BeneficiaryIdentificationNumber,                                                                                         
@IdBeneficiaryOutput Output ;                                                                                           
                                                                                            
------------------------------ Insert OWB ----------------------------------------------------                                                                                  
Declare @IdOnWhoseBehalfOutput Int                                                                                       
                                                                                            
If Len(@OWBName)>0                                                                                            
Begin                                                                                            
  EXEC st_InsertOnWhoseBehalf                                                                          
  @IdAgent,                                                                      
  1,                                                                                            
  @OWBName,                                                         
  @OWBFirstLastName,                                                                                            
  @OWBSecondLastName,                                                        
  @OWBAddress,                                                                                            
  @OWBCity,                                                                                            
  @OWBState,                                                      
  @OWBCountry,                                                                                         
  @OWBZipcode,                                                                     
  @OWBPhoneNumber,                                                                                            
  @OWBCelullarNumber,                             
  @OWBSSNumber,                                                                                            
  @OWBBornDate,                                                                  
  @OWBOccupation,                                                                                            
  @OWBIdentificationNumber,                                                                                      
  0,                                                                                        
  @OWBIdCustomerIdentificationType,                                                                             
  @OWBExpirationIdentification,   
  @OWBPurpose,                                                                                            
  @OWBRelationship,                                                                                            
  @OWBMoneySource,                                                                                            
  @DateOfTransfer,                                         
  @EnterByIdUser,                                                                                            
  @IdOnWhoseBehalfOutput OUTPUT ;                                      
End                                                                                            
Else                                                                                            
 Set @IdOnWhoseBehalfOutput=Null                                                                       
                                                                                            
                                                                                            
----------------------------------------------------------------------------------------------                                                                                
                                        
Declare @Folio int                                                                                            
Declare @ClaimCode nvarchar(max)                                                                                            
Declare @ConfirmationCode nvarchar(max)                                                                                            
Declare @IdTransfer Int                                                                
Declare @IdSeller int                                                                 
                                                                                           
                                                                                           
------------------------ Generador de Claim Code ---------------------------------------------------------------                                                                                           
                                                 
 Set @ClaimCode=''                                           
 Set @ConfirmationCode=''                                      
                                                             
                                                                                        
If (@IdGateway=3) or (@IdGateway=10) or (@IdGateway=9) or (@IdGateway=8) or (@IdGateway=11) or (@IdGateway=13) or (@IdGateway=14) or (@IdGateway=15) or (@IdGateway=16) or (@IdGateway=18) or (@IdGateway=20) or (@IdGateway=22) or (@IdGateway=19)
Begin                                        
  Declare @PayerCode nvarchar(max)                                                                                          
  Select @PayerCode=PayerCode From Payer with(nolock) where IdPayer=@IdPayer                                                              
               
  Create Table #Result                                                                                          
  (                                                                                          
  Result nvarchar(max)                                                                                          
  )                                                                                          
                              
  Insert into #Result (Result)                                                                                          
  EXEC ST_TNC_CLAIM_CODE_GEN @PayerCode                                                                                          
  Select @ClaimCode = ltrim(rtrim(Result)) From #Result;                                                                                         
                                                                              
  if @IdGateway=3                                          
  Begin                                  
 Delete #Result                                                                                  
 Insert into #Result (Result)                                                                                  
 EXECUTE DBO.ST_TNC_CONF_CODE_GEN '01', '01', @CustomerName, @BeneficiaryName, @BeneficiaryFirstLastName, @BeneficiarySecondLastName, @AmountInMN ;                                               
 Select @ConfirmationCode = ltrim(rtrim(Result)) From #Result                                                                                       
  End                                                                                 
  Else                                     
  Begin                                                                                
    Set @ConfirmationCode = 'No need'                                                                                   
  End                                                                                 
                                                     
                                                                                    
End                                                                                         
                                                    
                                                
If @IdGateway=4                                                    
Begin                                        
 Declare @BancomerClaimCode nvarchar(max),@FolioResult int                                                    
 Exec CreateBancomerReceiptFolio @IdCountryCurrency,@IdPayer,@BancomerClaimCode output,@FolioResult output;                                                    
 Set @ClaimCode=@BancomerClaimCode                                                    
Set @ConfirmationCode=''                                                                                       
End                                                    
                                                                              
                                                                                      
-------------------------- Incremente de Folio por Agencia -----------------------------------------------------                                                                                            
                      
                                                                                            
  --Update Agent Set Folio=Folio+1, @Folio=Folio+1  Where IdAgent=@IdAgent                                                                                             
 if not exists(select 1 from [AgentFolioPreFolio] with(nolock) where idagent=@IdAgent)
 begin
    insert into [AgentFolioPreFolio] (idagent,folio,prefolio) values (@IdAgent,0,0);
 end

 Update [AgentFolioPreFolio] Set Folio=Folio+1, @Folio=Folio+1  Where IdAgent=@IdAgent;                                                                                            
                                                                                           
--------------------------- Select IDSeller  --------------------------------------------------------------------                                                                                            
Select @IdSeller=isnull(IdUserSeller,1),@IdAgentPaymentSchema=IdAgentPaymentSchema from Agent with(nolock) where IdAgent=@IdAgent                                                                
-----------------------------------------------------------------------------------------------------------------                                                                
                                                                           
INSERT INTO [Transfer]                                                                                              
   (                                                                                            
   IdCustomer,                             
   IdBeneficiary,                                                                                            
   IdPaymentType,                                
   IdBranch,                                                                                            
   IdPayer,                                                                                            
   IdGateway,                                                                                            
   GatewayBranchCode,                                                                                     
   IdAgentPaymentSchema,                                                                                            
   IdAgent,                                                                                            
   IdAgentSchema,                                                          
   IdCountryCurrency,                                                                                            
   IdStatus,                                                   
   ClaimCode,                                                                    
   ConfirmationCode,                                                                                            
   AmountInDollars,                                                                                
   Fee,                                                                                            
   AgentCommission,                                                                                            
   CorporateCommission,                                                                                          
   DateOfTransfer,                                                                           
   ExRate,                                                                                            
   ReferenceExRate,                                                                                            
   AmountInMN,                                                                                            
   Folio,                                                                
   DepositAccountNumber,                                                                                            
   DateOfLastChange,                                             
   EnterByIdUser,                                                                                        
   TotalAmountToCorporate,                                                                                            
   BeneficiaryName,                                                                                            
   BeneficiaryFirstLastName,                                              
   BeneficiarySecondLastName,                                                                          
   BeneficiaryAddress,                                                                     
   BeneficiaryCity,                                                                              
   BeneficiaryState,                                                                                            
   BeneficiaryCountry,                                                                                            
   BeneficiaryZipcode,                                                                                            
   BeneficiaryPhoneNumber,                                                                                            
   BeneficiaryCelularNumber,                             
   BeneficiaryNote,                                                                                            
   CustomerName,                                  
   CustomerIdAgentCreatedBy,                                                                                            
   CustomerIdCustomerIdentificationType,                                                                                            
   CustomerFirstLastName,                                                       
   CustomerSecondLastName,                                                           
   CustomerAddress,                   
   CustomerCity,                           
   CustomerState,                                                                                            
   CustomerCountry,                                             
   CustomerZipcode,                                                                                            
   CustomerPhoneNumber,                                                                                            
   CustomerCelullarNumber,                                                                            
   CustomerSSNumber,                                                                                            
   CustomerBornDate,                                                                
   CustomerOccupation,                                                                         
   CustomerIdentificationNumber,                                               
   CustomerExpirationIdentification,                                                                          
   CustomerIdCarrier,                                                                                            
   IdOnWhoseBehalf,                                                                                            
   Purpose,                                                                              
   Relationship,                                                                                            
   MoneySource,                                                                              
   AgentCommissionExtra,                                                                         
   AgentCommissionOriginal,                                                                              
   ModifierCommissionSlider,                                                                         
   ModifierExchangeRateSlider,                     
   IdSeller,                        
   OriginExRate,                        
   OriginAmountInMN,      
   NoteAdditional,    
 CustomerIdentificationIdCountry,  
 CustomerIdentificationIdState,
 IdBeneficiaryIdentificationType,  
   BeneficiaryIdentificationNumber                                                                                            
           )                                                                                              
     VALUES                                                                                              
           (                                                                                            
           @IdCustomerOutput ,                                                     
           @IdBeneficiaryOutput ,             
           @IdPaymentType ,                                                                                             
           @IdBranch ,                                                                                              
           @IdPayer ,                                                                                              
           @IdGateway ,                                                                                   
           @GatewayBranchCode ,                                                                                              
           @IdAgentPaymentSchema ,                                                              
           @IdAgent ,                                
           @IdAgentSchema ,                                                                                              
           @IdCountryCurrency ,                                                                                              
           1,                                                                  
           @ClaimCode,                                                     
           @ConfirmationCode ,                                                                          
           @AmountInDollars ,                                                                                              
           @Fee ,                                    
           @AgentCommission ,                                                                                              
           @CorporateCommission ,                         
           @DateOfTransfer ,                                                                                              
           @ExRate ,                                                                                              
           @ReferenceExRate ,                                                          
           @AmountInMN ,                                                                                              
           @Folio ,                                                                                              
           @DepositAccountNumber ,                                                                              
           @DateOfLastChange ,                                                                                              
           @EnterByIdUser ,                                                                                              
           @TotalAmountToCorporate ,                                                                                              
           @BeneficiaryName ,                                                                                              
           @BeneficiaryFirstLastName ,                                                                                              
           @BeneficiarySecondLastName ,                                                                                              
           @BeneficiaryAddress ,                                                             
           @BeneficiaryCity ,                                                                                              
           @BeneficiaryState ,                                                                                              
           @BeneficiaryCountry ,                                                                                              
           @BeneficiaryZipcode ,                                                                                              
           @BeneficiaryPhoneNumber ,                                                                                              
           @BeneficiaryCelularNumber ,                                                                                              
           @BeneficiaryNote ,                                                                    
           @CustomerName ,                               
           @CustomerIdAgentCreatedBy ,                                                                                              
           @CustomerIdCustomerIdentificationType ,                                                                                              
           @CustomerFirstLastName ,                                                                            
           @CustomerSecondLastName ,                                                                                
           @CustomerAddress ,                                                                                              
           @CustomerCity ,                                            
           @CustomerState ,                                                                                              
           @CustomerCountry ,                                                                                              
           @CustomerZipcode ,                                                                                              
           @CustomerPhoneNumber ,                                                                                              
           @CustomerCelullarNumber,                                                                            
           @CustomerSSNumber,                                                                                            
           @CustomerBornDate,                
           @CustomerOccupation,                                        
           @CustomerIdentificationNumber ,                                                                                              
           @CustomerExpirationIdentification,                                                                          
           @CustomerIdCarrier,                                                                                            
           @IdOnWhoseBehalfOutput,                                                                                            
           @CustomerPurpose,                                                                                            
           @CustomerRelationship,                                                                                          
           @CustomerMoneySource,                                                                              
           @AgentCommissionExtra,                             
           @AgentCommissionOriginal,                                                                              
           @AgentCommissionEditedByCommissionSlider,                                                                              
           @AgentCommissionEditedByExchangeRateSlider,                                                                
           @IdSeller,                        
           @OriginExRate,                        
           @OriginAmountInMN,  
           @NoteAdditional ,    
   @CustomerIdentificationIdCountry ,  
   @CustomerIdentificationIdState,
   @IdBeneficiaryIdentificationType,  
   @BeneficiaryIdentificationNumber                                         
            );                                                                                              
                                                                                             
 Select @IdTransfer=SCOPE_IDENTITY();                                                                                            
                                                                   
                                                                                             
----------------------  Insert in case Resend Transfer -------------------------------------------------------                                                                                                        
          
                                                                                                     
                                                                                                     
If ISNULL(@IdTransferResend,0) <> 0                                                                                            
Begin                     
Insert into TransferResend (IdTransfer,Note,DateOfLastChange,EnterByIdUser,NewIdTransfer)                                
values (@IdTransferResend,'Resend by st_CreateTransfer',@DateOfTransfer,@EnterByIdUser,@IdTransfer);                                                                                            
-- Afectar el saldo del agente con un cargo negativo -----------                                                                 
Declare @ReturnCommission money                                                                
Declare @ResendHasError bit                                                                
Declare @ResendMessage nvarchar(max)                                                                
Declare @Reference nvarchar(max),@ResendNote nvarchar(max)     
  
If Exists(Select 1 From [Transfer] with(nolock) where IdTransfer=@IdTransferResend)  
Begin  
 Select @ReturnCommission=case when TotalAmountToCorporate=AmountInDollars+Fee Then  (TotalAmountToCorporate-AmountInDollars) Else (CorporateCommission) End ,  
 --@ResendNote='Credit Retransfer, Folio:'+CONVERT(varchar(max),Folio),   
 @ResendNote='Folio:'+CONVERT(varchar(max),Folio),   
 @Reference=CONVERT(varchar(max),Folio)   
 From [Transfer] with(nolock) where IdTransfer=@IdTransferResend                                  
End  
Else  
Begin   
 Select @ReturnCommission=case when TotalAmountToCorporate=AmountInDollars+Fee Then  (TotalAmountToCorporate-AmountInDollars) Else (CorporateCommission) End ,  
 --@ResendNote='Credit Retransfer, Folio:'+CONVERT(varchar(max),Folio),   
 @ResendNote='Folio:'+CONVERT(varchar(max),Folio),   
 @Reference=CONVERT(varchar(max),Folio)   
 From TransferClosed with(nolock) where IdTransferClosed=@IdTransferResend                                
End  
                               
exec st_SaveOtherCharge 1,@IdAgent,@ReturnCommission,0,@DateOfTransfer,@ResendNote,@Reference,@EnterByIdUser,@HasError=@ResendHasError Output,@Message=@ResendMessage  Output,@IdOtherChargesMemo=6,@OtherChargesMemoNote=null;   --6	Retransfer Credit
  
End                                                                                        
                                                                                        
                                                                     
---------------------------- State Tax --------------------------------------------------------------------------                                                                    
If @StateTax>0                                                                    
Begin                                             
                   
 Insert into StateFee (State,Tax,IdTransfer)                                                                    
 Select AgentState,@StateTax,@IdTransfer from Agent with(nolock) Where IdAgent=@IdAgent;                   
                  
 Declare @FeeNote nvarchar(max), @FeeReference nvarchar(max), @SateName nvarchar(max),@StateFeeHasError bit,@StateFeeMessage nvarchar(max)                      
 Select top 1 @SateName=StateName  from ZipCode with(nolock) where StateCode=(Select AgentState from Agent with(nolock) Where IdAgent=@IdAgent )                  
 --Select @FeeNote=@SateName+' State Fee, Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From Transfer where IdTransfer=@IdTransfer                                                  
 Select @FeeNote='Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From Transfer with(nolock) where IdTransfer=@IdTransfer                                                  
                   
 Exec st_SaveOtherCharge 1,@IdAgent,@StateTax,1,@DateOfTransfer,@FeeNote,@FeeReference,@EnterByIdUser,@HasError=@StateFeeHasError Output,@Message=@StateFeeMessage   Output,@IdOtherChargesMemo=1,@OtherChargesMemoNote=null   --1	Oklahoma State Fee
                                                                    
End                                                                    
                                                                                            
------------------------- Insert Broken Rules -------------------------------------------------------------------                                                                                            
                                                                                            
Declare @HasErrorBrokenRules bit                                                                                            
EXEC st_InsertBrokenRulesByTransfer @IdTransfer,@XmlRules,@OWBRuleType,@HasError=@HasErrorBrokenRules Output                                        
If @HasErrorBrokenRules=1                                                                                            
 Select 1/0                                                                                
  
  
                                                                                            
--------------------------Agent hold ---------------------------------------------------------------------------                                                         
           
Declare @CurrentBalance Money,@SystemIdUser INT, @CreditLimitSuggested money                                                       
Set  @CurrentBalance=0                                                        
Select @CurrentBalance=isNull(Balance,0) from AgentCurrentBalance where IdAgent=@IdAgent                                                        

SELECT TOP 1 @CreditLimitSuggested=CreditLimitSuggested FROM dbo.AgentCreditApproval WHERE IdAgent=@IdAgent AND ISNULL(IsApproved,-1)=-1 ORDER BY IdAgentCreditApproval DESC
SET @CreditLimitSuggested=ISNULL(@CreditLimitSuggested,0)

If 
exists (Select 1 from Agent where IdAgent=@IdAgent and CreditAmount<@AmountInDollars+@CurrentBalance)         
AND
(@CreditLimitSuggested<@AmountInDollars+@CurrentBalance)
Begin                                
 Select @SystemIdUser=dbo.GetGlobalAttributeByName('SystemUserID')                                                        
 --Update Agent set IdAgentStatus=4, EnterByIdUser=@SystemIdUser where IdAgent=@IdAgent                          

 exec [dbo].[st_AgentStatusChange] 
    @IdAgent,
    4,
    @SystemIdUser,
    'Hold by Create Transfer'
End                                                                    
                                                 
                                                        
------------------------------------------------------------------------------------------------------------------                                                
 Set @IdTransferOutput=@IdTransfer    
 
 if(isnull(@SSNRequired,0)=1)
 begin
    insert into [TransferSSN] values (@IdTransfer,1,getdate())
 end   
 
 
  --service broker
 -----------------------------------------------------------------------------------------------------------------
 declare @Country nvarchar(max)

 select @Country=c.CountryCode from countrycurrency  cc
 join country c on cc.IdCountry=c.IdCountry
 where idcountrycurrency=@IdCountryCurrency

 DECLARE
    @conversation uniqueidentifier,
    @msg xml

set @msg =(
SELECT 
    @IdTransfer IdTransfer,
    1 IdTransferStatus,
    @EnterByIdUser EnterByIdUser,
    @IdAgent IdAgent, 
    @IdPayer IdPayer,
    @CustomerName CustomerName,
    @CustomerFirstLastName CustomerFirstLastName,
    @CustomerSecondLastName CustomerSecondLastName,
    @BeneficiaryName BeneficiaryName,
    @BeneficiaryFirstLastName BeneficiaryFirstLastName,
    @BeneficiarySecondLastName BeneficiarySecondLastName,    
    @IdPaymentType IdPaymentType,
    @TotalAmountToCorporate Amount,
    @Folio Reference,    
    @Country Country,
    @AgentCommissionExtra AgentCommissionExtra,
    @AgentCommissionOriginal AgentCommissionOriginal,
    @AgentCommissionEditedByCommissionSlider ModifierCommissionSlider,
    @AgentCommissionEditedByExchangeRateSlider ModifierExchangeRateSlider
FOR XML PATH ('Transfer'),ROOT ('OriginDataType'))

--- Start a conversation:
BEGIN DIALOG @conversation
    FROM SERVICE [//Maxi/Transfer/OriginSenderService]
    TO SERVICE N'//Maxi/Transfer/OriginRecipService'
    ON CONTRACT [//Maxi/Transfer/OriginContract]
    WITH ENCRYPTION=OFF;

--- Send the message
SEND ON CONVERSATION @conversation
    MESSAGE TYPE [//Maxi/Transfer/OriginDataType]
    (@msg);

insert into dbo.SBSendOriginMessageLog (ConversationID,MessageXML) values (@conversation,@msg)

 -----------------------------------------------------------------------------------------------------------------                                                                
                                                                                          
 Set @HasError=0                                                          
 --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,6)                                                                                            
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')
                                       
End Try                                                                                            
Begin Catch        
  

  
                                                                                      
 Set @HasError=1                                                                                   
 --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,7)                                                                               
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreateTransfer',Getdate(),@ErrorMessage)                                                                                            
End Catch  
  



--ACTUALIZADO EN PROD EL DIA 25/06/2013 BY ARR.

