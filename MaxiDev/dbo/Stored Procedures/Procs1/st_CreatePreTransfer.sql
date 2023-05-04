CREATE PROCEDURE [dbo].[st_CreatePreTransfer]
(                                                                                            
    @IdLenguage int,
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
	@TypeTaxId int,
	@HasTaxId bit,
	@HasDuplicatedTaxId bit,                                                              
    @CustomerBornDate datetime,                                                       
    @CustomerOccupation nvarchar(max),
	@CustomerIdOccupation int = 0, /*M00207*/
	@CustomerIdSubcategoryOccupation int = 0,/*M00207*/
	@CustomerSubcategoryOccupationOther nvarchar(max) =null,/*M00207*/                                                     
    @CustomerIdentificationNumber nvarchar(max),                                                           
    @CustomerExpirationIdentification datetime,                                                          
    @CustomerPurpose nvarchar(max),                                                                                            
    @CustomerRelationship nvarchar(max),                                                                                            
    @CustomerMoneySource nvarchar(max),                                                                          
    @CustomerIdCarrier int,
    @XmlRules xml,
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
	@OWBIdOccupation int = 0,/*M00207*/
	@OWBIdSubcategoryOccupation int = 0,/*M00207*/
	@OWBSubcategoryOccupationOther nvarchar(max) =null,/*M00207*/                                                                                           
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
    @IdTransferResend int = null,
    @TransferAmount Money,
    @IdBeneficiaryIdentificationType int,
    @BeneficiaryIdentificationNumber nvarchar(max),
    @HasError bit out,
    @Message varchar(max) out,
    @IdPreTransferOutput int output,
    @IdCustomerOutput int output,
    @SSNRequired bit = null,
    @IsSaveCustomer bit = null,
    @IdCustomerCountryOfBirth int = null,
    @IdBeneficiaryCountryOfBirth int = null,
    @BeneficiaryBornDate datetime = NULL,
    @CustomerReceiveSms BIT = 0,
    @ReSendSms BIT = 0,
    @AccountTypeId INT = NULL,
	@IsModifyPre bit = 0

    ,@CustomerOccupationDetail nvarchar(max) = NULL /*S44:REQ. MA.025*/
    ,@TransferIdCity int = NULL
    ,@BeneficiaryIdCarrier int = NULL
	,@idElasticCustomer varchar(max) output /*Optmizacion Agente*/
	,@IdBeneficiaryOutput int output /*Optmizacion Agente*/
	,@cardVip varchar(max) = null output /*Optmizacion Agente*/
)
As
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/07/28" Author="mdelgado"> S32:: History Customer info Deposit AccountNumber by Payer</log>
<log Date="2017/10/30" Author="snevarez"> S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="2018/01/18" Author="azavala"> Optimizacion Agente : Se agregaron parametros de salida necesarios para la actualizacion de Customer en ElastiSearch</log>
<log Date="2018/05/08" Author="jmolina"> Cambio en validación de transferncias duplicadas, se incremento el tiempo entre transferencias y se agregaron los campos de IdCustomer, IdBeneficiary y AmountInDollar</log>
<log Date="19/12/2018" Author="jmolina">Add with(nolock) and ; en cada insert/update</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
<log Date="2022/09/09" Author="maprado"  Name="Agent">Se agrega bandera @IsMonoUser y validacion para modificar transacciones de una agencia suspendida (solo multiAgente) </log>
</ChangeLog>
********************************************************************/
Set nocount on    
--@OWBRuleType  0- No pidio Owbh, 1- Pidio y el dinero es suyo, 2- pidio y el dinero no es suyo                                                                     
Select  @HasError
Declare @CustomerIdAgentCreatedBy  int
Set @CustomerIdAgentCreatedBy=@IdAgent
Declare @DateOfPreTransfer datetime
Declare @DateOfLastChange datetime
Set @DateOfPreTransfer=Getdate()
Set @DateOfLastChange=Getdate()
Declare @CustomerCountry nvarchar(max)
Set  @CustomerCountry='USA'
Declare @OWBCountry nvarchar(max)
Set   @OWBCountry ='USA'
Declare @BeneficiaryNote nvarchar(max)
Set  @BeneficiaryNote=''
declare @dateNow Datetime
set @dateNow= GETDATE()  

