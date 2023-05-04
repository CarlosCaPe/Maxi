CREATE procedure [TransFerTo].[st_UpdateTransferTToAPIPay]
(    
    @IdTransferTTo int,
    @IdLenguage int,      
    @IdOtherProduct int,  
    @IdTransactionTTo int,      
    @OperatorReference nvarchar(max),
    @LocalInfoAmount money,
    @LocalInfoCurrency nvarchar(max),
    @LocalInfoValue money,
    @ReturnTimeStamp datetime,        
    @Response nvarchar(max),     
    @pinBased bit,
    @pinValidity nvarchar(max),
    @pinCode nvarchar(max),
    @pinIvr nvarchar(max),
    @pinSerial nvarchar(max),
    @pinValue nvarchar(max),
    @pinOption1 nvarchar(max),
    @pinOption2 nvarchar(max),
    @pinOption3 nvarchar(max),     
    @IdStatus int,
    @HasError int out,                                                                                            
    @Message varchar(max) out
)
as
Begin Try  
declare 
    @IdAgent int,    
    @Destination_Msisdn nvarchar(max),
    @Country nvarchar(max),
    @Commission money,
    @AgentCommission money,
	@CorpCommission money,
    @WholeSalePrice money,
    @RetailPrice money,
    @IdAgentPaymentSchema int
declare @CountryCode nvarchar(max)
        
    select          
        @IdAgent = IdAgent,        
        @Destination_Msisdn = Destination_Msisdn,
        @Country = Country,
        @WholeSalePrice = WholeSalePrice,
        @RetailPrice = RetailPrice,
        @Commission = Commission,
        @AgentCommission = AgentCommission,
	    @CorpCommission =CorpCommission        
    from 
        TransferTo.[TransferTTo] 
    where 
        IdTransferTTo=@IdTransferTTo

    set @IdAgent=isnull(@IdAgent,0)

    if @IdAgent=0
    begin
        Set @HasError=12                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        return
    end

        update TransferTo.[TransferTTo] set 
            IdTransactionTTo = @IdTransactionTTo,
            OperatorReference = @OperatorReference,
            LocalInfoAmount = @LocalInfoAmount,
            LocalInfoCurrency = @LocalInfoCurrency,
            LocalInfoValue = @LocalInfoValue,
            ReturnTimeStamp = @ReturnTimeStamp,
            Response = @Response,
            pinBased = @pinBased,
            pinValidity = @pinValidity,
            pinCode = @pinCode,
            pinIvr = @pinIvr,
            pinSerial = @pinSerial,
            pinValue = @pinValue,
            pinOption1 = @pinOption1,
            pinOption2 = @pinOption2,
            pinOption3 = @pinOption3,
            IdStatus = @IdStatus
        where IdTransferTTo=@IdTransferTTo        

         --Afectar Balance

        if @IdStatus=30 
        begin
         --calculos balance
         select @IdAgentPaymentSchema=IdAgentPaymentSchema from agent where idagent=@IdAgent
         declare @TotalAmountToCorporate money = 0

         if (@IdAgentPaymentSchema=2)
            set @TotalAmountToCorporate = @WholeSalePrice+@CorpCommission
        else
            set @TotalAmountToCorporate = @RetailPrice

        --Afectar Balance

        select @CountryCode=CountryCode from TransferTo.Country where countryname=@Country

         set @Country=upper(@Country)

         set @CountryCode= isnull(@CountryCode,@Country)

         EXEC	[dbo].[st_OtherProductToAgentBalance]
		    @IdTransaction = @IdTransferTTo,
		    @IdOtherProduct = @IdOtherProduct,
		    @IdAgent = @IdAgent,
		    @IsDebit = 1,
		    @Amount = @TotalAmountToCorporate,
		    @Description = 'Top UP',
		    @Country = @CountryCode,
		    @Commission = @Commission,
		    @AgentCommission = @AgentCommission,
		    @CorpCommission = @CorpCommission,
		    @FxFee = 0,
		    @Fee = 0,
		    @ProviderFee = 0
        end

         Set @HasError=1
         SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')        
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=3                                                                         
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_UpdateTransferTToAPIPay',Getdate(),@ErrorMessage)                                                                                            
End Catch  