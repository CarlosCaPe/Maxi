
CREATE PROCEDURE [TransFerTo].[st_CancelTransferTToByIdUser]
(
    @IdLenguage int,
    @EnterByIdUser int,    
    @IdProductTransfer bigint,
    @HasError bit OUTPUT,
	@Message nvarchar(max) OUTPUT       
)
as
Begin Try  
declare @CountryCode nvarchar(max)
declare 
    @IdStatusOld int,     
    @IdStatus int,     
    @IdAgent int,       
    @Destination_Msisdn nvarchar(max),
    @Country nvarchar(max),
    @Commission money,
    @AgentCommission money,
	@CorpCommission money,
    @WholeSalePrice money,
    @RetailPrice money,
    @IdAgentPaymentSchema int,
    @Action nvarchar(max), 
    @IdOtherProduct int,
    @CancellationTimeStamp datetime,
    @CancellationMessage nvarchar(max),
    @login nvarchar(max), 
    @operator nvarchar(max) 

    set @Action='topup'
    set @IdOtherProduct=7
    set @CancellationMessage='Cancel by User'
    set @login=''

    set @IdStatus=22 --Cancelled

    select          
        @IdAgent = IdAgent,        
        @Destination_Msisdn = Destination_Msisdn,
        @Country = Country,
        @WholeSalePrice = WholeSalePrice,
        @RetailPrice = RetailPrice,
        @Commission = Commission,
        @AgentCommission = AgentCommission,
	    @CorpCommission =CorpCommission,
        @IdStatusOld=IdStatus,
        @operator=operator
    from 
        TransferTo.[TransferTTo] 
    where 
        IdProductTransfer=@IdProductTransfer /*and [action]=@Action*/ and idstatus=30 and IdOtherProduct=@IdOtherProduct

    set @IdAgent=isnull(@IdAgent,0)

    --Verificar si se encontro la transferencia
    if @IdAgent=0
    begin
        Set @HasError=1                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        return
    end    
    
    --Verificar si se encuentra en un status diferente a cancelado
    if @IdStatusOld=22
    begin    
        Set @HasError=1                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        return
    end
    
    select @login=username from users where iduser=@EnterByIdUser
    
    set @CancellationTimeStamp=getdate()

    
     EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @CancellationTimeStamp,
                @EnterByIdUser = @EnterByIdUser,
		        @HasError = @HasError OUTPUT  
    
    update 
        TransferTo.[TransferTTo] 
    set 
            idstatus=@IdStatus,
            CancellationTimeStamp= @CancellationTimeStamp,
            CancellationMessage= @CancellationMessage,
            LoginCancel=@login
     where
        IdProductTransfer=@IdProductTransfer

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
    
    Set @HasError=0 
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PTOK')
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('TransFerTo.st_CancelTransferTToByIdUser',Getdate(),@ErrorMessage)                                                                                            
End Catch      
