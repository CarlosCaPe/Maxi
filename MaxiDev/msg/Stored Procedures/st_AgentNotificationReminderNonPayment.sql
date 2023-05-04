CREATE procedure [msg].[st_AgentNotificationReminderNonPayment]
as
/********************************************************************
<Author> UNKNOW </Author>
<Description> Inserta FAX para las agencias que no han realizado su deposito </Description>

<ChangeLog>
<log Date="04/06/2018" Author="azavala">No contemplar Agencias Writte Off</log>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
*********************************************************************/
--Delaracion de variables
Declare @DayOfPayment int
Declare @Today datetime
Declare @IdAgentNonPayReminder int
Declare @IdAgentNonPayReminderTop int
Declare @IdAgent int
Declare @Amount money
Declare @HasError bit
Declare @MessageError nvarchar(max)
Declare @Condition int
Declare @JSONMessage nvarchar(max)
Declare @TEXTMessage nvarchar(max)
Declare @ShowNotification BIT
DECLARE @SendFax bit
Declare @IdCollectionNotificationRuleType int
Declare @IdMessageProvider int
Declare @IsSpanishLanguage int
DECLARE @ActualDate DATETIME
DECLARE @LastDayOfPayment DATETIME
DECLARE @DepositAmount MONEY
DECLARE @IdAgentCommunication int
DECLARE @MessageXML XML
    
--Inicializacion de variables

SELECT  @MessageError = dbo.GetMessageFromLenguajeResorces (1,64),
        @Today = getdate(),
        @IdCollectionNotificationRuleType=3, --Non Pay Reminder
        @IdMessageProvider=4,
        @IsSpanishLanguage=1,
        @HasError = 0

Select   @DayOfPayment = dbo.[GetDayOfWeek](@Today)
        ,@Today = dbo.RemoveTimeFromDatetime(@Today)
        ,@ActualDate=[dbo].[RemoveTimeFromDatetime] (dateadd(day,0,Getdate()))

CREATE TABLE #AgentNonPayReminder
(
    IdAgentNonPayReminder int identity(1,1),
    IdAgent INT,
    LastDayOfPayment DATETIME,
    LastBalance MONEY,
    IdAgentCommunication int
)

INSERT INTO #AgentNonPayReminder
select
     idagent,
     [dbo].funPastPaymentDateN (idagent,@Today) LastDayOfPayment,
     --isnull((select top 1 1 from agentdeposit d where a.idagent=d.idagent and depositdate>=[dbo].[funLastPaymentDate] (idagent,@Today) and depositdate<=[dbo].[RemoveTimeFromDatetime] ( dateadd(day,-1,Getdate()))),0) IsDeposit
     isnull((Select top 1 Balance from AgentBalance WITH(NOLOCK) where DateOfMovement<dateadd(day,1,[dbo].funPastPaymentDateN (idagent,@Today))+1 and IdAgent=A.idAgent order by DateOfMovement desc),0) as LastBalance,
     --isnull((Select top 1 Balance from AgentBalance where DateOfMovement<dateadd(day,1,Getdate()) and IdAgent=A.idAgent order by DateOfMovement desc),0) as ActualBalance
     IdAgentCommunication
from agent AS A WITH(NOLOCK)
WHERE
    isnull((Select top 1 Balance from AgentBalance WITH(NOLOCK) where DateOfMovement<dateadd(day,1,[dbo].funPastPaymentDateN (idagent,@Today))+1 and IdAgent=A.idAgent order by DateOfMovement desc),0)>0
	and A.IdAgentStatus<>6 /*Agencias Writte Off*/

SELECT @IdAgentNonPayReminder = 1,@IdAgentNonPayReminderTop=MAX(IdAgentNonPayReminder) FROM #AgentNonPayReminder

WHILE @IdAgentNonPayReminder <= (@IdAgentNonPayReminderTop)
BEGIN
    select @IdAgent=IdAgent, @Amount=LastBalance, @LastDayOfPayment=LastDayOfPayment, @IdAgentCommunication=IdAgentCommunication from  #AgentNonPayReminder where IdAgentNonPayReminder=@IdAgentNonPayReminder
    
    SELECT @DepositAmount=SUM(Amount) FROM dbo.AgentDeposit WITH(NOLOCK) WHERE IdAgent=@IdAgent AND DepositDate>=@LastDayOfPayment AND DepositDate<=@ActualDate

    SET @DepositAmount = ISNULL(@DepositAmount,0)

    set @Condition=''
    set @JSONMessage=''
    set @TEXTMessage=''
    set @ShowNotification=0
    set @SendFax=0

    EXEC	[msg].[st_GetAgentCollectionNotificationRule]
		@Idagent,
		@IdCollectionNotificationRuleType, 
		@Condition OUTPUT,
        @JSONMessage OUTPUT,
		@TEXTMessage OUTPUT,
		@ShowNotification OUTPUT,        
        @SendFax OUTPUT
       
    
    --if @DepositAmount=0 AND @LastDayOfPayment<=dateadd(day,-1*@Condition,@ActualDate)
   IF @DepositAmount=0 AND DATEDIFF(DAY, @LastDayOfPayment,dateadd(day,-1*@Condition,@ActualDate))<=@Condition
    begin        
  
        EXEC	[msg].[st_CreateMessageForAgent]
	    	@IdAgent,		
    		@JSONMessage,
		    @TEXTMessage,
		    @ShowNotification,
		    @SendFax,
            @IdCollectionNotificationRuleType,
		    @HasError = @HasError OUTPUT,
		    @MessageError = @MessageError OUTPUT      
    end
    SET @IdAgentNonPayReminder = @IdAgentNonPayReminder + 1
END