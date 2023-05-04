CREATE procedure [msg].[st_AgentNotificationReminderPayment]
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/
as
--Delaracion de variables
Declare @DayOfPayment int
Declare @Today datetime
Declare @IdAgentPaydayReminder int
Declare @IdAgentPaydayReminderTop int
Declare @IdAgent int
Declare @Amount money
Declare @HasError bit
Declare @MessageError nvarchar(max)
Declare @Condition int
Declare @JSONMessage nvarchar(max)
Declare @TEXTMessage nvarchar(max)
Declare @ShowNotification BIT
Declare @SendFax bit
Declare @IdCollectionNotificationRuleType int
Declare @IdMessageProvider int
Declare @IsSpanishLanguage int
DECLARE @IdAgentCommunication int
    
--Inicializacion de variables
set @Today = getdate()
--Inicializacion de variables

SELECT @MessageError = dbo.GetMessageFromLenguajeResorces (1,64),
       @IdCollectionNotificationRuleType=2, --Pay Day Reminder
       @IdMessageProvider=4,
       @IsSpanishLanguage=1,
       @HasError = 0

Select   @DayOfPayment = dbo.[GetDayOfWeek](@Today)
        ,@Today = dbo.RemoveTimeFromDatetime(@Today)

create table #AgentPaydayReminder
(
    IdAgentPaydayReminder int identity(1,1),
    IdAgent int,
    Amount MONEY,
    IdAgentCommunication INT    
)

--Obtener Agencias que realizan el pago en la fecha actual
insert into #AgentPaydayReminder
select m.idagent,amountbycalendar amount , IdAgentCommunication 
  from maxicollection as m WITH(NOLOCK)
 inner join agent as a WITH(NOLOCK) on m.idagent=a.idagent
where dateofcollection=@Today and amountbycalendar>0
--Select
-- A.IdAgent, 
-- isnull((Select top 1 Balance from AgentBalance where DateOfMovement<dbo.funLastPaymentDate(A.IdAgent,@Today)+1 and IdAgent=A.idAgent order by DateOfMovement desc),0) as Amount ,
-- IdAgentCommunication
-- from Agent A
-- where     
--		(  
--		    DoneOnSundayPayOn=@DayOfPayment or    
--		    DoneOnMondayPayOn=@DayOfPayment or    
--		    DoneOnTuesdayPayOn=@DayOfPayment or    
--		    DoneOnWednesdayPayOn=@DayOfPayment or    
--		    DoneOnThursdayPayOn=@DayOfPayment or    
--		    DoneOnFridayPayOn=@DayOfPayment or    
--		    DoneOnSaturdayPayOn=@DayOfPayment  
--		)
--        AND A.IdAgentStatus!= 2 or A.IdAgentStatus!= 5 or A.IdAgentStatus!= 6
--        AND isnull((Select top 1 Balance from AgentBalance where DateOfMovement<dbo.funLastPaymentDate(A.IdAgent,@Today)+1 and IdAgent=A.idAgent order by DateOfMovement desc),0)>0

SELECT @IdAgentPaydayReminder = 1,@IdAgentPaydayReminderTop=MAX(IdAgentPaydayReminder) FROM #AgentPaydayReminder

WHILE @IdAgentPaydayReminder <= (@IdAgentPaydayReminderTop)
BEGIN
    select @IdAgent=IdAgent, @Amount=Amount, @IdAgentCommunication=IdAgentCommunication from  #AgentPaydayReminder where IdAgentPaydayReminder=@IdAgentPaydayReminder
        --if @Amount>0
    --begin
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

       EXEC	[msg].[st_CreateMessageForAgent]
	    	@IdAgent,		
    		@JSONMessage,
            @TEXTMessage,
		    @ShowNotification,
		    @SendFax,
            @IdCollectionNotificationRuleType,
		    @HasError = @HasError OUTPUT,
		    @MessageError = @MessageError OUTPUT
        
    --end
    SET @IdAgentPaydayReminder = @IdAgentPaydayReminder + 1
END