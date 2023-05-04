
CREATE procedure [TransFerTo].[st_CancelTransferTTo]
(
    @IdLenguage int,
    @Action nvarchar(max),
    @IdTransactionTTo int,
    @IdOtherProduct int,
    @CancellationTimeStamp datetime,
    @CancellationMessage nvarchar(max),
    @login nvarchar(max),
    @IdProductTransferOut bigint OUTPUT,
    @HasError int OUTPUT,
	@Message nvarchar(max) OUTPUT       
)
as
Begin Try  
declare @CountryCode nvarchar(max)
declare @IdStatus int,     
    @IdAgent int,    
    @Destination_Msisdn nvarchar(max),
    @Country nvarchar(max),
    @Operator nvarchar(max),
    @Commission money,
    @AgentCommission money,
	@CorpCommission money,
    @WholeSalePrice money,
    @RetailPrice money,
    @IdAgentPaymentSchema int,
    @IdProductTransfer bigint

    --fix temporal zona horaria
    set @CancellationTimeStamp = dateadd(HOUR, -5, @CancellationTimeStamp) 

    set @IdStatus=22 --Cancelled

    select  
        @IdProductTransferOut = IdProductTransfer,
        @IdAgent = IdAgent,        
        @Destination_Msisdn = Destination_Msisdn,
        @Country = Country,
        @Operator = Operator,
        @WholeSalePrice = WholeSalePrice,
        @RetailPrice = RetailPrice,
        @Commission = Commission,
        @AgentCommission = AgentCommission,
	    @CorpCommission =CorpCommission,
        @IdProductTransfer = IdProductTransfer        
    from 
        TransferTo.[TransferTTo] 
    where 
        IdTransactionTTo=@IdTransactionTTo and [action]=@Action and idstatus=30 and IdOtherProduct=@IdOtherProduct

    set @IdProductTransferOut=isnull(@IdProductTransferOut,0)
    
    if @IdProductTransferOut=0
    begin
        Set @HasError=12                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        return
    end

     EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @CancellationTimeStamp,
                @EnterByIdUser = null,
		        @HasError = @HasError OUTPUT  

    update 
        TransferTo.[TransferTTo] 
    set 
            idstatus=@IdStatus,
            CancellationTimeStamp= @CancellationTimeStamp,
            CancellationMessage= @CancellationMessage,
            LoginCancel=@login
     where
        IdProductTransfer = @IdProductTransferOut

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
    
    Set @HasError=6 
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE37')
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=13                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_CancelTransferTTo',Getdate(),@ErrorMessage)                                                                                            
End Catch      
