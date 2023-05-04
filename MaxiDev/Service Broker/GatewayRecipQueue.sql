CREATE QUEUE [QueueSW].[GatewayRecipQueue]
    WITH ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dbo].[sp_GatewayMessageReader], MAX_QUEUE_READERS = 2, EXECUTE AS N'dbo');

