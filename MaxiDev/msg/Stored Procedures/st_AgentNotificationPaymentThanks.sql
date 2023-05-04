
CREATE procedure [msg].[st_AgentNotificationPaymentThanks]
(
    @Idagent int,
    @HasError bit out,
    @MessageError nvarchar(max) out
)
as

/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="24/01/2018" Author="jmolina">Add with(nolock) And Schema</log>
</ChangeLog>
********************************************************************/

--Declaracion de variables
DECLARE	
		@Condition int,
		@JSONMessage nvarchar(max),
        @TEXTMessage nvarchar(max),
		@ShowNotification bit,
        @SendFax bit,
        @IdCollectionNotificationRuleType int               

--Inicializacion de variables

Select 
    @MessageError = dbo.GetMessageFromLenguajeResorces (1,64) ,
    @IdCollectionNotificationRuleType=1, --Default Payment Thanks
    @HasError = 0




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
