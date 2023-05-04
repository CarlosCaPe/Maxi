CREATE PROCEDURE [Corp].[st_CancelPureMinutesTransactionByIdUser]
(
    @IdLenguage int,
    @EnterByIdUser int,    
    @IdProductTransfer bigint,  
    @HasError bit OUTPUT,
	@Message nvarchar(max) OUTPUT       
)
as
Begin Try

DECLARE	@return_value int
DECLARE	@IdAgent int
DECLARE	@Amount money
DECLARE	@AgentCommission money
DECLARE	@CorpCommission money
DECLARE	@CGS money
DECLARE	@IdStatus int
DECLARE	@IdStatusOLD int
declare @TransactionCancelDate datetime= getdate() 
declare @ReceiveAccountNumber nvarchar(max)

set @IdStatus=2 --Cancelled

select 
    @IdAgent=idagent,
    @Amount=receiveamount,
    @AgentCommission=agentcommission,
    @CorpCommission=corpcommission,
    @CGS=receiveamount-agentcommission-corpcommission,
    @IdStatusOLD=status,
    @IdProductTransfer=IdProductTransfer,
    @ReceiveAccountNumber=ReceiveAccountNumber
from 
    PureMinutesTransaction 
where IdProductTransfer=@IdProductTransfer

    set @IdAgent=isnull(@IdAgent,0)

    --Verificar si se encontro la transferencia
    if @IdAgent=0
    begin
        Set @HasError=1                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        return
    end    
    
    --Verificar si se encuentra en un status diferente a cancelado
    if @IdStatusOld=2
    begin    
        Set @HasError=1                                                                                    
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
        return
    end

    EXEC	[Corp].[st_UpdateProductTransferStatus_Operation]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = 22,
		        @TransactionDate = @TransactionCancelDate,
                @EnterByIdUser = @EnterByIdUser,
		        @HasError = @HasError OUTPUT  

    if @HasError = 0
    begin
        update PureMinutesTransaction set status=@IdStatus,CancelIdUser=@EnterByIdUser,CancelDateOfTransaction=getdate()  where IdProductTransfer=@IdProductTransfer

        --Afectar Balance

        EXEC	[Corp].[st_OPDebitCreditToAgentBalance]
		    @IdAgent = @IdAgent,
		    @Amount = @Amount,
		    @IdReference = @IdProductTransfer,
		    @Reference = @IdProductTransfer,
		    --@Description = N'Long Distance Cancel',
            @Description = @ReceiveAccountNumber,
		    @Commission = @AgentCommission,
		    @OperationType = N'LDC',
		    @DebitOrCredit = N'Credit',
		    @CGS = @CGS,
		    @Fee = 0,
		    @ProviderFee = 0,
		    @CorpCommission = @CorpCommission

        Set @HasError=0 
        SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'LDCANCELOK')
    end
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_CancelPureMinutesTransactionByIdUser',Getdate(),@ErrorMessage)                                                                                            
End Catch
