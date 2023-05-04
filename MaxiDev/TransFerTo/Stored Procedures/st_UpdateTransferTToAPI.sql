
CREATE procedure [TransFerTo].[st_UpdateTransferTToAPI]
(    
    @IdProductTransfer BIGint,
    @IdLenguage int,      
    @IdOtherProduct int,  
    @IdTransactionTTo BIGint,      
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
	@EnterByIdUser INT = NULL,
    @HasError int out,                                                                                            
    @Message varchar(max) out
)
as
Begin Try  
declare 
    @IdAgent int,    
    @Destination_Msisdn nvarchar(max),
    @oPERATOR nvarchar(max),
    @Country nvarchar(max),
    @Commission money,
    @AgentCommission money,
	@CorpCommission money,
    @WholeSalePrice money,
    @RetailPrice money,
    @IdAgentPaymentSchema int
declare @CountryCode nvarchar(max)
        
	IF ISNULL(@EnterByIdUser,0) <= 0 SET @EnterByIdUser = 37

    select          
        @IdAgent = IdAgent,        
        @Destination_Msisdn = Destination_Msisdn,
        @Country = Country,
        @WholeSalePrice = WholeSalePrice,
        @RetailPrice = RetailPrice,
        @Commission = Commission,
        @AgentCommission = AgentCommission,
	    @CorpCommission =CorpCommission   ,
        @oPERATOR=oPERATOR     
    from 
        TransferTo.[TransferTTo] 
    where 
        IdProductTransfer=@IdProductTransfer

    set @IdAgent=isnull(@IdAgent,0)

    if @IdAgent=0
    begin
        Set @HasError=12                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        return
    end        

         --Afectar Balance

        if @IdStatus=22 
        begin

        UPDATE OPERATION.PRODUCTTRANSFER SET TransactionProviderID=@IdTransactionTTo where IdProductTransfer=@IdProductTransfer

         DECLARE @CANCEL DATETIME =  GETDATE()
      EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = @IdStatus,
		        @TransactionDate =@CANCEL,
                @EnterByIdUser = @EnterByIdUser,
		        @HasError = @HasError OUTPUT  

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
            IdStatus = @IdStatus,
            CancellationTimeStamp = case when @IdStatus=22 then @CANCEL else CancellationTimeStamp end
        where IdProductTransfer=@IdProductTransfer

        


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
		    @IdTransaction = @IdProductTransfer,
		    @IdOtherProduct = @IdOtherProduct,
		    @IdAgent = @IdAgent,
		    @IsDebit = 0,
		    @Amount = @TotalAmountToCorporate,
		    @Description = @Destination_Msisdn,
		    @Country = @Operator,
		    @Commission = @Commission,
		    @AgentCommission = @AgentCommission,
		    @CorpCommission = @CorpCommission,
		    @FxFee = 0,
		    @Fee = 0,
		    @ProviderFee = 0
        end

        IF @IDSTATUS=30
        BEGIN   
        
         UPDATE OPERATION.PRODUCTTRANSFER SET TransactionProviderID=@IdTransactionTTo where IdProductTransfer=@IdProductTransfer    

        DECLARE @ENTER DATETIME =  GETDATE()
        EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = @IdStatus,
		        @TransactionDate =@ENTER,
                @EnterByIdUser = @EnterByIdUser,
		        @HasError = @HasError OUTPUT  

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
            IdStatus = @IdStatus,
            CancellationTimeStamp = case when @IdStatus=22 then @CANCEL else CancellationTimeStamp end
        where IdProductTransfer=@IdProductTransfer
        END

         Set @HasError=1
         SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')        
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=3                                                                         
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_UpdateTransferTToAPI',Getdate(),@ErrorMessage)                                                                                            
End Catch  