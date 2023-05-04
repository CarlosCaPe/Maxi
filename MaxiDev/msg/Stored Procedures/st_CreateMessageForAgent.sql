
CREATE Procedure [msg].[st_CreateMessageForAgent]
(
        @IdAgent int,		
		@JSONMessage NVARCHAR(max),		
        @TEXTMessage NVARCHAR(max),		
        @ShowNotification bit,
        @SendFax BIT,
        @IdCollectionNotificationRuleType INT,
		@HasError BIT OUTPUT,
		@MessageError NVARCHAR(max) OUTPUT
)
/********************************************************************
<Author>Not Known</Author>
<app>MaxiCorp</app>
<Description></Description>

<ChangeLog>
<log Date="13/09/2018" Author="jmolina">Add with(nolock)</log>
</ChangeLog>
********************************************************************/

AS
--Declaracion de variables
DECLARE @IdAgentCommunication int
DECLARE @Parameters XML
DECLARE @ReportName NVARCHAR(max)
DECLARE @Priority INT
DECLARE @SystemUser INT
DECLARE @IdMessageProvider int
DECLARE @IsSpanishLanguage int 
DECLARE @AgentName NVARCHAR(max)
DECLARE @AgentCode NVARCHAR(max)
DECLARE @IdMessage INT
DECLARE @Footer NVARCHAR(max)
DECLARE @Header NVARCHAR(max)
DECLARE @IdAgentStatus INT
DECLARE @CurrentBalance money

--Inicializaciond e variables
IF @IdCollectionNotificationRuleType=0  RETURN;
SELECT 
    @AgentName=AgentName,
    @AgentCode=AgentCode,
    @IdAgentCommunication=IdAgentCommunication, 
    @ReportName='PayReminder',
    @Priority=1,
    @HasError=0,
    @Footer='',
    @Header='',
    @MessageError='No enviar',
    @SystemUser = CONVERT(INT,dbo.GetGlobalAttributeByName('SystemUserID')),
    @IdMessageProvider=4,
    @IsSpanishLanguage=1,
    @IdAgentStatus=IdAgentstatus,
    @CurrentBalance=isnull(balance,0)
FROM 
    [dbo].Agent AS a WITH(NOLOCK)
left join [dbo].agentcurrentbalance AS b WITH(NOLOCK) on a.idagent=b.idagent
WHERE a.IdAgent=@IdAgent

--valdiacion status y currentbalance
if (@IdAgentStatus=2)
begin
    return
end

IF ((@IdAgentCommunication=1 OR @IdAgentCommunication=4) AND @ShowNotification=1)
BEGIN   
  
    IF NOT EXISTS (
        SELECT 1 FROM [dbo].AgentNotificacionReminder AS n WITH(NOLOCK)
        inner join msg.[MessageSubcribers] AS s WITH(NOLOCK) on n.idmessage=s.idmessage
        WHERE IdAgent=@IdAgent AND 
              IdCollectionNotificationRuleType=@IdCollectionNotificationRuleType and
              idmessagestatus not in (4,5)
        )
    BEGIN
        EXEC @IdMessage = [dbo].[st_CreateMessageForAgent]
	        @IdAgent,
	        @IdMessageProvider,
	        @SystemUser,
	        @JSONMessage,
	        @IsSpanishLanguage,
	        @HasError OUTPUT,
	        @MessageError OUTPUT    
    
        IF (@IdCollectionNotificationRuleType!=1 AND @IdMessage>0)
        BEGIN
            --agregar notificaciones en tabla AgentNotificacionReminder
            INSERT INTO dbo.AgentNotificacionReminder
                    ( IdAgent ,
                        IdMessage ,
                        IdCollectionNotificationRuleType
                    )
            VALUES  ( @IdAgent , -- IdAgent - int
                        @IdMessage , -- IdMessage - int
                        @IdCollectionNotificationRuleType  -- IdCollectionNotificationRuleType - int
                    )        
        END
        
        IF (@IdCollectionNotificationRuleType=1)
        BEGIN
            --eliminar notificaciones por deposito      
            DECLARE
		        @HasError2 bit,
		        @MessageOut2 varchar(max)      
            EXEC [dbo].[st_DismissNotificationReminder]
		        @IdAgent,
		        @IsSpanishLanguage,
		        @HasError2 OUTPUT,
		        @MessageOut2 OUTPUT
        END    
    END  
    
END
ELSE
BEGIN
    IF ((@IdAgentCommunication=2 OR @IdAgentCommunication=3) AND @SendFax=1)
    BEGIN
            DECLARE @QR_Base64_Image nvarchar(max)

            if @IdCollectionNotificationRuleType=2
            begin
                set @Footer='Al Fax (866) 629‐8726 o por e‐mail a cob@maxi‐ms.com'
                set @Header='Es necesario que envíe su ficha de depósito  correspondiente, gracias.'
            end
         
            select @QR_Base64_Image = [dbo].[GetGlobalAttributeByName]('QRHandler')+'?id='+[dbo].[GetGlobalAttributeByName]('QRAgentPrefix')+convert(varchar,@IdAgent)
            SELECT @Parameters=
            (
                SELECT
                (
                SELECT
                @TEXTMessage AS [Parameter/@Message],
                @AgentCode AS [Parameter/@AgentCode],
                @AgentName AS [Parameter/@AgentName],
                @QR_Base64_Image AS [Parameter/@QR_Base64_Image],
                @Footer AS [Parameter/@Footer],
                @Header AS [Parameter/@Header]
                FOR XML PATH('Parameters'),TYPE
                ).query('
                for $Parameters in /Parameters
                return
                <Parameters>        
                <Parameter name="Message" value="{data($Parameters/Parameter/@Message)}"></Parameter>
                <Parameter name="AgentCode" value="{data($Parameters/Parameter/@AgentCode)}"></Parameter>
                <Parameter name="AgentName" value="{data($Parameters/Parameter/@AgentName)}"></Parameter>
                <Parameter name="QR_Base64_Image" value="{data($Parameters/Parameter/@QR_Base64_Image)}"></Parameter>
                <Parameter name="Footer" value="{data($Parameters/Parameter/@Footer)}"></Parameter>
                <Parameter name="Header" value="{data($Parameters/Parameter/@Header)}"></Parameter>
                </Parameters>
                ')   
            )       
       
        
        EXEC [dbo].[st_InsertFaxToQueueFaxes]
		@Parameters,
		@ReportName,
		@Priority,
		@IdAgent,
		1,--@IdLenguage,
        @SystemUser,
		@HasError OUTPUT,
		@MessageError OUTPUT
    END  
END

