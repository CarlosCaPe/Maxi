CREATE SERVICE [//Maxi/Transfer/OriginSenderService]
    AUTHORIZATION [dbo]
    ON QUEUE [QueueSW].[OriginSenderQueue]
    ([//Maxi/Transfer/OriginContract]);

