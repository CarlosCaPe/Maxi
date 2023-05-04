CREATE PROCEDURE [Corp].[st_SaveAgentCreditLimitHistory]
(
    @IdAgent int,
    @CreditLimitSuggested money,
    @EnterbyIdUser int,
    @Note nvarchar(max) = '',
    @HasError bit out
)
as
begin try

 INSERT INTO [dbo].[AgentCreditLimitHistory]
           ([IdAgent]
           ,[CreditAmount]
           ,[DateOfLastChange]
           ,[EnterByIdUser]
		   ,[NoteCreditAmountChange])
        VALUES
           (@IdAgent
           ,@CreditLimitSuggested
           ,getdate()
           ,@EnterbyIdUser
		   ,@Note)

set @HasError=0
End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                       
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('Corp.st_SaveAgentCreditLimitHistory',Getdate(),@ErrorMessage)                                                                                            
End Catch 
