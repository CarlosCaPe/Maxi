CREATE PROCEDURE [Corp].[st_GetAgentCreditApproval]
(
    @Idagent int
)

/********************************************************************
<Author></Author>
<app>  </app>
<Description></Description>
<SampleCall></SampleCall>
<ChangeLog>
<log Date="10/12/2018" Author="adominguez">Se agrega try catch</log>
</ChangeLog>
*********************************************************************/

as

Begin try
--declaracion de variables
Declare @PercentForLimitCredit int
Declare @BalanceActual money
Declare @CreditActual money
Declare @CreditLimitSuggested money
Declare @AgentClassPercent int
Declare @IdAgentStatus int
Declare @ActualDate datetime
Declare @SystemUser int

--validar rechazo de credito
IF EXISTS (SELECT TOP 1 1 FROM AgentCreditApproval with(nolock) WHERE IdAgent=@Idagent AND IsApproved is null) RETURN

--Inicializar Variables
SELECT @PercentForLimitCredit = 100 - CONVERT(INT,dbo.GetGlobalAttributeByName('CreditLimitPorcentToShowWarning')),
       @SystemUser = CONVERT(INT,dbo.GetGlobalAttributeByName('SystemUserID'))

select
    @BalanceActual = isnull(c.balance,0),
    @CreditActual = isnull(a.creditamount,0),
	@AgentClassPercent = ac.classpercent,
	@IdAgentStatus=a.idAgentStatus
from agentcurrentbalance c with(nolock)
join agent a with(nolock) on c.idagent=a.idagent
join agentclass ac with(nolock) on a.idagentclass=ac.idagentclass
where c.idagent=@Idagent

set @BalanceActual=isnull(@BalanceActual,0)
set @CreditActual=isnull(@CreditActual,0)
set @AgentClassPercent=isnull(@AgentClassPercent,0)
set @ActualDate=dbo.RemoveTimeFromDatetime(getdate())

--Verificar limite actual y Verificar si ya se le rechazo un credito o no existe calculo de credito
--if (@CreditActual=0 or @AgentClassPercent=0 or exists(select top 1 1 from AgentCreditApproval where idagent=@Idagent and isnull(IsApproved,0)!=1 and dbo.RemoveTimeFromDatetime(CreationDate)=@ActualDate)) return

if (@CreditActual=0 or @AgentClassPercent=0) RETURN
--Verificar  si esta cerca de su limite de credito y verificar si es buen pagador
if (@BalanceActual >= @CreditActual-(@CreditActual*@PercentForLimitCredit/100) AND 
    EXISTS
        (
            SELECT TOP 1 1 FROM dbo.AgentDeposit a with(nolock) where idagent=@Idagent AND dbo.RemoveTimeFromDatetime(DepositDate) >= dbo.RemoveTimeFromDatetime([dbo].[funPastPaymentDateN](A.IdAgent,GETDATE()))
			--dbo.RemoveTimeFromDatetime(dbo.funLastPaymentDate(A.IdAgent,GETDATE()))
        )
    )
begin
    set @CreditLimitSuggested = round(@CreditActual+(@CreditActual*@AgentClassPercent/100),2)
    INSERT INTO [dbo].[AgentCreditApproval]
           ([IdAgent]
           ,[CreditLimit]
           ,[CreditLimitSuggested]           
           ,[CreationDate]
           ,[DateOfLastChange]
           ,[EnterByIdUser])
     VALUES
           ( @IdAgent
            , @CreditActual
            , @CreditLimitSuggested           
            , getdate()
            , getdate()
           , @SystemUser
           )
end
End try

begin catch     

Declare @ErrorMessage nvarchar(max)                                                                                             
Select @ErrorMessage=ERROR_MESSAGE()                                                    
    Insert into ErrorLogForStoreProcedure (StoreProcedure,ErrorDate,ErrorMessage)Values('dbo.st_GetAgentCreditApproval',Getdate(),@ErrorMessage)
                                                                                            
end catch









