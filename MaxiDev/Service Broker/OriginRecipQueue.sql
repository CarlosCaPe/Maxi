CREATE QUEUE [QueueSW].[OriginRecipQueue]
    WITH STATUS = OFF, ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dbo].[sp_OriginMessageReader], MAX_QUEUE_READERS = 4, EXECUTE AS N'dbo');