DECLARE @IsMonoUser BIT = 0

--EXEC soporte.st_logExecuteSP @@SPID, @@PROCID

if @IdLenguage is null 
    set @IdLenguage=2


if @IdBeneficiaryCountryOfBirth = 0
    set @IdBeneficiaryCountryOfBirth=null

if @IdCustomerCountryOfBirth = 0
    set @IdCustomerCountryOfBirth=null



Begin Try     

----------------------  Verify if @EnterByIdUser resend PreTransfer in #time --------------------  
if @EnterByIdUser<>0  
Begin  

Declare @DateOfTransfer2 Datetime, @IdCustomerVal int, @IdBeneficiaryVal Int, @AmountVal money

select top 1 @IdCustomerVal = IdCustomer, @IdBeneficiaryVal = IdBeneficiary, @AmountVal = AmountInDollars, @DateOfTransfer2 = DateOfPreTransfer from [dbo].[PreTransfer] with(nolock) where EnterByIdUser= @EnterByIdUser order by IdTransfer desc

 --If  (select top 1 DATEDIFF(second, DateOfPreTransfer, @dateNow) from PreTransfer with(nolock) where EnterByIdUser= @EnterByIdUser order by IdPreTransfer desc) <= 5  
 If (DATEDIFF(SECOND, @DateOfTransfer2, @dateNow) <= 30 AND @IdCustomer = @IdCustomerVal AND @IdBeneficiary = @IdBeneficiaryVal AND @AmountInDollars = @AmountVal and @IsModifyPre = 0)
  Begin  
   Set @HasError=1                                                                           
   --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,68)   
   SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE68')

   INSERT INTO Soporte.InfoLogForStoreProcedure (StoreProcedure, InfoDate, InfoMessage, ExtraData)
   VALUES ('st_CreatePreTransfer', GETDATE(), ISNULL(@Message, ''), 'IdUser: ' +CONVERT(varchar, @EnterByIdUser) + ', IdAgent: ' + CONVERT(varchar, @IdAgent) + ', IdCustomer: ' + CONVERT(varchar, @IdCustomer) + ', IdBeneficiary: ' + CONVERT(varchar, @IdBeneficiary) + ', AmountInDollar: ' + CONVERT(varchar, @AmountInDollars) );

   Return   
 End  
End    
  
----------  Special case when Agent is disable ------------------------------                        

IF EXISTS (SELECT 1 FROM AgentUser WITH (NOLOCK) WHERE IdUser = @EnterByIdUser)
BEGIN
	SET @IsMonoUser = 1
END

If exists (Select 1 from Agent with(nolock) where IdAgent=@IdAgent and (IdAgentStatus=2 or IdAgentStatus=3 or IdAgentStatus=5 or IdAgentStatus=6 or IdAgentStatus=7) AND (@IsMonoUser = 1))                   
Begin                                                          
    Set @IdPreTransferOutput=0                                                        
    Set @HasError=1                                                                                            
        --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,29)                                                   
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE29')
    Return                                                          
End

if not exists(select idpayer from branch with(nolock) where idbranch=@IdBranch)
begin
    set @IdBranch=null
end 

----- Special case when Idbranch is null but PreTransfer is cash ----------------                                                            
If (@IdBranch is null and (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2 OR  @IdPaymentType=5))                                                            
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
  
If (@IdBranch is null and (@IdPaymentType=1 or @IdPaymentType=4 or @IdPaymentType=2 or @IdPaymentType=5))                                                            
Begin                                 
  Select top 1 @IdBranch=IdBranch from Branch with(nolock) where IdPayer=@IdPayer and (IdGenericStatus=1 or IdGenericStatus is null)  order by IdBranch                                                       
  Select @GatewayBranchCode=GatewayBranchCode from GatewayBranch with(nolock) where IdBranch=@IdBranch   
    Insert into Soporte.InfoLogForStoreProcedure(StoreProcedure,InfoDate,InfoMessage) values ('st_CreatePreTransfer',GETDATE(),' Y el IdPayer es '+CONVERT(Varchar,@IdPayer));  
    
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
if @CustomerSubcategoryOccupationOther IS NULL Set @CustomerSubcategoryOccupationOther=''                                                                                    
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
if @OWBSubcategoryOccupationOther IS NULL Set @OWBSubcategoryOccupationOther=''                                                                                        
if @OWBIdentificationNumber  is Null Set @OWBIdentificationNumber=''                                                                                      
if @OWBPurpose  is Null Set @OWBPurpose=''                                                                                      
if @OWBRelationship  is Null Set @OWBRelationship=''                                                                                      
if @OWBMoneySource  is Null Set @OWBMoneySource=''         

