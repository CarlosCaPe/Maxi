
CREATE PROCEDURE dbo.st_CreateTransfer
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
	@TypeTaxId int,
	@HasTaxId bit,
	@HasDuplicatedTaxId bit,
    @CustomerBornDate datetime,
    @CustomerOccupation nvarchar(max),
    @CustomerIdentificationNumber nvarchar(max),
    @CustomerExpirationIdentification datetime,
    @CustomerPurpose nvarchar(max),
    @CustomerRelationship nvarchar(max),
    @CustomerMoneySource nvarchar(max),
    @CustomerIdCarrier int,
	@CustomerIdOccupation int = 0, /*M00207*/
	@CustomerIdSubcategoryOccupation int = 0,/*M00207*/
	@CustomerSubcategoryOccupationOther nvarchar(max) =null,/*M00207*/
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
	@OWBIdOccupation int = 0,/*M00207*/
	@OWBIdSubcategoryOccupation int = 0,/*M00207*/
	@OWBSubcategoryOccupationOther nvarchar(max) =null,/*M00207*/
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
    @SSNRequired bit = null,
    @IsSaveCustomer bit = null,
    @SendMoneyAlertInvitation BIT = NULL,
    @IdCustomerCountryOfBirth Int = NULL,
    @IdBeneficiaryCountryOfBirth Int = NULL,
    @BeneficiaryBornDate datetime = NULL,
    @CustomerReceiveSms BIT = 0,
    @ReSendSms BIT = 0,
    @AccountTypeId INT = NULL
	,@IsModify bit = 0
	,@IdPreTransfer int = NULL

    ,@CustomerOccupationDetail nvarchar(max) = NULL /*S44:REQ. MA.025*/
    ,@TransferIdCity int = NULL
    ,@BeneficiaryIdCarrier int = NULL
	,@BranchCodePontual varchar(10) 	-- CR M00259	
	,@IdCustomerOutput int = null
	,@OnlineTransfer	BIT = 0,
	@IdTransferOriginal BIGINT = 0,
	@IdPaymentMethod	INT = 1,
	@Discount			MONEY = 0,
	@OperationFee		MONEY = 0,
	@isValidCustomerPhoneNumber	BIT = 0,
	@IdDialingCodePhoneNumber INT= NULL,
	@ClaimCode					VARCHAR(50) = NULL
	--,@BranchCodePontual nvarchar(max) = NULL	-- CR M00259								 							 
)                                                                                                        
As
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="2017/07/28" Author="mdelgado"> S32:: History Customer info Deposit AccountNumber by Payer</log>
<log Date="2017/10/31" Author="snevarez"> S44::REQ. MA.025 : Add detail for Other Occupations</log>
<log Date="2018/03/22" Author="snevarez"> S09::REQ. MA.008: Add PaymentType ATM(BBVA BANCOMER)</log>
<log Date="2018/05/08" Author="jmolina"> Cambio en validación de transferncias duplicadas, se incremento el tiempo entre transferencias y se agregaron los campos de IdCustomer, IdBeneficiary y AmountInDollar</log>
<log Date="2018/10/03" Author="jdarellano" Name="#1">Se aplica set de PayerCode para Banco Inmobiliario</log>
<log Date="2018/12/17" Author="jmolina" Name="">Se agrego nolock, ; por cada insert y/o update</log>
<log Date="2020/09/03" Author="jgomez" Name="">-- CR M00259	</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
<log Date="09/11/2020" Author="adominguez"> M00056 : Modificaciones</log>
<log Date="24/01/2022" Author="jcsierra">Add PosTransfer props</log>
<log Date="18/05/2022" Author="adominguez">Add Gateway CorpoUnidas</log>
<log Date="2022/03/8" Author="jcsierra">MP-889: Se agrega generacion de claimcode para el Gateway PIN4</log>
<log Date="2022/08/09" Author="jcsierra">SD1-2179: Se considera CaribeExpress para generacion de claimcode</log>
<log Date="2022/09/06" Author="maprado">SD1-2301: Se agrega - a claimcode para gateway pin4Cash</log>
<log Date="2022/09/09" Author="maprado">SD1-2358: Se agrega bandera @IsMonoUser y validacion para modificar transacciones de una agencia suspendida (solo multiAgente) </log>
<log Date="2022/09/14" Author="jcsierra" Name="#MP1276">SD1-2414, MP-1276: Se genera nuevo proceso de generacion de claimcodes</log>
<log Date="13/10/2022" Author="adominguez">Add CreateBankayaFolio Bankaya</log>
<log Date="14/10/2022" Author="adominguez">Add CreateBGuayaquilFolio Bankaya</log>
<log Date="17/10/2022" Author="adominguez">Add CreateJetPeruFolio JetPeru</log>
<log Date="10/11/2022" Author="adominguez">Add CreateEasyPagosFolio JetPeru</log>
<log Date="2022/12/07" Author="jcsierra">M1-530: Se agrega el @ClaimCode como parametro y se elimina la logica de creacion de claimcodes</log>
</ChangeLog>
********************************************************************/                                                                        
Set nocount on;
DECLARE @IsMonoUser BIT = 0
Declare @IdGatewayCorpoUnidas Int = 47 --Poner el id correspondiente a cada ambiente Dev =47,  Stage=48 , Prod = 47

