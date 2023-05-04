CREATE PROCEDURE [Corp].[st_CancelBPTransaction_regalii]
(
     @IdProductTransfer bigint 
    ,@EnterByIdUser int
    ,@IdLenguage int
    ,@HasError bit out                                                                                          
    ,@Message nvarchar(max) out
)
as
Begin Try 
--Declaracion de variables
declare @IdStatus int
declare @TransactionDate datetime
declare @IdAgentPaymentSchema int 
declare @IdProvider int 
declare @IdAgentBalanceService  int
declare @IdOtherProduct int
declare @IdAgent int
declare @TotalAmountToCorporate money
declare @AgentCommission money
declare @CorpCommission money
declare @Fee money
declare @ProviderFee money
declare @BillerName nvarchar(max)
declare @Amount money
declare @AmountInMN money
declare @exrate money
declare @transactionexrate money

--inicializacion de variables
select 
    @TransactionDate=getdate(),
    @IdAgentPaymentSchema=p.IdAgentPaymentSchema,
    @IdProvider=IdProvider, 
    @IdAgentBalanceService=IdAgentBalanceService,
    @IdOtherProduct=IdOtherProduct,
    @IdAgent=p.IdAgent,
    @TotalAmountToCorporate=p.TotalAmountToCorporate,    
    @AgentCommission=p.AgentCommission,
    @CorpCommission=p.CorpCommission,
    @Fee=p.Fee,
    @ProviderFee=p.TransactionFee,
    @BillerName=t.Name,
    @Amount = t.Amount,
    @exrate = t.exrate,
    @TransactionExRate = t.TransactionExRate,
	@AmountInMN = t.AmountInMN
from 
    Operation.ProductTransfer p with(nolock)
join 
    Regalii.TransferR t with(nolock) on p.IdProductTransfer=t.IdProductTransfer
where 
    p.IdProductTransfer=@IdProductTransfer and p.IdStatus=30

if (@IdAgentPaymentSchema is null)
begin
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    Set @HasError=1
    return
end

             --Cogs
            Declare @CGS  money = ROUND(@AmountInMN/@TransactionExRate,2)*-1
			/*print('@AmountInMN')
			print(@AmountInMN)
			print('@TransactionExRate')
			print(@TransactionExRate)
			print('@CGS')
			print(@CGS)*/
            
            --Afectar Balance         

             EXEC	[Corp].[st_RegaliiToAgentBalance]
		        @IdTransaction = @IdProductTransfer,
		        @IdOtherProduct = @IdOtherProduct,
		        @IdAgent = @IdAgent,
		        @IsDebit = 0,
		        @Amount = @TotalAmountToCorporate,
		        @Description = @BillerName,
		        @Country = '',
		        @Commission = 0,
		        @AgentCommission = @AgentCommission,
		        @CorpCommission = @CorpCommission,
		        @FxFee = 0,
		        @Fee = @Fee,
		        @ProviderFee = @ProviderFee,
                @CGS = @CGS

            --update Operation.ProductTransfer set TransactionProviderID=@ProviderId,TransactionProviderDate=@ProviderDate where IdProductTransfer=@IdProductTransfer

             set @IdStatus = 22
             
             EXEC	[Corp].[st_UpdateProductTransferStatus_Operation]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @TransactionDate,
                @EnterByIdUser=@EnterByIdUser,
		        @HasError = @HasError OUTPUT 

            --actualizar
            
            update Regalii.TransferR set
                    EnterByIdUserCancel=@EnterByIdUser,
                    DateOfCancel=@TransactionDate,
                    IdStatus=@IdStatus
            where IdProductTransfer=@IdProductTransfer

            SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PTOK')

End Try
Begin Catch
    Set @HasError=1
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    Declare @ErrorMessage nvarchar(max)
    Select @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_CancelBPTransaction_regalii',Getdate(),@ErrorMessage)
End Catch
