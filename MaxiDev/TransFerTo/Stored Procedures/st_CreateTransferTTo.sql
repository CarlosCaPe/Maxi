
CREATE procedure [TransFerTo].[st_CreateTransferTTo]
(    
    @IdLenguage int,
    @IdAgent int,
    @IdOtherProduct int,
    @Action nvarchar(max),
    @Key int,
    @Msisdn nvarchar(max),
    @Destination_Msisdn nvarchar(max),
    @Product nvarchar(max),
    @Operator nvarchar(max),
    @OriginCurrency nvarchar(max),
    @DestinationCurrency nvarchar(max),
    @WholeSalePrice money,
    @RetailPrice money,
    --@Sentamount money,
    @IdTransactionTTo int,
    @Country nvarchar(max),
    @OperatorReference nvarchar(max),
    @LocalInfoAmount money,
    @LocalInfoCurrency nvarchar(max),
    @LocalInfoValue money,
    @ReturnTimeStamp datetime,    
    @Commission money,
    --@CommissionPercent float,        
    @AgentCommission money,
    @CorpCommission money,
    @Login nvarchar(max),
    @IdSchema int,
    --@IdTransferTTo int out,
    @IdProductTransferOut int out,
    @HasError int out,                                                                                            
    @Message varchar(max) out
)
as
Begin Try  
declare @IdStatus int 
declare @IdAgentPaymentSchema int 
declare @CountryCode nvarchar(max)
declare @IdProvider int = 2 --transferto
declare @IdAgentBalanceService int = 4 --topup

    --fix temporal zona horaria
    set @ReturnTimeStamp = dateadd(HOUR, -5, @ReturnTimeStamp) 
    
    set @IdStatus=30 --Paid   
    /*
    if exists (select top 1 1 from TransferTo.[TransferTTo] where IdTransactionTTo=@IdTransactionTTo) 
    begin
        Set @HasError=2                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE61')
        return
    end
    */

    set @Country=upper(@Country)

     --calculos balance
         select @IdAgentPaymentSchema=IdAgentPaymentSchema from agent where idagent=@IdAgent
         declare @TotalAmountToCorporate money = 0

         if (@IdAgentPaymentSchema=2)
            set @TotalAmountToCorporate = @WholeSalePrice+@CorpCommission
        else
            set @TotalAmountToCorporate = @RetailPrice

    declare @SystemUser int

    select @SystemUser=dbo.GetGlobalAttributeByName('SystemUserID')    

     EXEC	[Operation].[st_CreateProductTransfer]
		@IdProvider = @IdProvider,
		@IdAgentBalanceService = @IdAgentBalanceService,
		@IdOtherProduct = @IdOtherProduct,
		@IdAgent = @IdAgent,
		@IdAgentPaymentSchema = @IdAgentPaymentSchema,
		@TotalAmountToCorporate = @TotalAmountToCorporate,
		@Amount = @RetailPrice,
		@Commission = @Commission,
        @fee = 0,
        @TransactionFee = 0,
		@AgentCommission = @AgentCommission,
		@CorpCommission = @CorpCommission,
		@EnterByIdUser = @SystemUser,
		@TransactionDate = @ReturnTimeStamp,
		@TransactionID = @IdTransactionTTo,
		@HasError = @HasError OUTPUT,
		@IdProductTransferOut = @IdProductTransferOut OUTPUT

    if   @HasError=0             
    begin

        insert into  TransferTo.[TransferTTo](	
                IdAgent,
                [Action],
                [Key],
                Msisdn,
                Destination_Msisdn,
                Product,
                Operator,
                OriginCurrency,
                DestinationCurrency,
                WholeSalePrice,
                RetailPrice,            
                IdTransactionTTo,
                Country,
                OperatorReference,
                LocalInfoAmount,
                LocalInfoCurrency,
                LocalInfoValue,
                ReturnTimeStamp,        
                Commission,
                --CommissionPercent,
                AgentCommission,
                CorpCommission,
                [IdStatus],
                DateOfCreation,
                IdOtherProduct,
                login,
                IdSchema,
                IdProductTransfer
            )
            values
            (
                @IdAgent,
                @Action,
                @Key,
                @Msisdn,
                @Destination_Msisdn,
                @Product,
                @Operator,
                @OriginCurrency,
                @DestinationCurrency,
                @WholeSalePrice,
                @RetailPrice,            
                @IdTransactionTTo,
                @Country,
                @OperatorReference,
                @LocalInfoAmount,
                @LocalInfoCurrency,
                @LocalInfoValue,
                @ReturnTimeStamp,
                @Commission,
                --@CommissionPercent,
                @AgentCommission,
                @CorpCommission,
                @IdStatus,
                getdate(),
                @IdOtherProduct,
                @Login,
                @IdSchema,
                @IdProductTransferOut
            )        

             --Afectar Balance

             select @CountryCode=CountryCode from TransferTo.Country where countryname=@Country

              set @Country=upper(@Country)          

             set @CountryCode= isnull(@CountryCode,@Country)

             EXEC	[dbo].[st_OtherProductToAgentBalance]
		        @IdTransaction = @IdProductTransferOut,
		        @IdOtherProduct = @IdOtherProduct,
		        @IdAgent = @IdAgent,
		        @IsDebit = 1,
		        @Amount = @TotalAmountToCorporate,
		        @Description = @Destination_Msisdn,
		        @Country = @Operator,
		        @Commission = @Commission,
		        @AgentCommission = @AgentCommission,
		        @CorpCommission = @CorpCommission,
		        @FxFee = 0,
		        @Fee = 0,
		        @ProviderFee = 0

             exec [Operation].[st_SaveChangesToProductTransferLog]
		        @IdProductTransfer = @IdProductTransferOut,
		        @IdStatus = 1,
		        @Note = 'Transfer Charge Added to Agent Balance',
		        @IdUser = 0,
		        @CreateNote = 0

            set @IdStatus = 30
             
             EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransferOut,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @ReturnTimeStamp,
		        @HasError = @HasError OUTPUT 

             Set @HasError=1
             SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')
    end
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=3                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_CreateTransferTTo',Getdate(),@ErrorMessage)                                                                                            
End Catch  