CREATE SERVICE [//Maxi/Transfer/GatewaySenderService]
    AUTHORIZATION [dbo]
    ON QUEUE [QueueSW].[GatewaySenderQueue]
    ([//Maxi/Transfer/GatewayContract]);

