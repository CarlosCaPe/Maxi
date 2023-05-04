CREATE QUEUE [QueueSW].[UpdateSenderQueue]
    WITH ACTIVATION (STATUS = ON, PROCEDURE_NAME = [dbo].[sp_ReceiptUpdateMessageReader], MAX_QUEUE_READERS = 4, EXECUTE AS N'dbo');