/*S44:REQ. MA.025 - Begin*/
if @CustomerOccupationDetail is Null Set @CustomerOccupationDetail='';  
if @TransferIdCity = 0 Set @TransferIdCity = NULL;
if @BeneficiaryIdCarrier = 0 Set @BeneficiaryIdCarrier = NULL;
/*S44:REQ. MA.025 - End*/

----------------------------------- Insert/Update Customer ----------------------------
--Declare @IdCustomerOutput INT

if (@IdCustomer>0) and (@IsSaveCustomer=0) and not Exists (select 1 from customer with(nolock) where idcustomer=@IdCustomer and IdAgentCreatedBy=@IdAgent)
--if not Exists (select top 1 1 from customer with(nolock) where idcustomer=@IdCustomer and IdAgentCreatedBy=@IdAgent)
begin
    set @IsSaveCustomer=1
end

declare @duplicate int = 0
if (@HasDuplicatedTaxId =1)
	set @duplicate = 1   

if (@IsSaveCustomer=1)
begin
    EXEC [dbo].[st_InsertCustomerByTransfer]
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
	   @CustomerIdOccupation , /*M00207*/
	   @CustomerIdSubcategoryOccupation,/*M00207*/
	   @CustomerSubcategoryOccupationOther,/*M00207*/
	   @CustomerIdentificationNumber,
	   0,
	   @DateOfPreTransfer,
	   @EnterByIdUser,
	   @CustomerExpirationIdentification,
	   @CustomerIdCarrier,
	   @CustomerIdentificationIdCountry,
	   @CustomerIdentificationIdState ,
	   0,
	   @IdCustomerCountryOfBirth,
	   @CustomerReceiveSms,
	   @ReSendSms,
	   @IdAgent,
	   @TypeTaxId ,
	   @duplicate ,
	   @HasTaxId ,
	   @CustomerOccupationDetail /*S44:REQ. MA.025*/

	   ,@IdCustomerOutput output
	   ,@idElasticCustomer output

	   set @cardVip = isnull((Select top 1 CardNumber from CardVIP with (nolock) where IdCustomer = @IdCustomerOutput),'')
	   set @IdCustomer=@IdCustomerOutput--#1
	   
end
else
begin
	set @idElasticCustomer = (Select top 1 idElasticCustomer from Customer with (nolock) where IdCustomer = @IdCustomer)
	set @cardVip = isnull((Select top 1 CardNumber from CardVIP with (nolock) where IdCustomer = @IdCustomer),'')
	IF @ReSendSms = 1
		EXEC [Infinite].[st_insertInvitationSms] @CelullarNumber = @CustomerCelullarNumber, @EnterByIdUser = @EnterByIdUser, @AgentId = @IdAgent, @InsertSms = @ReSendSms
    SET @IdCustomerOutput=@IdCustomer
end

----------------------------------- Insert/Update Beneficiary ----------------------------                    
--Declare @IdBeneficiaryOutput INT                                                             
                                                                                            
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
@BeneficiaryBornDate,                                                                                              
'',                                                                                              
@BeneficiaryNote,                                                                                              
1,                                           
@DateOfPreTransfer,                                                                       
@EnterByIdUser,    
@IdBeneficiaryIdentificationType,     
@BeneficiaryIdentificationNumber,          
@IdBeneficiaryCountryOfBirth,                                                                                   
@IdBeneficiaryOutput Output                                                                                            
                                                                                            
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
  @OWBIdOccupation ,/*M00207*/
  @OWBIdSubcategoryOccupation ,/*M00207*/
  @OWBSubcategoryOccupationOther,/*M00207*/                                                                                            
  @OWBIdentificationNumber,                                                                                      
  0,                                                                                        
  @OWBIdCustomerIdentificationType,                                                                             
  @OWBExpirationIdentification,   
  @OWBPurpose,                                                                                            
  @OWBRelationship,                                                                                            
  @OWBMoneySource,                                                                                            
  @DateOfPreTransfer,                                         
  @EnterByIdUser,                                                                                            
  @IdOnWhoseBehalfOutput OUTPUT                                       
