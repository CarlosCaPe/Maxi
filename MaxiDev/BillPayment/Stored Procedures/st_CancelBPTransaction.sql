
CREATE procedure [BillPayment].[st_CancelBPTransaction]
(
     @IdProductTransfer bigint 
    ,@EnterByIdUser int
    ,@IdLenguage int
	,@JsonRequest varchar(MAX)=''
	,@JsonResponse varchar(MAX)=''
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
    Operation.ProductTransfer p
join 
    Billpayment.TransferR t on p.IdProductTransfer=t.IdProductTransfer
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

             EXEC	[Billpayment].st_AgentBalance
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
             
             EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @TransactionDate,
                @EnterByIdUser=@EnterByIdUser,
		        @HasError = @HasError OUTPUT 

            --actualizar
            IF(@JsonRequest!='' and @JsonResponse!='')
				BEGIN
					update Billpayment.TransferR set
							EnterByIdUserCancel=@EnterByIdUser,
							DateOfCancel=@TransactionDate,
							IdStatus=@IdStatus,
							JsonRequest=@JsonRequest,
							JsonResponse=@JsonResponse
					where IdProductTransfer=@IdProductTransfer
				END
			ELSE
				BEGIN
					update Billpayment.TransferR set
							EnterByIdUserCancel=@EnterByIdUser,
							DateOfCancel=@TransactionDate,
							IdStatus=@IdStatus
					where IdProductTransfer=@IdProductTransfer
				END

            SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PTOK')

End Try
Begin Catch
    Set @HasError=1
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    Declare @ErrorMessage nvarchar(max)
    Select @ErrorMessage=ERROR_MESSAGE()
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Billpayment.st_CancelBPTransaction',Getdate(),@ErrorMessage)
End Catch