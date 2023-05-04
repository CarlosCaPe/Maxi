CREATE PROCEDURE [lunex].[st_CancelProductTransferByIdUser]
(
    @IdLenguage int,
    @EnterByIdUser int,    
    @IdProductTransfer bigint,
    @HasError bit OUTPUT,
	@Message nvarchar(max) OUTPUT       
)
as
/********************************************************************
<Author> </Author>
<app></app>
<Description></Description>

<ChangeLog>
<log Date="19/12/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/

SET NOCOUNT ON;

Begin Try  
declare 
    @IdStatusOld int,     
    @IdStatus int,     
    @IdAgent int,           
    @Commission money,
    @AgentCommission money,
	@CorpCommission money,    
    @IdAgentPaymentSchema int,    
    @IdOtherProduct int,
    @CancellationTimeStamp datetime,
    @login nvarchar(max)='',
    @TotalAmountToCorporate money,
    @SKUName NVARCHAR(1000),    
    @Phone NVARCHAR(1000),
    @TopupPhone NVARCHAR(1000)

    set @IdStatus=22 --Cancelled

    select          
        @IdAgent = p.IdAgent,                
        @Commission = p.Commission,
        @AgentCommission = p.AgentCommission,
	    @CorpCommission =p.CorpCommission,
        @IdStatusOld=p.IdStatus,        
        @IdOtherProduct=p.IdOtherProduct,
        @TotalAmountToCorporate=TotalAmountToCorporate,
        @TopupPhone=TopupPhone,
        @Phone=Phone,
        @skuname=skuname
    from 
        operation.ProductTransfer p with(nolock)
    join 
        lunex.transferln l with(nolock) on p.IdProductTransfer=l.IdProductTransfer
    where 
        p.IdProductTransfer=@IdProductTransfer /*and [action]=@Action*/ and p.idstatus=30

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
    
    set @CancellationTimeStamp=getdate();

    
     EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @CancellationTimeStamp,
                @EnterByIdUser = @EnterByIdUser,
		        @HasError = @HasError OUTPUT;  
    
    update 
        lunex.TransferLN
    set 
            idstatus=@IdStatus,
            DateOfCancel= @CancellationTimeStamp,
            TransactionCancelDate= @CancellationTimeStamp,            
            LoginCancel=@login,
            EnterByIdUserCancel=@EnterByIdUser
     where
        IdProductTransfer=@IdProductTransfer;   
        
    declare @Description nvarchar(max)        
            declare @Country nvarchar(max)        

            set @Description =case 
                                when @IdOtherProduct=9 then @TopupPhone 
                                when @IdOtherProduct=10 then @Phone 
                                else @skuname                             
                              end

            set @Country =case 
                                when @IdOtherProduct=9 then @skuname 
                                when @IdOtherProduct=10 then @skuname 
                                else ''                                                        
                              end      

    --Afectar Balance         

         EXEC	[dbo].[st_OtherProductToAgentBalance]
		    @IdTransaction = @IdProductTransfer,
		    @IdOtherProduct = @IdOtherProduct,
		    @IdAgent = @IdAgent,
		    @IsDebit = 0,
		    @Amount = @TotalAmountToCorporate,
		    @Description = @Description,
		    @Country = @Country,
		    @Commission = @Commission,
		    @AgentCommission = @AgentCommission,
		    @CorpCommission = @CorpCommission,
		    @FxFee = 0,
		    @Fee = 0,
		    @ProviderFee = 0;
    
    Set @HasError=0 
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'PTOK')
    
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE57')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('lunex.st_CancelProductTransferByIdUser',Getdate(),@ErrorMessage);                                                                                            
End Catch
