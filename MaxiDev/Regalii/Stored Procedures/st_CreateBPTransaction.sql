/********************************************************************
<Author>Unknow</Author>
<app>Agent</app>
<Description></Description>

<ChangeLog>
<log Date="2018/01/18" Author="azavala"> Optimizacion Agente : Se agregaron parametros de salida necesarios para la actualizacion de Customer en ElastiSearch</log>
<log Date="2020/07/20" Author="adominguez"> Info Adicional : Se agregan campos de info adicional para la transferencia y customer</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
********************************************************************/
CREATE procedure [Regalii].[st_CreateBPTransaction]
(
    @IdAgent int,

    @Amount money,
    @AmountInMN money,
    @ExRate money,
    @Fee money,
    --@TransactionFee money,
    --@Commission money,
    @CorpCommission money,
    @AgentCommission money,
    @TopUpBonusAmountReceived money,
	    
    @IdCustomer int,
    @IsSaveCustomer bit,    
    @CustomerName nvarchar(max),
    @CustomerFirstLastName nvarchar(max),
    @CustomerSecondLastName nvarchar(max),
    @CustomerCelularNumber nvarchar(max),
    @IdCarrier int,
	@City nvarchar(max),
	@State nvarchar(max),
	@ZipCode nvarchar(max),
	@Address nvarchar(max),

	@IdCustomerFrequentNumber int,
	@NickNameBeneficiary nvarchar(max),
	@BeneficiaryPhoneNumber nvarchar(max),
	@IdSchemaTopUp int,

    @IdBiller int,
    @Account_Number nvarchar(max),
    @IdCurrency int,
    @CurrencyName nvarchar(max),
    @Name_On_Account nvarchar(max),
    @Pos_Number nvarchar(max),

    @BillerName nvarchar(max),
    @Country nvarchar(max),
    @BillerType nvarchar(max),
    @CanCheckBalance bit,
    @SupportsPartialPayments bit,
    @RequiresNameOnAccount bit,
    @AvailableTopupAmounts nvarchar(max),
    @HoursToFulfill nvarchar(max),
    @LocalCurrency nvarchar(max),
    @AccountNumberDigits nvarchar(max),
    @Mask nvarchar(max),
    @BillType nvarchar(max),
	@TopUpCommissionPercentage money,
    @IdCountry int,
	@IdOtherProduct int,
    @TransactionExRate money = null,

    @EnterByIdUser int,
    @IdLenguage int,
    @IdCustomerOut int out,
    @IdProductTransferOut bigint out,
    @HasError bit out,                                                                                            
    @Message nvarchar(max) out,
	@idElasticCustomer varchar(max) out, /*Optimizacion Agente*/
	@Update bit out, /*Optimizacion Agente*/

	--Datos Info Adicional Customer
	@CustomerIdCustomerIdentificationType int = null,
	@CustomerSSNumber nvarchar(max),
	@TypeTaxId int = null,
	@HasTaxId bit,
	@HasDuplicatedTaxId bit,
    @CustomerBornDate datetime = null,
    @CustomerOccupation nvarchar(max)= '',

	@CustomerIdOccupation int = 0, /*M00207*/
	@CustomerIdSubcategoryOccupation int = 0,/*M00207*/
	@CustomerSubcategoryOccupationOther nvarchar(max) ='',/*M00207*/  
    @CustomerIdentificationNumber nvarchar(max)='',
    @CustomerExpirationIdentification datetime = null,
	@CustomerPhoneNumber nvarchar(max)='',
	@CustomerCelullarNumber nvarchar(max)='',
 --   @CustomerPurpose nvarchar(max),
 --   @CustomerRelationship nvarchar(max),
 --   @CustomerMoneySource nvarchar(max),
	@CustomerIdentificationIdCountry int = null,
    @CustomerIdentificationIdState int = null,
	@CustomerOccupationDetail nvarchar(max) = '',    
	--Datos OWB
	@OWBName nvarchar(max)='',
    @OWBFirstLastName nvarchar(max)='',
    @OWBSecondLastName nvarchar(max)='',
    @OWBAddress nvarchar(max)='',
    @OWBCity nvarchar(max)='',
    @OWBState nvarchar(max)='',
    @OWBZipcode nvarchar(max)='',
    @OWBPhoneNumber nvarchar(max)='',
    @OWBCelullarNumber nvarchar(max)='',
    @OWBSSNumber nvarchar(max)='',
    @OWBBornDate datetime = null,
    @OWBOccupation nvarchar(max)='',
	@OWBIdOccupation int = 0,/*M00207*/
	@OWBIdSubcategoryOccupation int = 0,/*M00207*/
	@OWBSubcategoryOccupationOther nvarchar(max) ='',/*M00207*/  

    @OWBIdentificationNumber nvarchar(max)='',
    @OWBIdCustomerIdentificationType int = null,
    @OWBExpirationIdentification datetime= null,
    @OWBPurpose nvarchar(max)='',
    @OWBRelationship nvarchar(max)='',
    @OWBMoneySource nvarchar(max)=''
)
as
Begin Try  
--Declaracion de variables
declare @BillerTypeCell varchar(500) = isnull(dbo.GetGlobalAttributeByName('RegaliiBillerTypeCell'),0)
declare @IdStatus int 
declare @IdAgentPaymentSchema int 
declare @IdProvider int = 5 --Regalii
declare @IdAgentBalanceService int =case when @BillerType!=@BillerTypeCell then 2 else 4 end --BillPayment--Top Ups
declare @TransactionDate datetime
declare @TransactionFee money = 0


