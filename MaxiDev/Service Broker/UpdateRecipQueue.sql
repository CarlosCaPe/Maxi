CREATE QUEUE [QueueSW].[UpdateRecipQueue]
    WITH ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dbo].[sp_UpdateMessageReader], MAX_QUEUE_READERS = 4, EXECUTE AS N'dbo');

