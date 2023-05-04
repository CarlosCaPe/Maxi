CREATE procedure [Regalii].[st_PaidBPTransaction]
(
     @IdProductTransfer bigint
    ,@JsonRequest nvarchar(max)
    ,@ProviderId bigint
    ,@Fx_Rate money -- transactionexrate=@Fx_Rate
    --,@Bill_Amount_Usd money
    --,@Bill_Amount_Chain_Currency money
    --,@Payment_Transaction_Fee money
    --,@Payment_Total_Usd money
    --,@Payment_Total_Chain_Currency money
    --,@Chain_Earned money
    ,@Chain_Paid money --round(montoinmn/transactionexrate,2)+transactionfee=@Chain_Paid
    --,@Starting_Balance money
    --,@Ending_Balance money
    --,@Discount money
    --,@Sms_Text nvarchar(max)
    ,@ProviderDate datetime
    ,@JsonResponse nvarchar(max)
    ,@IdLenguage int
    ,@IsPaid bit
    ,@HasError bit out                                                                                          
    ,@Message nvarchar(max) out
)
as

/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="17/04/2018" Author="jdarellano" Name="#1">Se elimina notificación de correo de "Regalii Operation Error" a petición de cliente.</log>
</ChangeLog>
*********************************************************************/

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
declare @BillerTypeCell varchar(500)
declare @Account_Number varchar(500)


if isnull(@IsPaid,0)=0
begin
    update Regalii.TransferR set
                    JsonRequest=@JsonRequest                                                                            
                   ,JsonResponse=@JsonResponse                   
    where IdProductTransfer=@IdProductTransfer

    set @HasError=0
    SELECT @Message=''
return
end

  
Select @recipients=Value from GLOBALATTRIBUTES where Name='ListEmailRegalliError'  
Select @EmailProfile=Value from GLOBALATTRIBUTES where Name='EmailProfiler'  
Select @BillerTypeCell=Value from GLOBALATTRIBUTES where Name='RegaliiBillerTypeCell'  

select @transactionexrate=TransactionExRate, @AmountDls=Amount ,@AmountInMN=AmountInMN,@transactionFee=TransactionFee, @BillerType=BillerType
from Regalii.TransferR where IdProductTransfer=@IdProductTransfer


IF (@BillerType!=@BillerTypeCell)
BEGIN
	if (@transactionexrate!=@Fx_Rate) or (round(@AmountInMN/@transactionexrate,2)+@transactionFee!=@Chain_Paid)
	begin
		set @IsSendMail = 0--1 --#1
		set @MessageMail = 'Regalii Operation Error: ' + convert(varchar,@IdProductTransfer)
		Set @Body ='Regalii Operation Error: ' + convert(varchar,@IdProductTransfer)
	end
END

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
	@Account_Number=T.Account_Number
from 
    Operation.ProductTransfer p
join 
    Regalii.TransferR t on p.IdProductTransfer=t.IdProductTransfer
where 
    p.IdProductTransfer=@IdProductTransfer and p.IdStatus=1

if (@IdAgentPaymentSchema is null)
begin
    Set @HasError=1
    SELECT @Message=[dbo].[GetMessageFromMultiLenguajeResorces] (@IdLenguage,'MESSAGE07')
return
end
            --Cogs
            Declare @BPTempCGS  money =	 case	
												When @BillerType!=@BillerTypeCell then ROUND(@AmountInMN/@TransactionExRate,1)
												ELSE  @TotalAmountToCorporate--ROUND(@TotalAmountToCorporate,1)	
										END									

            --Afectar Balance   
			
			declare @TempDescription nvarchar(max) =case	
														when @BillerType!=@BillerTypeCell then @BillerName
														else @Account_Number
													end  
			
			declare @TempCountry nvarchar(max) =case	
														when @BillerType!=@BillerTypeCell then ''
														else @BillerName
													end

			if(@BillerType!=@BillerTypeCell)
				Begin
				 EXEC	[dbo].st_RegaliiToAgentBalance
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
				 EXEC	[dbo].[st_RegaliiTopUpToAgentBalance]
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


            exec [Operation].[st_SaveChangesToProductTransferLog]
		        @IdProductTransfer = @IdProductTransfer,
		        @IdStatus = 1,
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

            update Regalii.TransferR set
                    JsonRequest=@JsonRequest
                   ,ProviderId=@ProviderId
                   ,Fx_Rate= case 
									when @BillerType!=@BillerTypeCell then @Fx_Rate
									else 0
							end
                   --,Bill_Amount_Usd=@Bill_Amount_Usd
                   --,Bill_Amount_Chain_Currency=@Bill_Amount_Chain_Currency
                   --,Payment_Transaction_Fee=@Payment_Transaction_Fee
                   --,Payment_Total_Usd=@Payment_Total_Usd
                   --,Payment_Total_Chain_Currency=@Payment_Total_Chain_Currency
                   --,Chain_Earned=@Chain_Earned
                   ,Chain_Paid=@Chain_Paid
                   --,Starting_Balance=@Starting_Balance
                   --,Ending_Balance=@Ending_Balance
                   --,Discount=@Discount
                   --,Sms_Text=@Sms_Text
                   ,ProviderDate=@ProviderDate
                   ,JsonResponse=@JsonResponse
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
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Regalii.st_PaidBPTransaction',Getdate(),@ErrorMessage)                                                                                            
End Catch  