--Inicializacion de variables
set @IdStatus=1 --Origin
Set @HasError=0
set @TransactionExRate = ISNULL(@TransactionExRate,0)
set @TransactionFee= case when @BillerType!=@BillerTypeCell then isnull(convert(money,dbo.GetGlobalAttributeByName('RegaliiFee')),0) else 0 end
set @CorpCommission=@CorpCommission-@TransactionFee
set @IdCarrier = case when @IdCarrier=0 then null else @IdCarrier end

if (@BillerType!=@BillerTypeCell and isnull(@IdCustomer,0)=0) or (@BillerType!=@BillerTypeCell and isnull(@IdCustomer,0)>0 and isnull(@IsSaveCustomer,0)=1)
	or (@BillerType=@BillerTypeCell and isnull(@IsSaveCustomer,0)=1)
begin
    
	declare @oldAddress nvarchar(max), @oldcity nvarchar(max), @oldstate nvarchar(max), @oldzip nvarchar(max), @oldphone nvarchar(max)
	
	if isnull(@IdCustomer,0)>0 BEGIN
	  select @oldAddress = Address, @oldcity =City, @oldstate = State, @oldzip =Zipcode, @oldphone = PhoneNumber from Customer where IdCustomer=@IdCustomer
	END 

    EXEC [dbo].[st_SaveCustomer]
		@IdCustomer = @IdCustomer OUTPUT,
		@IdAgentCreatedBy = @IdAgent,
		@Name = @CustomerName,
		@FirstLastName = @CustomerFirstLastName,
		@SecondLastName = @CustomerSecondLastName,
		@Address = @Address,
		@City = @City,
		@State = @State,
		@Zipcode = @ZipCode,
		@PhoneNumber = @oldphone,
		@CelullarNumber = @CustomerCelularNumber,
		@IdCarrier = @IdCarrier,
		@EnterByIdUser = @EnterByIdUser,

		@CustomerBornDate = @CustomerBornDate,
		@CustomerIdCustomerIdentificationType = @CustomerIdCustomerIdentificationType,
		@CustomerSSNumber = @CustomerSSNumber,
		@TypeTaxId = @TypeTaxId,
		@HasTaxId = @HasTaxId,
		@HasDuplicatedTaxId = @HasDuplicatedTaxId,
		@CustomerOccupation = @CustomerOccupation,
		@CustomerIdOccupation = @CustomerIdOccupation,
		@CustomerIdSubcategoryOccupation = @CustomerIdSubcategoryOccupation,
		@CustomerSubcategoryOccupationOther = @CustomerSubcategoryOccupationOther,
		@CustomerOccupationDetail = @CustomerOccupationDetail,
		@CustomerIdentificationNumber = @CustomerIdentificationNumber,
		@CustomerExpirationIdentification = @CustomerExpirationIdentification,
		@CustomerIdentificationIdCountry = @CustomerIdentificationIdCountry,
        @CustomerIdentificationIdState = @CustomerIdentificationIdState,
		@IdLenguage = @IdLenguage,
		@HasError = @HasError OUTPUT,
		@Update = @Update OUTPUT, /*Optimizacion Agente*/
		@idElasticCustomer = @idElasticCustomer OUTPUT, /*Optimizacion Agente*/
		@ResultMessage = @Message OUTPUT