--@OWBRuleType  0- No pidio Owbh, 1- Pidio y el dinero es suyo, 2- pidio y el dinero no es suyo                                                                     
Select  @HasError                                                                  
Declare @CustomerIdAgentCreatedBy  int                                                                                    
Set @CustomerIdAgentCreatedBy=@IdAgent                                                                                    
Declare @DateOfTransfer datetime                                                                                         
Declare @DateOfLastChange datetime                                                             
Set @DateOfTransfer=Getdate()                                                                                        
Set @DateOfLastChange=Getdate()    
Declare @DateOfTransferUTC datetime                                                             
Set @DateOfTransferUTC=GETUTCDATE()
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

if @IdBeneficiaryCountryOfBirth = 0
    set @IdBeneficiaryCountryOfBirth=null

if @IdCustomerCountryOfBirth = 0
    set @IdCustomerCountryOfBirth=null

IF @IdBeneficiary = 0 --#1
BEGIN
	SET @HasError=1
	SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('Info: st_CreateTransfer', GETDATE(),'Error por beneficiario no registrado, Parameters: IdCustomer: ' + CONVERT(VARCHAR, ISNULL(@IdCustomer, 0)) + ' IdBeneficiary: ' + CONVERT(VARCHAR,ISNULL(@IdBeneficiary, 0)) + ', IdAgent: ' + CONVERT(VARCHAR, ISNULL(@IdAgent, 0)) + ', Customer: ' + ISNULL(@CustomerName, 'UNK') + ' - ' + ISNULL(@CustomerFirstLastName, 'UNK') + ' - ' + ISNULL(@CustomerSecondLastName, 'UNK') + ', Beneficiary: ' + ISNULL(@BeneficiaryName, 'UNK') + ' - ' + ISNULL(@BeneficiaryFirstLastName, 'UNK') + ' - ' + ISNULL(@BeneficiarySecondLastName, 'UNK'));
	RETURN
END

Begin Try     
  
----------------------  Verify if @EnterByIdUser resend transfer in #time --------------------  

if @EnterByIdUser<>0  
Begin
Declare @DateOfTransfer2 Datetime, @IdCustomerVal int, @IdBeneficiaryVal Int, @AmountVal money