End                                                                                            
Else                                                                                            
 Set @IdOnWhoseBehalfOutput=Null  
                                                                                            
----------------------------------------------------------------------------------------------                                                                                
                                        
Declare @Folio int
Declare @IdPreTransfer Int
Declare @IdSeller INT

-------------------------- Incremente de Folio por Agencia -----------------------------------------------------                                                                                            


--Update dbo.Agent Set PreFolio=PreFolio+1, @Folio=PreFolio+1  Where IdAgent=@IdAgent
 if not exists(select 1 from [AgentFolioPreFolio] with(nolock) where idagent=@IdAgent)
 begin
    insert into [AgentFolioPreFolio] (idagent,folio,prefolio) values (@IdAgent,0,0);
 end

Update dbo.[AgentFolioPreFolio] Set PreFolio=PreFolio+1, @Folio=PreFolio+1  Where IdAgent=@IdAgent;

--------------------------- Select IDSeller  --------------------------------------------------------------------                                                                                            
Select @IdSeller=isnull(IdUserSeller,1) from Agent with(nolock) where IdAgent=@IdAgent                                                                
-----------------------------------------------------------------------------------------------------------------                                                                
                                                                           
INSERT INTO [PreTransfer]                                                                                              
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
   --IdStatus,                                                   
   --ClaimCode,                                                                    
   --ConfirmationCode,                                                                                            
   AmountInDollars,                                                                                
   Fee,                                                                                            
   AgentCommission,                                                                                            
   CorporateCommission,                                                                                          
   DateOfPreTransfer,                                                                           
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
   [CustomerIdOccupation],
   [CustomerIdSubOccupation],
   [CustomerSubOccupationOther],                                                                        
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
   BrokenRules,
   IdCity,
   StateTax,
   OWBRuleType,
   IdTransferResend,
   TransferAmount,
   IdBeneficiaryIdentificationType,     
   BeneficiaryIdentificationNumber,
   CustomerIdCountryOfBirth,
   BeneficiaryIdCountryOfBirth,
   BeneficiaryBornDate,
   [AccountTypeId]

   ,CustomerOccupationDetail /*S44:REQ. MA.025*/
   ,TransferIdCity
   ,BeneficiaryIdCarrier
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
    --1,                                                                  
    --@ClaimCode,                                                     
    --@ConfirmationCode ,                                                                          
    @AmountInDollars ,
    @Fee ,
    @AgentCommission ,
    @CorporateCommission ,
    @DateOfPreTransfer ,
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
    @CustomerPhoneNumber,
    @CustomerCelullarNumber,
    @CustomerSSNumber,
    @CustomerBornDate,
    @CustomerOccupation,
	@CustomerIdOccupation , /*M00207*/
	@CustomerIdSubcategoryOccupation,/*M00207*/
	@CustomerSubcategoryOccupationOther,/*M00207*/
    @CustomerIdentificationNumber,
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
    @NoteAdditional,
    @CustomerIdentificationIdCountry,
    @CustomerIdentificationIdState,
    ISNULL(@XmlRules,''),
    @IdCity,
    @StateTax,
    @OWBRuleType,
    @IdTransferResend,
    @TransferAmount,
    @IdBeneficiaryIdentificationType,     
    @BeneficiaryIdentificationNumber,
    @IdCustomerCountryOfBirth,
    @IdBeneficiaryCountryOfBirth,
    @BeneficiaryBornDate,
    @AccountTypeId

    ,@CustomerOccupationDetail /*S44:REQ. MA.025*/
    ,@TransferIdCity
    ,@BeneficiaryIdCarrier
)                                                                                              
                                                                                             
 Select @IdPreTransfer=SCOPE_IDENTITY();                                                                                            


