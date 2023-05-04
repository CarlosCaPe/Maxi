
CREATE procedure [BillPayment].[st_UpdateBillPaymentTrans]
(
	@IdProductTransfer int,
    @IdAgent int,
    @IdAggregator  int,
    @Amount money,
    @AmountInMN money,
    @ExRate money,
    @Fee money,
    @CorpCommission money,
    @AgentCommission money,
    @TransactionFee money,    
    @IdCustomer int,
    @IsSaveCustomer bit,    
    @CustomerName nvarchar(max),
    @CustomerFirstLastName nvarchar(max),
    @CustomerSecondLastName nvarchar(max),
    @CustomerCelularNumber nvarchar(max),
    @Address nvarchar(max),
    @ZipCode nvarchar(max),
    @City nvarchar(max),
    @State nvarchar(max),
    @IdCustomerFrequentNumber int =null,
    @NickNameBeneficiary nvarchar(max) = null,
    @BeneficiaryPhoneNumber nvarchar(max) = null,
    @IdSchemaTopUp int =null,
    @IdBiller int,
    @Account_Number nvarchar(max),   
    @EnterByIdUser int,
    @IdLenguage int,
    @HasError bit out,
    @Message nvarchar(max) out,
    @TransactionExRate money = null,
	@ZipBiller varchar(max),
	@IdCarrier int = null
)

/********************************************************************
<Author>azavala</Author>
<app>New Agent</app>
<Description>Update a Tranfer for BillPayment when this has an update after fix information to complete the transaction </Description>

<ChangeLog>
<log Date="2019-03-16" Author="azavala"> Creacion  </log>
</ChangeLog>

*********************************************************************/
as
Begin Try

    declare 
    @IdCurrency int
    , @CurrencyName nvarchar(max)
    , @Name_On_Account nvarchar(max)
    , @Pos_Number nvarchar(max)
    , @BillerName nvarchar(max)
    , @Country nvarchar(max)
    , @BillerType nvarchar(max)
    , @CanCheckBalance bit
    , @SupportsPartialPayments bit
    , @RequiresNameOnAccount bit
    , @AvailableTopupAmounts nvarchar(max)
    , @HoursToFulfill nvarchar(max)
    , @LocalCurrency nvarchar(max)
    , @AccountNumberDigits nvarchar(max)
    , @Mask nvarchar(max)
    , @BillType nvarchar(max)
    , @TopUpCommissionPercentage money
    , @IdCountry int
    , @IdOtherProduct int
    -- , @TransactionExRate money 
    , @IdStatusActivo int
    , @isDomestic bit

	 set @IdStatusActivo= 1
	 set @Name_On_Account= ''
	 set @CanCheckBalance = 0
	 set @SupportsPartialPayments = 0
	 set @RequiresNameOnAccount = 0
	 set @AvailableTopupAmounts= 0
	 set @HoursToFulfill = ''
	 set @Mask =''
	 set @TopUpCommissionPercentage=0
	 set @TransactionExRate = ISNULL(@TransactionExRate,0)
	 set @AccountNumberDigits=''
  
      select 
        @BillerName	= B.Name       
       , @BillerType= B.CategoryAggregator
       , @BillType 	= B.CategoryAggregator
       , @isDomestic= B.isDomestic
      from 
       BillPayment.Billers as B with (nolock)
      where 
       Idbiller= @IdBiller
       and IdStatus= @IdStatusActivo

	   set   @IdOtherProduct = (select O.IdOtherProducts from BillPayment.Aggregator as O with (nolock) where  O.IdAggregator = @IdAggregator )

	   set   @IdCurrency = (case 
         										 when @isDomestic=1
         										 then
								1
							 end
							 )
                            
	   set   @IdCountry = (case 
         										 when @isDomestic=1
         										 then
								18
							 end
							 )                           
	   set  	@LocalCurrency =  (select C.CurrencyCode from dbo.Currency as C with (nolock) where C.IdCurrency=@IdCurrency)
	   set  	@CurrencyName =   (select C.CurrencyName from dbo.Currency as C with (nolock) where C.IdCurrency=@IdCurrency)
	   set 	@Country =  (case 
         										 when @isDomestic=1
         										 then
							 (select CountryName from Country with (nolock) where IdCountry=@IdCountry)
							 end
					   )    

--Declaracion de variables
declare @BillerTypeCell varchar(500) =  0 
declare @IdStatus int 
declare @IdAgentPaymentSchema int 
declare @IdProvider int = (select IdProvider from dbo.Providers where ProviderName = (select Name from BillPayment.aggregator where IdAggregator=@IdAggregator))
		  --Regalii
