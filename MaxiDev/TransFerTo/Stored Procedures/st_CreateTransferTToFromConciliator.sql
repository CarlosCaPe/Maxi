CREATE procedure [TransFerTo].[st_CreateTransferTToFromConciliator]
(    
    @IdLenguage int,
    @IdAgent int,
    @IdOtherProduct int,
    @Action nvarchar(max),
    @Key bigint,
    @Msisdn nvarchar(max),
    @Destination_Msisdn nvarchar(max),
    @Product nvarchar(max),
    @Operator nvarchar(max),
    @OriginCurrency nvarchar(max),
    @DestinationCurrency nvarchar(max),
    @WholeSalePrice money,
    @RetailPrice money,
    @IdTransactionTTo int,
    @Country nvarchar(max),
    @OperatorReference nvarchar(max),
    @ReturnTimeStamp datetime,    
    @Commission money,
    @AgentCommission money,
    @CorpCommission money,
    @IdSchema int,
	@IdStatus int,
	@EnterByIdUser int,
	@LocalInfoAmount money,
    @LocalInfoCurrency nvarchar(max),
    @LocalInfoValue money,
	@pinBased bit,
    @pinValidity nvarchar(max),
    @pinCode nvarchar(max),
    @pinIvr nvarchar(max),
    @pinSerial nvarchar(max),
    @pinValue nvarchar(max),
    @pinOption1 nvarchar(max),
    @pinOption2 nvarchar(max),
    @pinOption3 nvarchar(max),
    @IdTransferTTo int out,
    @HasError int out,                                                                                            
    @Message varchar(max) out
)
as
Begin Try  
	
	declare @IdAgentPaymentSchema int 
    declare @CountryCode nvarchar(max)        

    select @CountryCode=CountryCode from TransferTo.Country where countryname=@Country

    set @Country=upper(@Country)

    set @CountryCode= isnull(@CountryCode,@Country)

	if (@IdTransactionTTo>0 and not exists(select top 1 IdTransactionTTo from TransferTo.TransferTTo where IdTransactionTTo =@IdTransactionTTo))
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
            ReturnTimeStamp,        
            Commission,
            AgentCommission,
            CorpCommission,
            [IdStatus],
            DateOfCreation,
            IdOtherProduct,
            IdSchema,
			EnterByIdUser,
			LocalInfoAmount,
			LocalInfoCurrency,
			LocalInfoValue,			
			pinBased,
			pinValidity,
			pinCode,
			pinIvr,
			pinSerial,
			pinValue,
			pinOption1,
			pinOption2,
			pinOption3			
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
            @ReturnTimeStamp,
            @Commission,
            @AgentCommission,
            @CorpCommission,
            @IdStatus,
            getdate(),
            @IdOtherProduct,
            @IdSchema,
			@EnterByIdUser,
			@LocalInfoAmount,
			@LocalInfoCurrency,
			@LocalInfoValue, 
			@pinBased,
			@pinValidity,
			@pinCode,
			@pinIvr,
			@pinSerial,
			@pinValue,
			@pinOption1,
			@pinOption2,
			@pinOption3				
        )

         Select @IdTransferTTo=SCOPE_IDENTITY() 

         --calculos balance
         select @IdAgentPaymentSchema=IdAgentPaymentSchema from agent where idagent=@IdAgent
         declare @TotalAmountToCorporate money = 0

         if (@IdAgentPaymentSchema=2)
            set @TotalAmountToCorporate = @WholeSalePrice+@CorpCommission
        else
            set @TotalAmountToCorporate = @RetailPrice

         --Afectar Balance         

		 if @IdStatus=30 and @RetailPrice>=1
		 begin

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
end
else
begin
         Set @HasError=3
         SELECT @Message= 'El IdTransaction ' + convert(nvarchar(max),@IdTransactionTTo) + ' ya existe en el sistema, se intentaba insertar otra vez'
end
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=3                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_CreateTransferTToFromConciliator',Getdate(),@ErrorMessage)                                                                                            
End Catch  