----------------------- S32 INSERT INFO TRANSFER CUSTOMER AND ACCOUNNUMBER OF DEPOSIT BY PAYER ------------

	EXEC st_saveTransferCustomerInfoByPayer	@IdCustomerOutput, @IdPayer,  @IdBeneficiaryOutput, @DepositAccountNumber;
	                                                                     
---------------------------- State Tax --------------------------------------------------------------------------                                                                    
--If @StateTax>0                                                                    
--Begin                                             
                   
-- Insert into StateFee (State,Tax,IdPreTransfer)                                                                    
-- Select AgentState,@StateTax,@IdPreTransfer from Agent Where IdAgent=@IdAgent                   
                  
-- Declare @FeeNote nvarchar(max), @FeeReference nvarchar(max), @SateName nvarchar(max),@StateFeeHasError bit,@StateFeeMessage nvarchar(max)                      
-- Select top 1 @SateName=StateName  from ZipCode where StateCode=(Select AgentState from Agent Where IdAgent=@IdAgent )                  
-- Select @FeeNote=@SateName+' State Fee, Folio:'+CONVERT(varchar(max),Folio), @FeeReference=CONVERT(varchar(max),Folio) From PreTransfer where IdPreTransfer=@IdPreTransfer                                                  
                   
-- Exec st_SaveOtherCharge 1,@IdAgent,@StateTax,1,@DateOfPreTransfer,@FeeNote,@FeeReference,@EnterByIdUser,@HasError=@StateFeeHasError Output,@Message=@StateFeeMessage                     
                                                                    
--End                                                                    
                                                                                            
------------------------- Validar Broken Rules -------------------------------------------------------------------                                                                                            
Begin Try
Declare @DocHandle int
    EXEC sp_xml_preparedocument @DocHandle OUTPUT, @XmlRules
    EXEC sp_xml_removedocument @DocHandle
End Try
Begin Catch
 Set @HasError=1
 Select 1/0
End Catch
                                                                                            
------------------------------------------------------------------------------------------------------------------                                                
 Set @IdPreTransferOutput=@IdPreTransfer
 
 if(isnull(@SSNRequired,0)=1)
 begin
    insert into [PreTransferSSN] values (@IdPreTransfer,1,getdate());
 end
                                                                        
                                                                                          
 Set @HasError=0                                                          
 set @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE69')                                                                                    
 SELECT @Message, @idElasticCustomer
                                       
End Try                                                                                            
Begin Catch
 Set @HasError=1                                                                                   
 --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,70)                                                                               
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE70')
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select  @ErrorMessage=ERROR_MESSAGE()                                             
	DECLARE @CustomerOrCustomerOut varchar(250)
	DECLARE @BenificiaryOrBenificiaryOut varchar(250)
	SET @CustomerOrCustomerOut = CASE WHEN (@IdCustomer = 0 OR @IdCustomer IS NULL) AND @IdCustomerOutput > 0 THEN ' IdCustomerOutput: ' + CONVERT(VARCHAR, @IdCustomerOutput) ELSE ' IdCustomer: ' + CONVERT(VARCHAR, @IdCustomer) END
	SET @BenificiaryOrBenificiaryOut = CASE WHEN (@IdBeneficiary = 0 OR @IdBeneficiary IS NULL) AND @IdBeneficiaryOutput > 0 THEN ' IdBeneficiaryOutput: ' + CONVERT(VARCHAR, @IdBeneficiaryOutput) ELSE ' IdBeneficiary: ' + CONVERT(VARCHAR, @IdBeneficiary) END
	Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CreatePreTransfer : ' + @CustomerOrCustomerOut + ', ' + @BenificiaryOrBenificiaryOut + ', IdAgent: ' + CONVERT(VARCHAR, @IdAgent) + ', Folio ' + CONVERT(VARCHAR, ISNULL(@Folio, 0)) + ', Customer: ' + ISNULL(@CustomerName, 'UNK') + ' - ' + ISNULL(@CustomerFirstLastName, 'UNK') + ' - ' + ISNULL(@CustomerSecondLastName, 'UNK') + ', line: ' + CONVERT(VARCHAR,ERROR_LINE()),Getdate(),@ErrorMessage);
End Catch