end
else
begin
	set @Update = 0
end
set @IdCustomerOut=@IdCustomer /*Optimizacion Agente*/

Declare @IdOnWhoseBehalfOutput Int  , @TransactionDates datetime
set @TransactionDates = getdate()
                                                                                            
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
	   'USA',
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
	   @TransactionDates,
	   @EnterByIdUser,
	   @IdOnWhoseBehalfOutput OUTPUT;
End                                                                                            
Else                                                                                            
 Set @IdOnWhoseBehalfOutput=Null 

if (@HasError=1) return


if (@BillerType=@BillerTypeCell and @IdCustomerFrequentNumber is null and isnull(@IdCustomer,0)>0 and RTRIM(LTRIM(REPLACE(REPLACE(@NickNameBeneficiary,'(',''),')',''))) !='')
    begin 
        declare @IdCustomerFrequentNumberout int

        exec [TransFerTo].[st_SaveCustomerFrequentNumber]
		@IdCustomerFrequentNumber,
		@IdCustomer,
		@NickNameBeneficiary ,		
		@BeneficiaryPhoneNumber,
		@EnterByIdUser,
		@IdCustomerFrequentNumberout OUTPUT,
		@HasError OUTPUT       

        if @HasError=1 
        begin
            SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
            return
        end
                        
    end

  --calculos balance
             select @IdAgentPaymentSchema=IdAgentPaymentSchema from agent where idagent=@IdAgent
             declare @TotalAmountToCorporate money = 0
			 declare @Commission money = case when @BillerType=@BillerTypeCell then @AgentCommission+@CorpCommission else 0 end
IF( @BillerType=@BillerTypeCell)
	BEGIN
				 if (@IdAgentPaymentSchema=2)
					set @TotalAmountToCorporate =  @Amount-@AgentCommission
				 else
					set @TotalAmountToCorporate =  @Amount

                 if(@IdCustomer= 0)
					set @IdCustomer= null
	END
ELSE
	BEGIN
				if (@IdAgentPaymentSchema=2)
					set @TotalAmountToCorporate =  @Amount+@Fee-@AgentCommission
				 else
					set @TotalAmountToCorporate =  @Amount+@Fee
	END


