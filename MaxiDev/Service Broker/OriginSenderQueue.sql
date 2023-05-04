CREATE QUEUE [QueueSW].[OriginSenderQueue]
    WITH ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dbo].[sp_ReceiptMessageReader], MAX_QUEUE_READERS = 4, EXECUTE AS N'dbo');

