CREATE SERVICE [//Maxi/Transfer/GatewayRecipService]
    AUTHORIZATION [dbo]
    ON QUEUE [QueueSW].[GatewayRecipQueue]
    ([//Maxi/Transfer/GatewayContract]);