set @TransactionDate = getdate()


    EXEC	[Operation].[st_CreateProductTransfer]
		@IdProvider = @IdProvider,
		@IdAgentBalanceService = @IdAgentBalanceService,
		@IdOtherProduct = @IdOtherProduct,
		@IdAgent = @IdAgent,
		@IdAgentPaymentSchema = @IdAgentPaymentSchema,
		@TotalAmountToCorporate = @TotalAmountToCorporate,
		@Amount = @Amount,
		@Commission = @Commission,
        @Fee = @Fee,
        @TransactionFee = @TransactionFee,
		@AgentCommission = @AgentCommission,
		@CorpCommission = @CorpCommission,
		@EnterByIdUser = @EnterByIdUser,
		@TransactionDate = @TransactionDate,
		@TransactionID = null,
		@HasError = @HasError OUTPUT,
		@IdProductTransferOut = @IdProductTransferOut OUTPUT

    if   @HasError=0             
    begin
        --insert

        INSERT INTO [Regalii].[TransferR]
                   ([IdAgent]
                   ,[IdAgentPaymentSchema]
                   ,[EnterByIdUser]
                   ,[DateOfCreation]
                   ,[EnterByIdUserCancel]
                   ,[DateOfCancel]
                   ,[IdStatus]
                   ,[IdProductTransfer]
                   ,[IdCustomer]
                   ,[CustomerName]
                   ,[CustomerFirstLastName]
                   ,[CustomerSecondLastName]
                   ,[CustomerCellPhoneNumber]
                   ,[IdCarrier]
                   ,[TotalAmountToCorporate]
                   ,[Amount]
                   ,[Commission]
                   ,[AgentCommission]
                   ,[CorpCommission]
                   ,[Fee]
                   ,[TransactionFee]
                   ,[ExRate]
                   ,[IdBiller]
                   ,[Account_Number]
                   ,[IdCurrency]
                   ,[CurrencyName]
                   ,[AmountInMN]
                   ,[Name_On_Account]
                   ,[Pos_Number]
                   --,[JsonRequest]
                   --,[ProviderId]
                   --,[Fx_Rate]
                   --,[Bill_Amount_Usd]
                   --,[Bill_Amount_Chain_Currency]
                   --,[Payment_Transaction_Fee]
                   --,[Payment_Total_Usd]
                   --,[Payment_Total_Chain_Currency]
                   --,[Chain_Earned]
                   --,[Chain_Paid]
                   --,[Starting_Balance]
                   --,[Ending_Balance]
                   --,[Discount]
                   --,[Sms_Text]
                   --,[ProviderDate]
                   --,[JsonResponse]
                   ,[Name]
                   ,[Country]
                   ,[BillerType]
                   ,[CanCheckBalance]
                   ,[SupportsPartialPayments]
                   ,[RequiresNameOnAccount]
                   ,[AvailableTopupAmounts]
                   ,[HoursToFulfill]
                   ,[LocalCurrency]
                   ,[AccountNumberDigits]
                   ,[Mask]
                   ,[BillType]
                   ,[IdCountry]
                   ,TransactionExRate
				   ,TopUpCommissionPercentage
				   ,TopUpBonusAmountReceived
                   ,IdSchema
				   ,IdOnWhoseBehalf)
             VALUES
                   (@IdAgent
                   ,@IdAgentPaymentSchema
                   ,@EnterByIdUser
                   ,@TransactionDate
                   ,null    --@EnterByIdUserCancel
                   ,null    --@DateOfCancel
                   ,@IdStatus
                   ,@IdProductTransferOut
                   ,@IdCustomer
                   ,@CustomerName
                   ,@CustomerFirstLastName
                   ,@CustomerSecondLastName
                   ,@CustomerCelularNumber
                   ,@IdCarrier
                   ,@TotalAmountToCorporate
                   ,@Amount
                   ,0
                   ,@AgentCommission
                   ,@CorpCommission
                   ,@Fee
                   ,@TransactionFee
                   ,@ExRate
                   ,@IdBiller
                   ,@Account_Number
                   ,@IdCurrency
                   ,@CurrencyName
                   ,@AmountInMN
                   ,@Name_On_Account
                   ,@Pos_Number
                   --,@JsonRequest
                   --,@ProviderId
                   --,@Fx_Rate
                   --,@Bill_Amount_Usd
                   --,@Bill_Amount_Chain_Currency
                   --,@Payment_Transaction_Fee
                   --,@Payment_Total_Usd
                   --,@Payment_Total_Chain_Currency
                   --,@Chain_Earned
                   --,@Chain_Paid
                   --,@Starting_Balance
                   --,@Ending_Balance
                   --,@Discount
                   --,@Sms_Text
                   --,@ProviderDate
                   --,@JsonResponse
                   ,@BillerName
                   ,@Country
                   ,@BillerType
                   ,@CanCheckBalance
                   ,@SupportsPartialPayments
                   ,@RequiresNameOnAccount
                   ,@AvailableTopupAmounts
                   ,@HoursToFulfill
                   ,@LocalCurrency
                   ,@AccountNumberDigits
                   ,@Mask
                   ,@BillType
                   ,@IdCountry
                   ,@TransactionExRate
				   ,@TopUpCommissionPercentage
				   ,@TopUpBonusAmountReceived
                   ,@IdSchemaTopUp
				   ,@IdOnWhoseBehalfOutput)
		declare @OperationDetailNote varchar(100) =case when @BillerType=@BillerTypeCell then 'Create Regalii Top Up Transaction' else 'Create Regalii BillPayment Transaction' end
         exec [Operation].[st_SaveChangesToProductTransferLog]
		        @IdProductTransfer = @IdProductTransferOut,
		        @IdStatus = 1,
		        @Note = @OperationDetailNote,
		        @IdUser = 0,
		        @CreateNote = 0

        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')
    end



End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Regalii.st_CreateBPTransaction',Getdate(),@ErrorMessage)                                                                                            
End Catch  