select top 1 @IdCustomerVal = IdCustomer, @IdBeneficiaryVal = IdBeneficiary, @AmountVal = AmountInDollars, @DateOfTransfer2 = DateOfTransfer from [dbo].[Transfer] with(nolock) where EnterByIdUser= @EnterByIdUser order by IdTransfer desc

 --If  (select top 1 DATEDIFF(second, DateOfTransfer, @dateNow) from [dbo].[Transfer] with(nolock) where EnterByIdUser= @EnterByIdUser order by IdTransfer desc) <= 30
 If (DATEDIFF(SECOND, @DateOfTransfer2, @dateNow) <= 30 AND @IdCustomer = @IdCustomerVal AND @IdBeneficiary = @IdBeneficiaryVal AND @AmountInDollars = @AmountVal AND @IsModify = 0)
  Begin  
   Set @HasError=1                                                                           
   --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,61)   
   SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE61')

   INSERT INTO Soporte.InfoLogForStoreProcedure (StoreProcedure, InfoDate, InfoMessage, ExtraData)
   VALUES ('st_CreateTransfer', GETDATE(), ISNULL(@Message, ''), 'IdUser: ' +CONVERT(varchar, @EnterByIdUser) + ', IdAgent: ' + CONVERT(varchar, @IdAgent) + ', IdCustomer: ' + CONVERT(varchar, @IdCustomer) + ', IdBeneficiary: ' + CONVERT(varchar, @IdBeneficiary) + ', AmountInDollar: ' + CONVERT(varchar, @AmountInDollars) );

   Return   
 End  
End  

/*if @EnterByIdUser<>0  
Begin  
 If  (select top 1 DATEDIFF(second, DateOfTransfer, @dateNow) from Transfer with(nolock) where EnterByIdUser= @EnterByIdUser order by IdTransfer desc) <= 5  
  Begin  
   Set @HasError=1                                                                           
   --Select @Message =dbo.GetMessageFromLenguajeResorces (@IsSpanishLanguage,61)   
   SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE61')
   Return   
 End  
End*/
  
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

IF EXISTS (SELECT 1 FROM AgentUser WITH (NOLOCK) WHERE IdUser = @EnterByIdUser)
	BEGIN
		SET @IsMonoUser = 1
	END

If exists (Select 1 from Agent with(nolock) where IdAgent=@IdAgent and (IdAgentStatus=2 or IdAgentStatus=3 or IdAgentStatus=5 or IdAgentStatus=6 or IdAgentStatus=7) AND (@IsMonoUser = 1))                                                           
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
  --Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage) values ('st_CreateTransfer',GETDATE(),' Y el IdPayer es '+CONVERT(Varchar,@IdPayer))
  Insert into Soporte.InfoLogForStoreProcedure(StoreProcedure,infoDate,InfoMessage) values ('st_CreateTransfer',GETDATE(),' Y el IdPayer es '+CONVERT(Varchar,@IdPayer));
    
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
if @isValidCustomerPhoneNumber	is Null Set @isValidCustomerPhoneNumber=''
--if @IdDialingCodePhoneNumber	is Null Set @IdDialingCodePhoneNumber=''
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
if @SendMoneyAlertInvitation IS NULL set @SendMoneyAlertInvitation = 0

--fix @DepositAccountNumber

--IdPaymentType	PaymentName
--    2		 DEPOSIT
--    5		 MOBILE WALLET
--    6		 ATM
set @DepositAccountNumber = case 
	when @IdPaymentType = 2 then @DepositAccountNumber
	when @IdPaymentType = 5 then @DepositAccountNumber
	when @IdPaymentType = 6 then @DepositAccountNumber /*MA_008*/
	else ''
	end

/*S44:REQ. MA.025 - Begin*/
if @CustomerOccupationDetail is Null Set @CustomerOccupationDetail='';  
if @TransferIdCity = 0 Set @TransferIdCity = NULL;
if @BeneficiaryIdCarrier = 0 Set @BeneficiaryIdCarrier = NULL;
/*S44:REQ. MA.025 - End*/                         
----------------------------------- Insert/Update Customer ----------------------------                                                                                            
Declare @IdCustomerElasticOutput varchar(max)      

