CREATE procedure [Operation].[st_CreateProductTransfer]
(
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
           ,@IdProductTransferOut bigint out
)
as
begin try
INSERT INTO [Operation].[ProductTransfer]
           ([IdProvider]
           ,[IdAgentBalanceService]
           ,[IdOtherProduct]
           ,[IdAgent]
           ,[IdAgentPaymentSchema]
           ,[TotalAmountToCorporate]
           ,[Amount]
           ,[Commission]
           ,[AgentCommission]
           ,[CorpCommission]
           ,[DateOfCreation] 
           ,DateOfStatusChange          
           ,[EnterByIdUser]           
           ,[IdStatus]
           ,[TransactionProviderDate]           
           ,[TransactionProviderID]
           ,Fee
           ,TransactionFee
           )
     VALUES
           (@IdProvider
           ,@IdAgentBalanceService
           ,@IdOtherProduct
           ,@IdAgent
           ,@IdAgentPaymentSchema
           ,@TotalAmountToCorporate
           ,@Amount
           ,@Commission
           ,@AgentCommission
           ,@CorpCommission
           ,Getdate() 
           ,getdate()          
           ,@EnterByIdUser
           ,1
           ,@TransactionDate
           ,@TransactionID  
           ,@Fee     
           ,@TransactionFee    
           );

set @IdProductTransferout = SCOPE_IDENTITY();
set @HasError=0
end try
Begin Catch                                                                                        
    Set @HasError=1                                                                                     
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('operation.st_CreateProductTransfer',Getdate(),@ErrorMessage)                                                                                            
End Catch