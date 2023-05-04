/********************************************************************
<Author>Unknow</Author>
<app>Agent</app>
<Description></Description>

<ChangeLog>
<log Date="2020/07/20" Author="adominguez"> Info Adicional : Se agregan campos de info adicional para la transferencia y customer</log>
<log Date="2020/09/18" Author="esalazar"> se inicializan nulos campos para funcionamiento en guardado de customer pago de bill M00271</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>
********************************************************************/
CREATE procedure [BillPayment].[st_CreateBillPaymentTrans]
(
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
    @IdCarrier int =null,
    @IdCustomerFrequentNumber int =null,
    @NickNameBeneficiary nvarchar(max) = null,
    @BeneficiaryPhoneNumber nvarchar(max) = null,
    @IdSchemaTopUp int =null,
    @IdBiller int,
    @Account_Number nvarchar(max),   
    @EnterByIdUser int,
    @IdLenguage int,
    @IdCustomerOut int out,
    @IdProductTransferOut bigint out,
    @HasError bit out,
    @Message nvarchar(max) out,
    @idElasticCustomer varchar(max) out, 
    @TransactionExRate money = null,
    @Update bit out,
	@ZipBiller varchar(max), 
	--Datos Info Adicional Customer
	@CustomerIdCustomerIdentificationType int = null,
	@CustomerSSNumber nvarchar(max)= null, ---M00271
	@TypeTaxId int = 0,
	@HasTaxId bit = 0,
	@HasDuplicatedTaxId bit=null, --M00271
    @CustomerBornDate datetime= null,--- M00271
    @CustomerOccupation nvarchar(max)= '',
	@CustomerIdOccupation int = 0, /*M00207*/
	@CustomerIdSubcategoryOccupation int = 0,/*M00207*/
	@CustomerSubcategoryOccupationOther nvarchar(max) ='',/*M00207*/  
    @CustomerIdentificationNumber nvarchar(max)='',
    @CustomerExpirationIdentification datetime=null,--M00271
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
	--@OWBRuleType int
)

/********************************************************************
<Author>Amoreno</Author>
<app> </app>
<Description>Create Tranfer for BillPayment </Description>

<ChangeLog>
<log Date="2018-08-22" Author="amoreno"> Creacion  </log>
<log Date="2018-09-26" Author="amoreno"> Cambio en calculo de comisiones</log>
<log Date="2019-01-31" Author="azavala"> Forzar guardado de customer - Ref: 31012019_azavala</log>
<log Date="2019-02-10" Author="amoreno"> Se agrega ZipBiller</log>
<log Date="2020/10/04" Author="esalazar" Name="Occupations">-- CR M00207	</log>
</ChangeLog>

*********************************************************************/
as
Begin Try  
  
    Insert into Soporte.InfoLogForStoreProcedure(StoreProcedure,InfoDate,InfoMessage)Values('BillPayment.st_CreateBPTransaction',Getdate(),
	   'IdProductTransfer:0 - Fee:' + CAST(@Fee AS varchar(15)) + ',' +
	   'CorpCommission:' + CAST(@CorpCommission AS varchar(15)) + ',' +
	   'AgentCommission:' + CAST(@AgentCommission AS varchar(15)) + ',' +
	   'TransactionFee:' + CAST(@TransactionFee AS varchar(15))
	);

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
	, @TransferDate datetime = getdate()

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
declare @IdProvider int =  		(select IdProvider	 from dbo.Providers where ProviderName =( select Name from BillPayment.aggregator where IdAggregator=@IdAggregator) )
		  --Regalii
declare @IdAgentBalanceService int =case when @BillerType!=@BillerTypeCell then 2 else 4 end --BillPayment--Top Ups
declare @TransactionDate datetime



--select * from dbo.GetGlobalAttributeByName('RegaliiFee')




--Inicializacion de variables
set @IdStatus=1 --Origin
Set @HasError=0
set @TransactionExRate = ISNULL(@TransactionExRate,0)
--set @TransactionFee=  0 --case when @BillerType!=@BillerTypeCell then isnull(convert(money,dbo.GetGlobalAttributeByName('RegaliiFee')),0) else 0 end
--set @CorpCommission=@CorpCommission-@Fee
set @IdCarrier = case when @IdCarrier=0 then null else @IdCarrier end

