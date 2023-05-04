CREATE SERVICE [//Maxi/Transfer/UpdateRecipService]
    AUTHORIZATION [dbo]
    ON QUEUE [QueueSW].[UpdateRecipQueue]
    ([//Maxi/Transfer/UpdateContract]);

