create procedure [dbo].[st_UdateAgentCreditLimit]
(
    @IdAgent int,
    @CreditAmount money,
    @EnterbyIdUser int,
	@Note Varchar(Max),
    @HasError bit out
)
as
begin try

declare @SystemUser int	
select @SystemUser=convert(int,[dbo].[GetGlobalAttributeByName]('SystemUserID'))

if isnull(@CreditAmount,0)>0 
   begin
		if(ISNULL((select creditamount from agent where idagent = @IdAgent),0) != @CreditAmount)
			begin
				insert into creditlimithistory(IdAgent, CreditLimit, DateOfCreation, EnteredByIdUser) values (@IdAgent, @CreditAmount, GETDATE(),@EnterbyIdUser)								
                update AgentCreditApproval set IsApproved=0 , DateOfLastChange=getdate() , EnterByIdUser=@SystemUser where idagent=@idAgent and IsApproved is null
                exec st_SaveAgentMirror @IdAgent 
                update agent set CreditAmount=@CreditAmount,dateoflastchange=getdate(),enterbyiduser=@EnterbyIdUser,NoteCreditAmountChange = @Note where idagent=@IdAgent
			end     
            
        --exec st_SaveAgentMirror @IdAgent 
        --update agent set CreditAmount=@CreditAmount,dateoflastchange=getdate(),enterbyiduser=@IdUser where idagent=@IdAgent
   end

set @HasError=0

EXEC [dbo].[st_SaveAgentCreditLimitHistory]   @IdAgent, @CreditAmount, @EnterbyIdUser, @Note, @HasError


End Try                                                                                            
Begin Catch                                                                                        
    Set @HasError=1                                                                                       
    Declare @ErrorMessage nvarchar(max)                                                                                             
    Select @ErrorMessage=ERROR_MESSAGE()                                             
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('st_SaveAgentCreditLimitHistory',Getdate(),@ErrorMessage)                                                                                            
End Catch 