if (@IdCustomer>0) and (@IsSaveCustomer=0) and not Exists (select 1 from customer with(nolock) where idcustomer=@IdCustomer and IdAgentCreatedBy=@IdAgent)
begin
    set @IsSaveCustomer=1
end    

declare @duplicate int = 0
if (@HasDuplicatedTaxId =1)
	set @duplicate = 1                                                                                        
                                                                                         
if (isnull(@IsSaveCustomer,0)=1)                                                                                          
begin
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
	   @CustomerIdOccupation , /*M00207*/
	   @CustomerIdSubcategoryOccupation,/*M00207*/
	   @CustomerSubcategoryOccupationOther,/*M00207*/
	   @CustomerIdentificationNumber,
	   0,
	   @DateOfTransfer,
	   @EnterByIdUser,
	   @CustomerExpirationIdentification,
	   @CustomerIdCarrier,
	   @CustomerIdentificationIdCountry ,
	   @CustomerIdentificationIdState ,
	   @AmountInDollars,
	   @IdCustomerCountryOfBirth,
	   @CustomerReceiveSms,
	   @ReSendSms,
	   @IdAgent,
	   @TypeTaxId ,
	   @duplicate ,
	   @HasTaxId ,
	   @CustomerOccupationDetail, /*S44:REQ. MA.025*/
	   @IdCustomerOutput Output,
	   @IdCustomerElasticOutput output,
	   @IdDialingCodePhoneNumber;
	   SET @IdCustomer = @IdCustomerOutput
end
else
begin
	IF @ReSendSms = 1
		EXEC [Infinite].[st_insertInvitationSms] @CelullarNumber = @CustomerCelullarNumber, @EnterByIdUser = @EnterByIdUser, @AgentId = @IdAgent, @InsertSms = @ReSendSms, @IdCustomer = @IdCustomer;
    SET @IdCustomerOutput=@IdCustomer
end                                                                                                                                               
                                                                                         
if (isnull(@IsSaveCustomer,0)=0)                                                                                          
BEGIN
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('dbo.st_CreateTransfer', GETDATE(),'IdCustomer: ' + convert(NVARCHAR(max), @IdCustomer));
	IF @ReSendSms = 1
		EXEC [Infinite].[st_insertInvitationSms] @CelullarNumber = @CustomerCelullarNumber, @EnterByIdUser = @EnterByIdUser, @AgentId = @IdAgent, @InsertSms = @ReSendSms, @IdCustomer = @IdCustomer;
end                                                                     
                                                                                            
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
	   @DateOfTransfer,
	   @EnterByIdUser,
	   @IdOnWhoseBehalfOutput OUTPUT;
End                                                                                            
Else                                                                                            
 Set @IdOnWhoseBehalfOutput=Null                                                                       
                                                                                            
                                                                                            
----------------------------------------------------------------------------------------------                                                                                

	DECLARE @Folio INT
	DECLARE @ConfirmationCode NVARCHAR(MAX)
	DECLARE @IdTransfer INT
	DECLARE @IdSeller INT
	DECLARE @Counter INT
                                                                                                                                                                                     
