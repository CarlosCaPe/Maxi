CREATE procedure [dbo].[st_AgentVerifyCreditLimit]
(
    @Idagent int
)
as
/********************************************************************
<Author>--</Author>
<app>---</app>
<Description>---</Description>

<ChangeLog>
<log Date="13/02/2018" Author="jdarellano" Name="#1">Performance: se eliminan "TOP 1" de "EXISTS".</log>
</ChangeLog>
*********************************************************************/
Begin Try 

--Checar margen de agente
EXEC st_GetAgentCreditApproval @IdAgent

Declare @CurrentBalance Money,
        @SystemIdUser INT, 
        @CreditLimitSuggested money                                                       

Select @CurrentBalance=isNull(Balance,0) from [dbo].[AgentCurrentBalance] with(nolock) where IdAgent=@IdAgent                                                        
Set @CurrentBalance= ISNULL(@CurrentBalance,0)                                                       

SELECT TOP 1 @CreditLimitSuggested=CreditLimitSuggested FROM [dbo].[AgentCreditApproval] with(nolock) WHERE IdAgent=@IdAgent AND IsApproved is null ORDER BY IdAgentCreditApproval DESC
SET @CreditLimitSuggested=ISNULL(@CreditLimitSuggested,0)

If 
--exists (Select top 1 1 from Agent with(nolock) where IdAgent=@IdAgent and CreditAmount<@CurrentBalance AND IdAgentStatus=1)         
exists (Select 1 from [dbo].[Agent] with(nolock) where IdAgent=@IdAgent and CreditAmount<@CurrentBalance AND IdAgentStatus=1)--#1
AND
(@CreditLimitSuggested<@CurrentBalance)
Begin                                
 Select @SystemIdUser=dbo.GetGlobalAttributeByName('SystemUserID')
 exec st_AgentStatusChange
    @IdAgent,
    4,
    @SystemIdUser,
    'Hold by AgentVerifyCreditLimit'
End                                                        
end try
Begin Catch 
 Declare @ErrorMessage nvarchar(max)                                                                                             
 Select @ErrorMessage=ERROR_MESSAGE()                                             
 Insert into [dbo].[ErrorLogForStoreProcedure] (StoreProcedure,ErrorDate,ErrorMessage)Values('st_AgentVerifyCreditLimit',Getdate(),@ErrorMessage)                                                                                            
End Catch 


