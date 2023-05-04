CREATE SERVICE [//Maxi/Transfer/OriginRecipService]
    AUTHORIZATION [dbo]
    ON QUEUE [QueueSW].[OriginRecipQueue]
    ([//Maxi/Transfer/OriginContract]);