declare @IdAgentBalanceService int =case when @BillerType!=@BillerTypeCell then 2 else 4 end --BillPayment--Top Ups
declare @TransactionDate datetime

--Inicializacion de variables
set @IdStatus=1 --Origin
Set @HasError=0
set @TransactionExRate = ISNULL(@TransactionExRate,0)
set @IdCarrier = case when @IdCarrier=0 then null else @IdCarrier end

if (@HasError=1) return

  --calculos balance
	select @IdAgentPaymentSchema=IdAgentPaymentSchema from agent where idagent=@IdAgent
	declare @TotalAmountToCorporate money = 0
	declare @Commission money =  @AgentCommission+@CorpCommission 
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
	   EXEC	[Operation].[st_UpdateProductTransfer]
	   @IdProductTransfer = @IdProductTransfer,
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
	   @HasError = @HasError OUTPUT

	if   @HasError=0             
    begin
    
    	    Insert into Soporte.InfoLogForStoreProcedure(StoreProcedure,InfoDate,InfoMessage)Values('BillPayment.st_UpdateBPTransaction',Getdate(),
		  'IdProductTransfer:' +CAST(@IdProductTransfer AS varchar(15)) + '- Fee:' + CAST(@Fee AS varchar(15)) + ',' +
		  'CorpCommission:' + CAST(@CorpCommission AS varchar(15)) + ',' +
		  'AgentCommission:' + CAST(@AgentCommission AS varchar(15)) + ',' +
		  'TransactionFee:' + CAST(@TransactionFee AS varchar(15))
		  );

        Update [BillPayment].[TransferR] set
                   [IdAgent]=@IdAgent
                   ,[IdAgentPaymentSchema]=@IdAgentPaymentSchema
                   ,[EnterByIdUser]=@EnterByIdUser
                   ,[DateOfCreation]=@TransactionDate
                   ,[IdCustomer]=@IdCustomer
                   ,[CustomerName]=@CustomerName
                   ,[CustomerFirstLastName]=@CustomerFirstLastName
                   ,[CustomerSecondLastName]=@CustomerSecondLastName
                   ,[CustomerCellPhoneNumber]=@CustomerCelularNumber
                   ,[IdCarrier]=@IdCarrier
                   ,[TotalAmountToCorporate]=@TotalAmountToCorporate
                   ,[Amount]=@Amount
                   ,[AgentCommission]=@AgentCommission
                   ,[CorpCommission]=@CorpCommission
                   ,[Fee]=@Fee
                   ,[TransactionFee]=@TransactionFee
                   ,[ExRate]=@ExRate
                   ,[IdBiller]=@IdBiller
                   ,[Account_Number]=@Account_Number
                   ,[IdCurrency]=@IdCurrency
                   ,[CurrencyName]=@CurrencyName
                   ,[AmountInMN]=@AmountInMN
                   ,[Name_On_Account]=@Name_On_Account
                   ,[Pos_Number]=@Pos_Number
                   ,[Name]=@BillerName
                   ,[Country]=@Country
                   ,[BillerType]=@BillerType
                   ,[CanCheckBalance]=@CanCheckBalance
                   ,[SupportsPartialPayments]=@SupportsPartialPayments
                   ,[RequiresNameOnAccount]=@RequiresNameOnAccount
                   ,[AvailableTopupAmounts]=@AvailableTopupAmounts
                   ,[HoursToFulfill]=@HoursToFulfill
                   ,[LocalCurrency]=@LocalCurrency
                   ,[AccountNumberDigits]=@AccountNumberDigits
                   ,[Mask]=@Mask
                   ,[BillType]=@BillType
                   ,[IdCountry]=@IdCountry
                   ,TransactionExRate=@TransactionExRate
				   ,TopUpCommissionPercentage=@TopUpCommissionPercentage
                   ,IdSchema=@IdSchemaTopUp
				   ,ZipCodeBiller=@ZipBiller
             WHERE
				IdProductTransfer=@IdProductTransfer

					 
		declare @OperationDetailNote varchar(100) =case when @BillerType=@BillerTypeCell then 'Update Fidelity Bill payment' else 'Create Fidelity BillPayment Transaction' end
         exec [Operation].[st_SaveChangesToProductTransferLog]
		        @IdProductTransfer = @IdProductTransfer,
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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('BillPayment.st_UpdateBillPaymentTrans',Getdate(),@ErrorMessage)                                                                                            
End Catch