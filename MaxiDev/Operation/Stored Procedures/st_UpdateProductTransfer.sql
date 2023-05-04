
CREATE procedure [Operation].[st_UpdateProductTransfer]
(
			@IdProductTransfer int,
            @IdProvider int
           ,@IdAgentBalanceService int
           ,@IdOtherProduct int
           ,@IdAgent int
           ,@IdAgentPaymentSchema int
           ,@TotalAmountToCorporate money
           ,@Amount money
           ,@Commission money
           ,@AgentCommission money
           ,@CorpCommission money           
           ,@EnterByIdUser int           
           ,@TransactionDate datetime 
           ,@TransactionID   bigint
           ,@Fee money
           ,@TransactionFee money
           ,@HasError bit out
)
as
begin try
update [Operation].[ProductTransfer]
SET 
           [IdProvider]=@IdProvider
           ,[IdAgentBalanceService]=@IdAgentBalanceService
           ,[IdOtherProduct]=@IdOtherProduct
           ,[IdAgent]=@IdAgent
           ,[IdAgentPaymentSchema]=@IdAgentPaymentSchema
           ,[TotalAmountToCorporate]=@TotalAmountToCorporate
           ,[Amount]=@Amount
           ,[Commission]=@Commission
           ,[AgentCommission]=@AgentCommission
           ,[CorpCommission]=@CorpCommission
           ,[DateOfCreation]=GETDATE()
           ,DateOfStatusChange=GETDATE()
           ,[EnterByIdUser]=@EnterByIdUser
           ,[IdStatus]=1
           ,[TransactionProviderDate]=@TransactionDate
           ,[TransactionProviderID]=@TransactionID
           ,Fee=@Fee
           ,TransactionFee=@TransactionFee
     WHERE
	  IdProductTransfer=@IdProductTransfer

set @HasError=0
end try
Begin Catch                                                                                        
    Set @HasError=1                                                                                     
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('operation.st_UpdateProductTransfer',Getdate(),@ErrorMessage)                                                                                            
End Catch