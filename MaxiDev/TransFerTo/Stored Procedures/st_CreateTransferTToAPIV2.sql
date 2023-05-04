
create procedure [TransFerTo].[st_CreateTransferTToAPIV2]
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
    @IdSchema int,
    @EnterByIdUser int,
    @IdCustomer int,
    @IdCustomerFrequentNumber int,
    @NickName nvarchar(max),    
    @SaveCustomerFrequentNumber bit,
	@Name nvarchar(max),	--customer name
	@FirstLastName nvarchar(max), --customer last name
	@SecondLastName nvarchar(max), --customer second last name
    @Response nvarchar(max), 
    @Request nvarchar(max), 
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
declare @IdStatus int 
declare @IdAgentPaymentSchema int 
declare @HasErrorBit bit
declare @Login nvarchar(max) = ''

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

   if (isnull(@IdCustomer,0)=0 and (ltrim(rtrim(isnull(@Msisdn,'')))!='' or (ltrim(rtrim(isnull(@Name,'')))!='' and ltrim(rtrim(isnull(@FirstLastName,'')))!='' and ltrim(rtrim(isnull(@SecondLastName,'')))!='') ))
   begin
   print 'entro a create customer'
   exec [TransFerTo].[st_CreateCustomer]
		@Msisdn,
		@IdAgent,
		@EnterByIdUser, 
		@Name,
		@FirstLastName,
		@SecondLastName, 
		@IdCustomer OUTPUT,
		@HasErrorBit OUTPUT

        if @HasErrorBit=1 
        begin
            Set @HasError=3                                                                                   
            SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
            return
        end

    end


    declare @IdCustomerFrequentNumberout int

    if (@SaveCustomerFrequentNumber=1 and isnull(@IdCustomer,0)>0)
    begin 
        print 'entro a [st_SaveCustomerFrequentNumber]'
        exec [TransFerTo].[st_SaveCustomerFrequentNumber]
		@IdCustomerFrequentNumber,
		@IdCustomer,
		@NickName ,		
		@Destination_Msisdn,
		@EnterByIdUser,
		@IdCustomerFrequentNumberout OUTPUT,
		@HasErrorBit OUTPUT

        set @IdCustomerFrequentNumber = @IdCustomerFrequentNumberout

        if @HasErrorBit=1 
        begin
            Set @HasError=3                                                                                   
            SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
            return
        end
                        
    end

    
    set @Country=upper(@Country)

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
            EnterByIdUser,
            IdCustomer,
            IdCustomerFrequentNumber,
            NickName,
            Response,
            Request,
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
            @EnterByIdUser,
            @IdCustomer,
            @IdCustomerFrequentNumber,
            @NickName,
            @Response,
            @Request,
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

		 declare @descrip nvarchar(100)
		 set @descrip = 'Reconcilliation with provider, ' + convert(nvarchar(30), @ReturnTimeStamp) + ' Dest. Number: ' + @Destination_Msisdn + ' TransID: ' + convert(nvarchar(30), @IdTransactionTTo)

         EXEC	[dbo].[st_OtherProductToAgentBalance]
		    @IdTransaction = @IdTransferTTo,
		    @IdOtherProduct = @IdOtherProduct,
		    @IdAgent = @IdAgent,
		    @IsDebit = 1,
		    @Amount = @TotalAmountToCorporate, 
		    @Description = @descrip ,
		    @Country = @Country,
		    @Commission = @Commission,
		    @AgentCommission = @AgentCommission,
		    @CorpCommission = @CorpCommission,
		    @FxFee = 0,
		    @Fee = 0,
		    @ProviderFee = 0

         Set @HasError=1
         SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=3                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_CreateTransferTTo',Getdate(),@ErrorMessage)                                                                                            
End Catch  