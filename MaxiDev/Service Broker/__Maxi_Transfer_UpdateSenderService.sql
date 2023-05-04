CREATE SERVICE [//Maxi/Transfer/UpdateSenderService]
    AUTHORIZATION [dbo]
    ON QUEUE [QueueSW].[UpdateSenderQueue]
    ([//Maxi/Transfer/UpdateContract]);

