CREATE PROCEDURE [Corp].[st_AgentNotificationPaymentThanks_msg]
(
    @Idagent int,
    @HasError bit out,
    @MessageError nvarchar(max) out
)
as

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




EXEC	[Corp].[st_GetAgentCollectionNotificationRule_msg]
		@Idagent,
		@IdCollectionNotificationRuleType, 
		@Condition OUTPUT,
		@JSONMessage OUTPUT,
        @TEXTMessage OUTPUT,
		@ShowNotification OUTPUT,
        @SendFax OUTPUT

EXEC	[Corp].[st_CreateMessageForAgent_msg]
		@IdAgent,		
		@JSONMessage,
        @TEXTMessage,
		@ShowNotification,
		@SendFax,
        @IdCollectionNotificationRuleType,
		@HasError = @HasError OUTPUT,
		@MessageError = @MessageError OUTPUT