--{if (@BillerType!=@BillerTypeCell and isnull(@IdCustomer,0)=0) or (@BillerType!=@BillerTypeCell and isnull(@IdCustomer,0)>0 and isnull(@IsSaveCustomer,0)=1)
--	or (@BillerType=@BillerTypeCell and isnull(@IsSaveCustomer,0)=1)
--begin }-- Ref: 31012019_azavala
    
	--declare @oldAddress nvarchar(max), @oldcity nvarchar(max), @oldstate nvarchar(max), @oldzip nvarchar(max), @oldphone nvarchar(max)
	
	--if isnull(@IdCustomer,0)>0 BEGIN
	--  select @oldAddress = Address, @oldcity =City, @oldstate = State, @oldzip =Zipcode, @oldphone = PhoneNumber from Customer where IdCustomer=@IdCustomer
	--END 


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
		@PhoneNumber = @CustomerCelularNumber,
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

	
		--declare @IdCustomerOutput int,  @IdCustomerElasticOutput varchar(max);
		--EXEC st_InsertCustomerByTransfer
	 --  @IdCustomer,
	 --  @IdAgent,
	 --  @CustomerIdCustomerIdentificationType,
	 --  1,
	 --  @CustomerName,
	 --  @CustomerFirstLastName,
	 --  @CustomerSecondLastName,
	 --  @Address,
	 --  @City,
	 --  @State,
	 --  'USA',
	 --  @ZipCode,
	 --  @CustomerPhoneNumber,
	 --  @CustomerCelullarNumber,
	 --  @CustomerSSNumber,
	 --  @CustomerBornDate,
	 --  @CustomerOccupation,
	 --  @CustomerIdentificationNumber,
	 --  0,
	 --  @TransferDate,
	 --  @EnterByIdUser,
	 --  @CustomerExpirationIdentification,
	 --  @IdCarrier,
	 --  NULL ,
	 --  NULL ,
	 --  @AmountInMN,
	 --  null,
	 --  0,
	 --  0,
	 --  @IdAgent,
	 --  @TypeTaxId ,
	 --  @HasDuplicatedTaxId ,
	 --  @HasTaxId ,
	 --  @CustomerOccupationDetail, /*S44:REQ. MA.025*/
	 --  @IdCustomerOutput Output,
	 --  @IdCustomerElasticOutput output;


	------------------------------ Insert OWB ----------------------------------------------------                                                                                  
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

--{end
--else
--begin
--	set @Update = 0
--end} Ref: 31012019_azavala
set @IdCustomerOut=@IdCustomer /*Optimizacion Agente*/

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
    
    	    Insert into Soporte.InfoLogForStoreProcedure(StoreProcedure,InfoDate,InfoMessage)Values('BillPayment.st_CreateBPTransaction',Getdate(),
		  'IdProductTransfer:' +CAST(@IdProductTransferOut AS varchar(15)) + '- Fee:' + CAST(@Fee AS varchar(15)) + ',' +
		  'CorpCommission:' + CAST(@CorpCommission AS varchar(15)) + ',' +
		  'AgentCommission:' + CAST(@AgentCommission AS varchar(15)) + ',' +
		  'TransactionFee:' + CAST(@TransactionFee AS varchar(15))
		  );

        INSERT INTO [BillPayment].[TransferR]
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
				  -- ,TopUpBonusAmountReceived
                   ,IdSchema
				   ,ZipCodeBiller
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
				 --  ,@TopUpBonusAmountReceived
                   ,@IdSchemaTopUp
				    ,  @ZipBiller
					,@IdOnWhoseBehalfOutput)
					 
		declare @OperationDetailNote varchar(100) =case when @BillerType=@BillerTypeCell then 'Create Fidelity Bill payment' else 'Create Fidelity BillPayment Transaction' end
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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('BillPayment.st_CreateBPTransaction',Getdate(),@ErrorMessage)                                                                                            
End Catch