------------------------ Generador de Claim Code ---------------------------------------------------------------     
	CREATE TABLE #Result (Result NVARCHAR(MAX))

	--SET @ClaimCode=''
	SET @ConfirmationCode=''

	IF @IdGateway=3
	BEGIN
		DELETE #Result
		INSERT INTO #Result (Result)
		EXECUTE DBO.ST_TNC_CONF_CODE_GEN '01', '01', @CustomerName, @BeneficiaryName, @BeneficiaryFirstLastName, @BeneficiarySecondLastName, @AmountInMN;
		SELECT @ConfirmationCode = LTRIM(RTRIM(Result)) FROM #Result
	END
	ELSE
		SET @ConfirmationCode = ''

	DECLARE @PayerCode NVARCHAR(MAX)                                                                                          
	SELECT @PayerCode=PayerCode FROM Payer WITH(NOLOCK) WHERE IdPayer=@IdPayer

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
	   [CustomerIdOccupation],  /*M00207*/
	   [CustomerIdSubOccupation],  /*M00207*/
	   [CustomerSubOccupationOther], /*M00207*/
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
	   BeneficiaryIdentificationNumber,
	   CustomerIdCountryOfBirth,
	   BeneficiaryIdCountryOfBirth,
	   BeneficiaryBornDate,
	   [AccountTypeId]

	   ,CustomerOccupationDetail /*S44:REQ. MA.025*/
	   ,TransferIdCity
	   ,BeneficiaryIdCarrier
	   ,[BranchCodePontual] -- CR M00259
	   ,DateOfTransferUTC,
	   IdPaymentMethod,
	   Discount,
	   OperationFee,
	   isValidCustomerPhoneNumber,
	   IdDialingCodePhoneNumber
    )
    VALUES
    (
	   @IdCustomer ,
	   @IdBeneficiary ,
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
	   @CustomerIdOccupation , /*M00207*/
	   @CustomerIdSubcategoryOccupation,/*M00207*/
	   @CustomerSubcategoryOccupationOther,/*M00207*/
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
	   @BeneficiaryIdentificationNumber,
	   @IdCustomerCountryOfBirth ,
	   @IdBeneficiaryCountryOfBirth,
	   @BeneficiaryBornDate,
	   @AccountTypeId

	   ,@CustomerOccupationDetail /*S44:REQ. MA.025*/
	   ,@TransferIdCity
	   ,@BeneficiaryIdCarrier
	   ,@BranchCodePontual -- CR M00259
	   ,@DateOfTransferUTC,
	   @IdPaymentMethod,
	   @Discount,
	   @OperationFee,
	   @isValidCustomerPhoneNumber,
	   @IdDialingCodePhoneNumber 
    );

Select @IdTransfer=SCOPE_IDENTITY();

----------------------- S32 INSERT INFO TRANSFER CUSTOMER AND ACCOUNNUMBER OF DEPOSIT BY PAYER ------------

	EXEC st_saveTransferCustomerInfoByPayer	@IdCustomer, @IdPayer, @IdBeneficiary, @DepositAccountNumber;
                                                                     
------------------------- Insert Broken Rules -------------------------------------------------------------------                                                                                            
                                                                                            
Declare @HasErrorBrokenRules bit                                                                                            
EXEC st_InsertBrokenRulesByTransfer @IdTransfer,@XmlRules,@OWBRuleType,@HasError=@HasErrorBrokenRules Output;                                        
If @HasErrorBrokenRules=1                                                                                            
 Select 1/0                                                                                

                                                        
------------------------------------------------------------------------------------------------------------------                                                
 Set @IdTransferOutput=@IdTransfer    
 
 if(isnull(@SSNRequired,0)=1)
 begin
    insert into [TransferSSN] values (@IdTransfer,1,getdate());
 end   
  --Para modificaciones
 if @IsModify = 1
