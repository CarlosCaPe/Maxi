CREATE procedure [BillPayment].[st_PaidBPTransaction]
(

     @IdProductTransfer bigint
    ,@JsonRequest nvarchar(max)
    ,@ProviderId bigint
    ,@ProviderDate datetime
    ,@JsonResponse nvarchar(max)
    ,@IdLenguage int
    ,@IsPaid bit
    ,@HasError bit out                                                                                          
    ,@Message nvarchar(max) out
    ,@TraceNumber nvarchar(max)
)
/********************************************************************
<Author> Amoreno </Author>
<app> Corporative </app>
<Description>Get TRansfer Other Products</Description>

<ChangeLog>
<log Date="01/02/2018" Author="amoreno"> Create</log>
<log Date="13/09/2019" Author="azavala"> Insert/Save Request and Response for FidelityExpress :: ref: azavala_13092019_1959</log>
</ChangeLog>
*********************************************************************/ 
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
declare @transactionexrate money
declare @AmountInMN money
declare @AmountDls money
declare @transactionFee Money
declare @IsSendMail bit = 0
declare @Body nvarchar(max) = ''
declare @MessageMail nvarchar(max) = ''
Declare @recipients nvarchar (max)                        
Declare @EmailProfile nvarchar(max) 
declare @exrate money
declare @Amount money
declare @BillerType varchar(500)
declare @Account_Number varchar(500)
declare @TempCountry varchar(500)

set @ProviderDate= getdate()

if isnull(@IsPaid,0)=0
begin
    update BillPayment.TransferR set
                    JsonRequest=(case when @JsonRequest='' then JsonResponse else @JsonRequest end)
                   ,JsonResponse=(case when @JsonResponse='' then JsonResponse else @JsonResponse end)
    where IdProductTransfer=@IdProductTransfer

    set @HasError=0
    SELECT @Message=''
    
    
	/*Start azavala_13092019_1959*/
          --  EXEC	[Operation].[st_UpdateProductTransferStatus]
		        --@IdProductTransfer = @IdProductTransfer,
		        --@IdStatus = 31,
		        --@TransactionDate = @TransactionDate,
		        --@HasError = @HasError OUTPUT
	/*End azavala_13092019_1959*/
		        
return
end

/*Start azavala_13092019_1959*/
if exists (select 1 from BillPayment.TransferR T with(nolock) inner join Billpayment.Billers B with(nolock) on B.IdBiller=T.IdBiller where T.IdProductTransfer=@IdProductTransfer and B.IdAggregator=1)
begin
	update BillPayment.TransferR set
        JsonRequest=(case when @JsonRequest='' then JsonResponse else @JsonRequest end),
		JsonResponse=(case when @JsonResponse='' then JsonResponse else @JsonResponse end)
	where IdProductTransfer=@IdProductTransfer
end
/*End azavala_13092019_1959*/
  
Select @recipients=Value from GLOBALATTRIBUTES where Name='ListEmailRegalliError'  
Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'  


select @transactionexrate=TransactionExRate, @AmountDls=Amount ,@AmountInMN=AmountInMN,@transactionFee=TransactionFee, @BillerType=BillerType
from BillPayment.TransferR where IdProductTransfer=@IdProductTransfer




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
	@Account_Number=T.Account_Number,
	@TempCountry = t.country
from 
    Operation.ProductTransfer p
join 
    BillPayment.TransferR t on p.IdProductTransfer=t.IdProductTransfer
where 
    p.IdProductTransfer=@IdProductTransfer and p.IdStatus=1

if (@IdAgentPaymentSchema is null)
begin
    Set @HasError=1
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
return
end

				 Declare @BPTempCGS	 money = @Amount											
            --Afectar Balance   
			
			declare @TempDescription nvarchar(max) =@BillerName--@Account_Number	
--														when @BillerType!=@BillerTypeCell then @BillerName
--														else @Account_Number
--													end  
--			
			--declare @TempCountry nvarchar(max) =@BillerName
--			case	
--														when @BillerType!=@BillerTypeCell then ''
--														else @BillerName
--													end


		 EXEC	[BillPayment].st_AgentBalance
					@IdTransaction = @IdProductTransfer,
					@IdOtherProduct = @IdOtherProduct,
					@IdAgent = @IdAgent,
					@IsDebit = 1,
					@Amount = @TotalAmountToCorporate,
					@Description = @TempDescription,
					@Country = @TempCountry,
					@Commission = 0,
					@AgentCommission = @AgentCommission,
					@CorpCommission = @CorpCommission,
					@FxFee = 0,
					@Fee = @Fee,
					@ProviderFee = @ProviderFee,
					@CGS = @BPTempCGS
					
					/*

			if(@BillerType!=@BillerTypeCell)
				Begin
				 EXEC	[BillPayment].st_AgentBalance
					@IdTransaction = @IdProductTransfer,
					@IdOtherProduct = @IdOtherProduct,
					@IdAgent = @IdAgent,
					@IsDebit = 1,
					@Amount = @TotalAmountToCorporate,
					@Description = @TempDescription,
					@Country = @TempCountry,
					@Commission = 0,
					@AgentCommission = @AgentCommission,
					@CorpCommission = @CorpCommission,
					@FxFee = 0,
					@Fee = @Fee,
					@ProviderFee = @ProviderFee,
					@CGS = @BPTempCGS
				END
			ELSE
				BEGIN
				 EXEC	[BillPayment].[st_TopUpToAgentBalance]
					@IdTransaction = @IdProductTransfer,
					@IdOtherProduct = @IdOtherProduct,
					@IdAgent = @IdAgent,
					@IsDebit = 1,
					@Amount = @TotalAmountToCorporate,
					@Description = @TempDescription,
					@Country = @TempCountry,
					@Commission = 0,
					@AgentCommission = @AgentCommission,
					@CorpCommission = @CorpCommission,
					@FxFee = 0,
					@Fee = @Fee,
					@ProviderFee = @ProviderFee,
					@CGS = @BPTempCGS
				END

*/
            exec [Operation].[st_SaveChangesToProductTransferLog]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus=@IdStatus, /*azavala_13092019_1959*/
		        @Note = 'Transfer Charge Added to Agent Balance',
		        @IdUser = 0,
		        @CreateNote = 0

            update Operation.ProductTransfer set TransactionProviderID=@ProviderId,TransactionProviderDate=@ProviderDate where IdProductTransfer=@IdProductTransfer

             set @IdStatus = 30
             
             EXEC	[Operation].[st_UpdateProductTransferStatus]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = @IdStatus,
		        @TransactionDate = @TransactionDate,
		        @HasError = @HasError OUTPUT 

            --actualizar

            update BillPayment.TransferR set
                    JsonRequest=(case when @JsonRequest='' then JsonResponse else @JsonRequest end)
                   ,ProviderId=@ProviderId
                   ,TraceNumber= @TraceNumber
                   ,Fx_Rate=  0
                   ,Chain_Paid=0
                   ,ProviderDate=@ProviderDate
                   ,JsonResponse=(case when @JsonResponse='' then JsonResponse else @JsonResponse end)
                   ,IdStatus=@IdStatus
            where IdProductTransfer=@IdProductTransfer

            SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE06')

if (@IsSendMail=1)
begin
        EXEC msdb.dbo.sp_send_dbmail                          
                @profile_name=@EmailProfile,                                                     
                @recipients = @recipients,                                                          
                @body = @body,                                                           
                @subject = @MessageMail
end


End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                   
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('BillPayment.st_PaidBPTransaction',Getdate(),@ErrorMessage)                                                                                            
End Catch  