BEGIN
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) 
	VALUES('st_CreateTransfer', GETDATE(), 'Debug - Parameters: IdTransfer: ' + CONVERT(VARCHAR(20),@IdTransfer)+ ', IsModify: ' + CONVERT(VARCHAR(20),@IsModify) + ', IdPreTransfer:' + CONVERT(VARCHAR(20),@IdPreTransfer));

	DECLARE @OldIdTans INT
	DECLARE @OldIdStatus INT
	DECLARE @OldTransfer BIGINT = ISNULL(@IdTransferOriginal, @IdPreTransfer)
	
	--if exists (Select 1 from PreTransfer with(nolock) where IdPreTransfer = @IdPreTransfer)
	--Begin
	--	Select @OldIdTans = IdTransfer from PreTransfer with(nolock) where IdPreTransfer = @IdPreTransfer
	--	Select @OldIdStatus= IdStatus from [Transfer] with(nolock) where IdTransfer = @OldIdTans
	--end
	--Else
	--Begin
	--	Select @OldIdStatus= IdStatus from [Transfer] with(nolock) where IdTransfer = @IdPreTransfer
	--	set @OldIdTans = @IdPreTransfer
	--End

	UPDATE TransferModify SET NewIdTransfer = @IdTransferOutput WHERE OldIdTransfer = @OldTransfer
	--Insert into TransferModify (OldIdTransfer,NewIdTransfer,CreatedBy,CreateDate,OldIdStatus,IsCancel) values(@OldIdTans, @IdTransferOutput, @EnterByIdUser, GETDATE(),@OldIdStatus, 0)

	DECLARE @OriginalTransferNote VARCHAR(200)

	SELECT 
		@OriginalTransferNote = CONCAT('The transaction has a modification, Folio #', t.Folio)
	FROM Transfer t WITH (NOLOCK)
	WHERE t.IdTransfer = @IdTransferOutput

	EXEC st_SimpleAddNoteToTransfer @OldTransfer, @OriginalTransferNote
END

 

IF ISNULL(@OnlineTransfer, 0) = 0
BEGIN
	--service broker
	-----------------------------------------------------------------------------------------------------------------
	 declare @Country nvarchar(max)

	 select @Country=c.CountryCode from countrycurrency  cc with(nolock)
	 join country c with(nolock) on cc.IdCountry=c.IdCountry
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
		@AgentCommissionEditedByExchangeRateSlider ModifierExchangeRateSlider,

		@IdTransferResend IdTransferResend,
		@DateOfTransfer DateOfTransfer,
		@StateTax StateTax
	FOR XML PATH ('Transfer'),ROOT ('OriginDataType'))

	INSERT INTO [dbo].[SBMessageLog] ([IdTransfer],[MessageXML]) values (@IdTransfer, @msg);

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

	insert into dbo.SBSendOriginMessageLog (ConversationID,MessageXML,[IdTransfer]) values (@conversation,@msg,@IdTransfer);

	 -----------------------------------------------------------------------------------------------------------------                                                                
END
   
 Set @HasError=0                                                                                                                                                    
 SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')

--- Send Money Alert Invitation
--IF @SendMoneyAlertInvitation = 1
--BEGIN
--	DECLARE @InvitationHasError BIT, @InvitationMessage NVARCHAR(MAX), @IsSpanishLanguage BIT, @CountryCode NVARCHAR(MAX)
--	SET @CountryCode = [dbo].[GetGlobalAttributeByName]('MoneyAlertCountryCode')
--	IF @IdLenguage = 1 SET @IsSpanishLanguage = 0
--	EXEC [MoneyAlert].[st_InvitationProcessing]
--		@IdCustomer
--		, @CountryCode
--		, @CustomerCelullarNumber
--		, @CustomerIdCarrier
--		, @IsSpanishLanguage
--		, @EnterByIdUser
--		, @InvitationHasError OUTPUT
--		, @InvitationMessage OUTPUT
--END

END TRY
BEGIN CATCH                                                                           
	SET @HasError=1
	SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
	DECLARE @ErrorMessage NVARCHAR(MAX)
	SELECT @ErrorMessage=ERROR_MESSAGE()
	INSERT INTO [dbo].[ErrorLogForStoreProcedure] ([StoreProcedure], [ErrorDate], [ErrorMessage]) VALUES('st_CreateTransfer' ,GETDATE(), @ErrorMessage + 'Parameters: IdCustomer: '+ CONVERT(VARCHAR,@IdCustomer)+ ' IdBeneficiary: ' + CONVERT(VARCHAR,@IdBeneficiary) + ' l;'+CONVERT(VARCHAR,ERROR_LINE()) + ' PAYER: ' + CONVERT(VARCHAR, @PayerCode));
END CATCH

